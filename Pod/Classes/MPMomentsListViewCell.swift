//
//  MPMomentsListViewCell.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/11/24.
//
//

import Foundation
import Photos

class MPMomentsListViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource {
    
//    var test: [PHFetchResult] = []
    
    var selectDelegate: MPMomentsListViewCellDelegate?
    
    var fetchResult: PHFetchResult?
    var assetCollection: PHAssetCollection?
    var cellChecked: [Bool] = []
    
    var rowInMomeryList: Int = 0
    var title: UILabel = UILabel(frame: CGRectZero)
    var subtitle: UILabel = UILabel(frame: CGRectZero)
    var cellImageThumbnailRequestSize: CGSize = CGSizeMake(0, 0)
    var cellGrid: UICollectionView?
    
    let imageManager: PHImageManager = PHImageManager()
    
    // MARK: - override
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        title.font = UIFont.systemFontOfSize(18)
        title.textColor = UIColor.blackColor()
        title.textAlignment = NSTextAlignment.Left
        self.contentView.addSubview(title)
        
        subtitle.font = UIFont.systemFontOfSize(14)
        subtitle.textColor = UIColor.blackColor()
        subtitle.textAlignment = NSTextAlignment.Left
        self.contentView.addSubview(subtitle)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let width = floor(UIScreen.mainScreen().bounds.width / 4)
        layout.itemSize = CGSizeMake(width, width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = LINE_HEIGHT_IN_SUB_COLLECTION
        
        cellGrid = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        cellGrid!.registerClass(MPAssetGridViewCell.classForCoder(), forCellWithReuseIdentifier: "sgcell")
        cellGrid!.backgroundColor = UIColor.whiteColor()
        cellGrid!.dataSource = self
        cellGrid!.delegate = self
        self.contentView.addSubview(cellGrid!)
        
        let scale = UIScreen.mainScreen().scale
        let ratio = PHOTO_DEFAULT_RATIO_H_2_W.IPHONE_6.rawValue
        cellImageThumbnailRequestSize = CGSizeMake(width * scale, width * scale * ratio)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        title.frame = CGRectMake(0, 0, self.bounds.width, CGFloat(MOMENTS_LIST_CELL_TITLE_HEIGHT)).insetBy(dx: 4, dy: 4)
        subtitle.frame = CGRectMake(0, CGFloat(MOMENTS_LIST_CELL_TITLE_HEIGHT), self.bounds.width, CGFloat(MOMENTS_LIST_CELL_SUBTITLE_HEIGHT)).insetBy(dx: 4, dy: 4)
        cellGrid!.frame = CGRectMake(0, CGFloat(MOMENTS_LIST_CELL_TITLE_AREA_HEIGHT), self.bounds.width, self.bounds.height - CGFloat(MOMENTS_LIST_CELL_TITLE_AREA_HEIGHT))
    }
    
    override func prepareForReuse() {
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("sgcell", forIndexPath: indexPath) as! MPAssetGridViewCell
        
        let asset = self.fetchResult![indexPath.item] as! PHAsset
        let options = PHImageRequestOptions()
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.FastFormat
        
        self.imageManager.requestImageForAsset(
            asset,
            targetSize: self.cellImageThumbnailRequestSize,
            contentMode: PHImageContentMode.AspectFill,
            options: options,
            resultHandler: { result, info in
                cell.imageView.image = result
            })
        
        cell.checkMark.checked = cellChecked[indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let selectDelegate = self.selectDelegate {
            if selectDelegate.isSelectionEnable(row: self.rowInMomeryList, cellIndex: indexPath.item) {
                let asset = self.fetchResult![indexPath.item] as! PHAsset
                cellChecked[indexPath.item] = !cellChecked[indexPath.item]
                cellGrid!.reloadItemsAtIndexPaths([indexPath])
                if MPCheckMarkStorage.sharedInstance.removeIfAlreadyChecked(row: self.rowInMomeryList, cellIndex: indexPath.item, asset: asset) {
                    // already checked, remove it
                } else {
                    MPCheckMarkStorage.sharedInstance.addEntry(row: self.rowInMomeryList, cellIndex: indexPath.item, asset: asset)
                }
                selectDelegate.didSelectImageInCell(row: self.rowInMomeryList, cellIndex: indexPath.item)
            }
        }
    }
    
    // MARK: - method
    
    func prepareData(fetchResult: PHFetchResult, row: Int) {
        self.fetchResult = fetchResult
        self.rowInMomeryList = row
        self.cellChecked = [Bool](count: self.fetchResult!.count, repeatedValue: false)
        
        let indexList = MPCheckMarkStorage.sharedInstance.getCheckedCellIndexListInRow(self.rowInMomeryList)
        indexList.each { checkedCellIndex in
            self.cellChecked[checkedCellIndex] = true
        }
    }
}