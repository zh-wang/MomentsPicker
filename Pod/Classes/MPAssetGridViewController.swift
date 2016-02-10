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
    
    var cellGrid: UICollectionView!
    var footerView: DynamicBottomBar = DynamicBottomBar(frame: CGRectZero)
    
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
        cellGrid.frame = self.view.bounds
        cellGrid.registerClass(MPAssetGridViewCell.classForCoder(), forCellWithReuseIdentifier: "gcell")
        cellGrid.backgroundColor = UIColor.whiteColor()
        cellGrid.dataSource = self
        cellGrid.delegate = self
        self.view.addSubview(cellGrid)
        
//        let doneBtn = UIBarButtonItem(title: self.config?.barBtnTitleDone, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onTapDoneButton"))
//        self.navigationItem.rightBarButtonItem = doneBtn
        
        let cancelBtn = UIBarButtonItem(title: self.config?.barBtnTitleCancel, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onTapCancelButton"))
        self.navigationItem.rightBarButtonItem = cancelBtn
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        let scale = UIScreen.mainScreen().scale
        let ratio = PHOTO_DEFAULT_RATIO_H_2_W.IPHONE_6.rawValue
        assetGridThumbnailSize = CGSizeMake(width * scale, width * scale * ratio)
    }
    
    override func viewDidLoad() {
        // Add footer view if needed
//        if let footerView = self.config?.staticFooterView {
//            let footerHeight = footerView.frame.height
//            let bounds = UIScreen.mainScreen().bounds
//            cellGrid.frame = CGRectMake(0, 0, bounds.width, bounds.height - footerHeight)
//            
//            let footerFrame = CGRectMake(0, bounds.height - footerHeight, bounds.width, footerHeight)
//            footerView.frame = footerFrame
//            self.view.addSubview(footerView)
//        }
        
        self.footerView.frame = CGRectMake(0, self.view.bounds.height - 48, self.view.bounds.width, 48)
        let footerHeight = footerView.frame.height
        self.cellGrid.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - footerHeight)
        self.view.addSubview(footerView)
        if let okBtnColor = self.config?.selectionEnabledColor {
            self.footerView.setOkBtnHighlightColor(okBtnColor)
        }
        if let range = self.config?.selectionRange {
            self.footerView.updateSelectionRange(range)
        }
        self.footerView.okBtn.addTarget(self, action: Selector("onTapDoneButton"), forControlEvents: UIControlEvents.TouchUpInside)
        
        if self.config!.startingPosition == .BOTTOM {
            self.cellGrid.scroll2Bottom(dataSourceCount: self.assetsFetchResults!.count, animated: false) // scroll to bottom
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults?.count ?? 0
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
            cellGrid.reloadItemsAtIndexPaths([indexPath])
            if MPCheckMarkStorage.sharedInstance.removeIfAlreadyChecked(cellIndex: indexPath.item, asset: asset) {
                // already checked, remove it
            } else {
                MPCheckMarkStorage.sharedInstance.addEntry(cellIndex: indexPath.item, asset: asset)
            }
            
            let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
            self.footerView.updateSelectionCounter(counter)
        
            self.changeTitleWhenSelected()
        }
    }
    
    func onTapDoneButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickedAssets(self, didFinishPickingAssets: MPCheckMarkStorage.sharedInstance.getCheckedAssets())
        }
    }
    
    func onTapCancelButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickCancelled(self)
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
                let selectedCounterText = String(format: config.selectedCounterText, arguments: [counter])
                self.navigationItem.title = selectedCounterText
            }
        }
    }
    
}