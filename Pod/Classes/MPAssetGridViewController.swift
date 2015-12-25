//
//  MPAssetGridViewController.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/11/24.
//
//

import Foundation
import Photos

class MPAssetGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource {
    
    var config: MPConfig?
    var delegate: MPViewControllerDelegate?
    
    var assetsFetchResults: PHFetchResult?
    var assetCollection: PHAssetCollection?
    var cellChecked: [Bool] = []
    
    var assetGridThumbnailSize: CGSize = CGSizeMake(0, 0)
    
    var cellGrid: UICollectionView?
    
    let imageManager: PHImageManager = PHImageManager()
    
    override func loadView() {
        super.loadView()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let width = floor(self.view.bounds.width / 4)
        layout.itemSize = CGSizeMake(width, width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = LINE_HEIGHT_IN_SUB_COLLECTION
        
        self.cellGrid = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        cellGrid!.frame = self.view.bounds
        cellGrid!.registerClass(MPAssetGridViewCell.classForCoder(), forCellWithReuseIdentifier: "gcell")
        cellGrid!.backgroundColor = UIColor.whiteColor()
        cellGrid!.dataSource = self
        cellGrid!.delegate = self
        self.view.addSubview(cellGrid!)
        
        let doneBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onTapDoneButton"))
        self.navigationItem.rightBarButtonItem = doneBtn
        
        let scale = UIScreen.mainScreen().scale
        let ratio = PHOTO_DEFAULT_RATIO_H_2_W.IPHONE_6.rawValue
        assetGridThumbnailSize = CGSizeMake(width * scale, width * scale * ratio)
    }
    
    override func viewDidLoad() {
        // Add footer view if needed
        if let footerView = self.config?.staticFooterView {
            let footerHeight = footerView.frame.height
            let bounds = UIScreen.mainScreen().bounds
            cellGrid!.frame = CGRectMake(0, 0, bounds.width, bounds.height - footerHeight)
            
            let footerFrame = CGRectMake(0, bounds.height - footerHeight, bounds.width, footerHeight)
            footerView.frame = footerFrame
            self.view.addSubview(footerView)
        }
        
        self.toggleDoneAvailability()
        
        self.cellGrid!.scroll2Bottom(dataSourceCount: self.assetsFetchResults!.count, animated: false) // scroll to bottom
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("gcell", forIndexPath: indexPath) as! MPAssetGridViewCell
        
        let asset = self.assetsFetchResults![indexPath.item] as! PHAsset
        let options = PHImageRequestOptions()
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.FastFormat
        
        self.imageManager.requestImageForAsset(
            asset,
            targetSize: self.assetGridThumbnailSize,
            contentMode: PHImageContentMode.AspectFill,
            options: nil,
            resultHandler: { result, info in
                cell.imageView.image = result
            })
        
        cell.checkMark.checked = cellChecked[indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.isSelectedTooMany() && self.isSelectingNewItem(indexPath.item) {
            // Cannot select more, but we can undo selecting for selected items
        } else {
            let asset = self.assetsFetchResults![indexPath.item] as! PHAsset
            cellChecked[indexPath.item] = !cellChecked[indexPath.item]
            cellGrid!.reloadItemsAtIndexPaths([indexPath])
            if MPCheckMarkStorage.sharedInstance.removeIfAlreadyChecked(cellIndex: indexPath.item, asset: asset) {
                // already checked, remove it
            } else {
                MPCheckMarkStorage.sharedInstance.addEntry(cellIndex: indexPath.item, asset: asset)
            }
        
            self.changeTitleWhenSelected()
            self.toggleDoneAvailability()
        }
    }
    
    func onTapDoneButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickedAssets(self, didFinishPickingAssets: MPCheckMarkStorage.sharedInstance.getCheckedAssets())
        }
    }
    
    func prepareData() {
        self.cellChecked = [Bool](count: self.assetsFetchResults!.count, repeatedValue: false)
        let indexList = MPCheckMarkStorage.sharedInstance.getCheckedCellIndexList()
        indexList.each { checkedCellIndex in
            self.cellChecked[checkedCellIndex] = true
        }
    }
    
    private func isSelectingNewItem(cellIndex: Int) -> Bool {
        return !MPCheckMarkStorage.sharedInstance.isEntryAlreadySelected(cellIndex: cellIndex)
    }
    
    private func isSelectedTooMany() -> Bool {
        if let config = self.config {
            if let selectionRange = config.selectionRange {
                let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
                return counter >= selectionRange.1 ? true : false
            }
        }
        return true
    }
    
    private func changeTitleWhenSelected() {
        if let config = self.config {
            if config.showSelectedCounter {
                let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
                self.navigationItem.title = "\(counter) selected"
            }
        }
    }
    
    private func toggleDoneAvailability() {
        if let config = self.config {
            if let selectionRange = config.selectionRange {
                let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
                let min = selectionRange.0
                let max = selectionRange.1
                if counter >= min && counter <= max {
                    self.navigationItem.rightBarButtonItem!.enabled = true
                } else {
                    self.navigationItem.rightBarButtonItem!.enabled = false
                }
            }
        }
    }
}