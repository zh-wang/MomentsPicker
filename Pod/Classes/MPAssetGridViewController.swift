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
    
    var config: MPConfig!
    var delegate: MPViewControllerDelegate?
    
    var assetsFetchResults: PHFetchResult?
//    var assetCollection: PHAssetCollection?
    
    var cellCheckedObv: Observable<[Bool]> = Observable<[Bool]>(value: [])
    
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
        
        if self.config.style == MPStyle.TOP_RIGHT_DONE {
            let doneBtn = UIBarButtonItem(title: self.config.barBtnTitleDone, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onTapDoneButton"))
            self.navigationItem.rightBarButtonItem = doneBtn
        }
        
        let cancelBtn = UIBarButtonItem(title: self.config.barBtnTitleCancel, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onTapCancelButton"))
        self.navigationItem.rightBarButtonItem = cancelBtn
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        let scale = UIScreen.mainScreen().scale
        let ratio = PHOTO_DEFAULT_RATIO_H_2_W.IPHONE_6.rawValue
        assetGridThumbnailSize = CGSizeMake(width * scale, width * scale * ratio)
        
        // observers
        // bind number of selected with top right done button enabled & footer view's counter
        MPCheckMarkStorage.sharedInstance.numberOfSelectedObv.addObserverPost("NUMBER_OF_SELECTED_OBV_ASSET_VC",
            didSetObserver: { [unowned self] oldValue, newValue in
                self.footerView.updateSelectionCounter()
                self.toggleDoneAvailability()
                self.changeTitleWhenSelected()
            })
        
        self.cellCheckedObv.addObserverPost("CELL_CHECKED_OBV_ASSET_VC",
            didSetObserver: { [unowned self] oldValue, newValue in
                // only update changed cell
                var indexPaths: [NSIndexPath] = []
                let n = oldValue!.count
                for i in 0..<n {
                    if oldValue![i] != newValue![i] {
                        indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
                    }
                }
                if indexPaths.count > 0 {
                    self.cellGrid.reloadItemsAtIndexPaths(indexPaths)
                }
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.config.style == MPStyle.BOTTOM_DYNAMIC_BAR {
            self.footerView.frame = CGRectMake(0, self.view.bounds.height - 48, self.view.bounds.width, 48)
            let footerHeight = footerView.frame.height
            self.cellGrid.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - footerHeight)
            self.view.addSubview(footerView)
            self.footerView.setOkBtnHighlightColor(self.config.selectionEnabledColor)
            if let range = self.config.selectionRange {
                self.footerView.updateSelectionRange(range)
            }
            self.footerView.okBtn.addTarget(self, action: Selector("onTapDoneButton"), forControlEvents: UIControlEvents.TouchUpInside)
        } else { // Add custom footer view if needed
            if let footerView = self.config.staticFooterView {
                let footerHeight = footerView.frame.height
                let bounds = UIScreen.mainScreen().bounds
                cellGrid.frame = CGRectMake(0, 0, bounds.width, bounds.height - footerHeight)
                
                let footerFrame = CGRectMake(0, bounds.height - footerHeight, bounds.width, footerHeight)
                footerView.frame = footerFrame
                self.view.addSubview(footerView)
            }
        }
        
        if self.config.startingPosition == .BOTTOM {
            self.cellGrid.scroll2Bottom(dataSourceCount: self.assetsFetchResults!.count, animated: false) // scroll to bottom
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.prepareData()
    }
    
    // MARK: - delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("gcell", forIndexPath: indexPath) as! MPAssetGridViewCell
        
        if let recogs = cell.gestureRecognizers {
            for _recog in recogs {
                cell.removeGestureRecognizer(_recog)
            }
        }
        let recog = UITapGestureRecognizer(target: self, action: Selector("handleTapOnCheckMark:"))
        cell.checkMark.addGestureRecognizer(recog)
        cell.checkMark.nsIndexPath = indexPath
        
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
        
        let checked = self.cellCheckedObv.getValue()?[indexPath.item] ?? false
        cell.checkMark.checked = checked
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.config.needDetailViewController {
            self.pushDetailViewController(indexPath: indexPath)
        } else {
            self.updateCheckMark(indexPath: indexPath)
        }
    }
    
    // MARK: - handlers
    
    @objc private func handleTapOnCheckMark(sender: UITapGestureRecognizer) {
        if let view = (sender.view as? MPCheckMarkView) {
            self.updateCheckMark(indexPath: view.nsIndexPath)
        }
    }
    
    // MARK: - handlers
    
    @objc private func onTapDoneButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickedAssets(self, didFinishPickingAssets: MPCheckMarkStorage.sharedInstance.getCheckedAssets())
        }
    }
    
    @objc private func onTapCancelButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickCancelled(self)
        }
    }

    // MARK: - funcs
    
    func prepareData() {
        var cellChecked = [Bool](count: self.assetsFetchResults!.count, repeatedValue: false)
        let indexList = MPCheckMarkStorage.sharedInstance.getCheckedCellIndexList()
        indexList.each { checkedCellIndex in
            cellChecked[checkedCellIndex] = true
        }
        self.cellCheckedObv.updateValue(cellChecked)
    }
    
    // MARK: - private funcs
    
    private func updateCheckMark(indexPath indexPath: NSIndexPath) {
        if self.isSelectedTooMany() && self.isSelectingNewItem(indexPath.item) {
            // Cannot select more, but we can undo selecting for selected items
        } else {
            
            if var cellChecked = self.cellCheckedObv.getValue() {
                cellChecked[indexPath.item] = !cellChecked[indexPath.item]
                self.cellCheckedObv.updateValue(cellChecked)
            }
            
            let asset = self.assetsFetchResults![indexPath.item] as! PHAsset
            if MPCheckMarkStorage.sharedInstance.removeIfAlreadyChecked(cellIndex: indexPath.item, asset: asset) {
                // already checked, remove it
            } else {
                MPCheckMarkStorage.sharedInstance.addEntry(cellIndex: indexPath.item, asset: asset)
            }
        }
    }
    
    private func pushDetailViewController(indexPath indexPath: NSIndexPath) {
        let detailVC = MPDetailViewController()
        detailVC.config = self.config
        detailVC.assetsFetchResults = self.assetsFetchResults
        detailVC.rowIndex = nil
        detailVC.startCellIndex = indexPath.item
        detailVC.delegate = self.delegate
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - private funcs
    
    private func updateCheckMark(indexPath indexPath: NSIndexPath) {
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
            
            self.changeTitleWhenSelected()
            self.toggleDoneAvailability()
        }
    }
    
    private func pushDetailViewController(indexPath indexPath: NSIndexPath) {
        let detailVC = MPDetailViewController()
        detailVC.config = self.config
        detailVC.assetsFetchResults = self.assetsFetchResults
        detailVC.rowIndex = nil
        detailVC.startCellIndex = indexPath.item
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func isSelectingNewItem(cellIndex: Int) -> Bool {
        return !MPCheckMarkStorage.sharedInstance.isEntryAlreadySelected(cellIndex: cellIndex)
    }
    
    private func isSelectedTooMany() -> Bool {
        if let selectionRange = config.selectionRange {
            let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
            return counter >= selectionRange.1 ? true : false
        }
        return true
    }
    
    private func changeTitleWhenSelected() {
        if config.showSelectedCounterInTitle {
            let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
            let selectedCounterText = String(format: config.selectedCounterText, arguments: [counter])
            self.navigationItem.title = selectedCounterText
        }
    }
    
    private func toggleDoneAvailability() {
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
