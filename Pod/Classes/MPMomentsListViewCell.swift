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
    
    var cellDelegate: MPMomentsListViewCellDelegate?
    
    var fetchResult: PHFetchResult?
    var assetCollection: PHAssetCollection?
    var cellChecked: [Bool] = []
    
    var rowInMomeryList: Int = 0
    var title: UILabel = UILabel(frame: CGRectZero)
    var subtitle: UILabel = UILabel(frame: CGRectZero)
    var dateLabel: UILabel = UILabel(frame: CGRectZero)
    var cellImageThumbnailRequestSize: CGSize = CGSizeMake(0, 0)
    var cellGrid: UICollectionView?
    
    let imageManager: PHImageManager = PHImageManager()
    let titleFont = UIFont.systemFontOfSize(16)
    let subtitleFont = UIFont.systemFontOfSize(12)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        title.font = titleFont
        title.textColor = UIColor.blackColor()
        title.textAlignment = NSTextAlignment.Left
        self.contentView.addSubview(title)
        
        subtitle.font = subtitleFont
        subtitle.textColor = UIColor.blackColor()
        subtitle.textAlignment = NSTextAlignment.Left
        self.contentView.addSubview(subtitle)
        
        dateLabel.font = subtitleFont
        dateLabel.textColor = UIColor.blackColor()
        dateLabel.textAlignment = NSTextAlignment.Right
        self.contentView.addSubview(dateLabel)
        
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
    
    override func prepareForReuse() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.title.frame = CGRectMake(0, CGFloat(MOMETNS_LIST_CELL_TITLE_TOP_PADDING), self.bounds.width, CGFloat(MOMENTS_LIST_CELL_TITLE_HEIGHT))
            .insetBy(dx: 4, dy: 4)
            .offsetBy(dx: 0, dy: 2)
        
        let subtitleStartY = CGFloat(MOMETNS_LIST_CELL_TITLE_TOP_PADDING + MOMENTS_LIST_CELL_TITLE_HEIGHT)
        let subtitleMaxWidth = self.bounds.width * 0.7
        self.subtitle.frame = CGRectMake(0, subtitleStartY, subtitleMaxWidth, CGFloat(MOMENTS_LIST_CELL_SUBTITLE_HEIGHT))
            .insetBy(dx: 4, dy: 4)
            .offsetBy(dx: 0, dy: -2)
        
        let dateLabelMaxWidth = self.bounds.width * 0.3
        self.dateLabel.frame = CGRectMake(self.bounds.width - dateLabelMaxWidth, subtitleStartY, dateLabelMaxWidth, CGFloat(MOMENTS_LIST_CELL_SUBTITLE_HEIGHT))
            .insetBy(dx: 4, dy: 4)
            .offsetBy(dx: -4, dy: -2)
        
        self.cellGrid!.frame = CGRectMake(0, CGFloat(MOMENTS_LIST_CELL_TITLE_AREA_HEIGHT), self.bounds.width, self.bounds.height - CGFloat(MOMENTS_LIST_CELL_TITLE_AREA_HEIGHT))
    }
    
    // MARK: - delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("sgcell", forIndexPath: indexPath) as! MPAssetGridViewCell
        
        if let recogs = cell.gestureRecognizers {
            for _recog in recogs {
                cell.removeGestureRecognizer(_recog)
            }
        }
        let recog = UITapGestureRecognizer(target: self, action: Selector("handleTapOnCheckMark:"))
        cell.checkMark.addGestureRecognizer(recog)
        cell.checkMark.nsIndexPath = indexPath
        
        if let phasset = self.ensureFetchedAssets(indexPath) {
            let options = PHImageRequestOptions()
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.FastFormat
            self.imageManager.requestImageForAsset(
                phasset,
                targetSize: self.cellImageThumbnailRequestSize,
                contentMode: PHImageContentMode.AspectFill,
                options: options,
                resultHandler: { result, info in
                    cell.imageView.image = result
                })
            cell.checkMark.checked = cellChecked[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.cellDelegate?.didSelectImageInCell(row: self.rowInMomeryList, cellIndex: indexPath.item, cell: self)
    }
    
    // MARK: - handlers
    
    @objc private func handleTapOnCheckMark(sender: UITapGestureRecognizer) {
        if let view = (sender.view as? MPCheckMarkView) {
//            self.updateCheckMark(indexPath: view.nsIndexPath)
            cellDelegate?.didTapCheckMark(row: self.rowInMomeryList, cellIndex: view.nsIndexPath.item, cell: self)
        }
    }
    
    // MARK: - funcs
    
    func prepareData(fetchResult: PHFetchResult, row: Int) {
        self.fetchResult = fetchResult
        self.rowInMomeryList = row
        self.cellChecked = [Bool](count: self.fetchResult!.count, repeatedValue: false)
        
        let indexList = MPCheckMarkStorage.sharedInstance.getCheckedCellIndexListInRow(self.rowInMomeryList)
        indexList.each { checkedCellIndex in
            self.cellChecked[checkedCellIndex] = true
        }
    }
    
    func updateCheckMarkInMomentsCell(cellIndex cellIndex: Int) -> Bool {
        if let cellDelegate = self.cellDelegate {
            let indexPath = NSIndexPath(forItem: cellIndex, inSection: 0)
            if !cellDelegate.isSelectionEnable(row: self.rowInMomeryList, cellIndex: indexPath.item, cell: self) {
                return false
            }
            if let phasset = self.ensureFetchedAssets(indexPath) {
                cellChecked[indexPath.item] = !cellChecked[indexPath.item]
                cellGrid!.reloadItemsAtIndexPaths([indexPath])
                if MPCheckMarkStorage.sharedInstance.removeIfAlreadyChecked(row: self.rowInMomeryList, cellIndex: indexPath.item, asset: phasset) {
                    // already checked, remove it
                } else {
                    MPCheckMarkStorage.sharedInstance.addEntry(row: self.rowInMomeryList, cellIndex: indexPath.item, asset: phasset)
                }
            }
        }
        return true
    }
    
    // MARK: - private funcs
    
    private func ensureFetchedAssets(indexPath: NSIndexPath) -> PHAsset? {
        let maybePhasset = self.fetchResult?[indexPath.item] as? PHAsset
        return maybePhasset
    }
    
}
