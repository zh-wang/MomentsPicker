//
//  MPDetailViewController.swift
//  Pods
//
//  Created by Wang Zhenghong on 2016/02/23.
//
//

import Foundation
import Photos

class MPDetailViewController: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource
    {
    
    var config: MPConfig!
    var delegate: MPViewControllerDelegate?
    
    var imageFetchSize: CGSize = CGSizeZero
    
    var assetsFetchResults: PHFetchResult?
    var rowIndex: Int? = 0 // only useful if parent vc is memory list
    var startCellIndex: Int = 0
    let imageManager: PHImageManager = PHImageManager()
    
    var collectionView: PagedCollectionView!
    var backBtn: FALBackButton = FALBackButton(frame: CGRectZero)
    var checkMark: MPCheckMarkView!
    var indicator: UILabel = UILabel(frame: CGRectZero)
    var footerView: DynamicBottomBar = DynamicBottomBar(frame: CGRectZero)
    
    private var popGesture: UIGestureRecognizer?
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height - 48)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        self.collectionView = PagedCollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.pagingEnabled = true
        collectionView.frame = self.view.bounds
        collectionView.registerClass(MPDetailViewCell.classForCoder(), forCellWithReuseIdentifier: "dcell")
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(self.collectionView)
        
        let scale = UIScreen.mainScreen().scale
        let ratio = PHOTO_DEFAULT_RATIO_H_2_W.IPHONE_6.rawValue
        let width = self.view.bounds.width
        self.imageFetchSize = CGSizeMake(width * scale, width * scale * ratio)
        
        let blurView = UIVisualEffectView(frame: CGRectMake(0, 0, self.view.bounds.width, 48 + 8))
        blurView.effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        self.view.addSubview(blurView)
        
        self.backBtn.frame = CGRectMake(0, 4, 48, 48)
        self.backBtn.addTarget(self, action: Selector("onTapBackBtn:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.backBtn)
        
        self.checkMark = MPCheckMarkView(frame: CGRectMake(self.view.bounds.width - 48, 4, 48, 48))
        self.view.addSubview(self.checkMark)
        self.checkMark.insets = UIEdgeInsetsMake(8, 4, 4, 8)
        let recog = UITapGestureRecognizer(target: self, action: Selector("onTapCheckMark:"))
        self.checkMark.addGestureRecognizer(recog)
        
        self.indicator.frame = CGRectMake(0, 4, self.view.bounds.width, 48)
        self.indicator.text = self.buildIndicatorText(currentIndex: self.startCellIndex)
        self.indicator.textColor = UIColor.blackColor()
        if #available(iOS 9.0, *) {
            self.indicator.font = UIFont.monospacedDigitSystemFontOfSize(22, weight: 0)
        } else {
            // Fallback on earlier versions
            self.indicator.font = UIFont.systemFontOfSize(22)
        }
        self.indicator.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.indicator)
        
        // observers
        // bind number of selected with check mark UI & footer view's counter
        MPCheckMarkStorage.sharedInstance.numberOfSelectedObv.addObserverPost("NUMBER_OF_SELECTED_OBV_DETAIL_VC",
            didSetObserver: { [weak self] oldValue, newValue in
                if let currentPageIndex = self?.collectionView.getCurrentPageIndex() {
                    self?.updateCheckMark(cellIndex: currentPageIndex)
                    self?.footerView.updateSelectionCounter()
                }
            })
        // bind page index with indicator & check mark UI
        self.collectionView.pageIndexObv.addObserverPost("PAGE_INDEX_OBV_DETAIL_VC",
            didSetObserver: { [weak self] oldValue, newValue in
                if let currentPageIndex = self?.collectionView.getCurrentPageIndex() {
                    self?.updateCheckMark(cellIndex: currentPageIndex)
                    self?.indicator.text = self?.buildIndicatorText(currentIndex: newValue ?? -1)
                }
            })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.config.style == MPStyle.BOTTOM_DYNAMIC_BAR {
            self.footerView.frame = CGRectMake(0, self.view.bounds.height - 48, self.view.bounds.width, 48)
            let footerHeight = footerView.frame.height
            self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - footerHeight)
            self.view.addSubview(footerView)
            self.footerView.setOkBtnHighlightColor(self.config.selectionEnabledColor)
            if let range = self.config.selectionRange {
                self.footerView.updateSelectionRange(range)
            }
            self.footerView.okBtn.addTarget(self, action: Selector("onTapDoneButton"), forControlEvents: UIControlEvents.TouchUpInside)
            self.footerView.updateSelectionCounter()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = true
        self.popGesture = navigationController?.interactivePopGestureRecognizer
        if self.popGesture != nil {
            self.navigationController?.view.removeGestureRecognizer(self.popGesture!)
        }
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: self.startCellIndex, inSection: 0), atScrollPosition: .None, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
        if self.popGesture != nil {
            self.navigationController?.view.addGestureRecognizer(popGesture!)
        }
        super.viewWillDisappear(animated)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("dcell", forIndexPath: indexPath) as! MPDetailViewCell
        
        let asset = self.assetsFetchResults![indexPath.item] as! PHAsset
        let options = PHImageRequestOptions()
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.FastFormat
        
        self.imageManager.requestImageForAsset(
            asset,
            targetSize: self.imageFetchSize,
            contentMode: PHImageContentMode.AspectFill,
            options: nil,
            resultHandler: { result, info in
                cell.imageView.image = result
            })
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.collectionView.didPageScrolled()
    }
    
    // MARK: - handlers
    
    @objc private func onTapDoneButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickedAssets(self, didFinishPickingAssets: MPCheckMarkStorage.sharedInstance.getCheckedAssets())
        }
    }
    
    @objc private func onTapBackBtn(button: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func onTapCheckMark(sender: UITapGestureRecognizer) {
        let cellIndex = self.collectionView.getCurrentPageIndex()
        var isSelectingNewItem: Bool = false
        if self.rowIndex != nil {
            isSelectingNewItem = self.isSelectingNewItem(self.rowIndex!, cellIndex: cellIndex)
        } else {
            isSelectingNewItem = self.isSelectingNewItem(cellIndex)
        }
        
        if self.isSelectedTooMany() && isSelectingNewItem {
            // Cannot select more, but we can undo selecting for selected items
        } else {
            let asset = self.assetsFetchResults![cellIndex] as! PHAsset
            if self.rowIndex != nil {
                if MPCheckMarkStorage.sharedInstance.removeIfAlreadyChecked(row: self.rowIndex!, cellIndex: cellIndex, asset: asset) {
                    // already checked, remove it
                } else {
                    MPCheckMarkStorage.sharedInstance.addEntry(row: self.rowIndex!, cellIndex: cellIndex, asset: asset)
                }
            } else {
                if MPCheckMarkStorage.sharedInstance.removeIfAlreadyChecked(cellIndex: cellIndex, asset: asset) {
                    // already checked, remove it
                } else {
                    MPCheckMarkStorage.sharedInstance.addEntry(cellIndex: cellIndex, asset: asset)
                }
            }
        }
    }
    
    // MARK: - private funcs
    
    private func updateCheckMark(cellIndex cellIndex: Int) {
        if self.rowIndex != nil {
            self.checkMark.checked = MPCheckMarkStorage.sharedInstance.isEntryAlreadySelected(row: self.rowIndex!, cellIndex: cellIndex)
        } else {
            self.checkMark.checked = MPCheckMarkStorage.sharedInstance.isEntryAlreadySelected(cellIndex: cellIndex)
        }
    }
    
    private func buildIndicatorText(currentIndex currentIndex: Int) -> String {
        let total = self.assetsFetchResults?.count ?? 0
        return "\(currentIndex + 1) / \(total)"
    }
    
    private func isSelectingNewItem(cellIndex: Int) -> Bool {
        return !MPCheckMarkStorage.sharedInstance.isEntryAlreadySelected(cellIndex: cellIndex)
    }
    
    private func isSelectingNewItem(rowIndex: Int, cellIndex: Int) -> Bool {
        return !MPCheckMarkStorage.sharedInstance.isEntryAlreadySelected(row: rowIndex, cellIndex: cellIndex)
    }
    
    private func isSelectedTooMany() -> Bool {
        if let selectionRange = config.selectionRange {
            let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
            return counter >= selectionRange.1 ? true : false
        }
        return true
    }
}
