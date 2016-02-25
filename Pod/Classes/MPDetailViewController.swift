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
    UICollectionViewDataSource {
    
    var config: MPConfig?
    var imageFetchSize: CGSize = CGSizeZero
    
    var categoryName: String = ""
    
    var assetsFetchResults: PHFetchResult?
    var rowIndex: Int? = 0 // only useful if parent vc is not memory list
    var startCellIndex: Int = 0
    let imageManager: PHImageManager = PHImageManager()
    
    var collectionView: UICollectionView!
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
        layout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
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
        let recog = UITapGestureRecognizer(target: self, action: Selector("handleTapOnCheckMark:"))
        self.checkMark.addGestureRecognizer(recog)
        
        self.indicator.frame = CGRectMake(0, 4, self.view.bounds.width, 48)
        self.indicator.text = self.buildIndicatorText(currentIndex: self.startCellIndex)
        self.indicator.textColor = UIColor.blackColor()
        self.indicator.font = UIFont.systemFontOfSize(22)
        self.indicator.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.indicator)
        
        self.updateCheckMark()
        
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentIndex = self.getCurrentCellIndex()
        if currentIndex > 0 {
            self.indicator.text = self.buildIndicatorText(currentIndex: currentIndex)
        }
        
        self.updateCheckMark()
    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let currentIndex = self.getCurrentCellIndex()
//        if currentIndex > 0 {
//            self.indicator.text = self.buildIndicatorText(currentIndex: currentIndex)
//        }
//    }
    
    // MARK: - handlers
    
    @objc private func onTapBackBtn(button: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func handleTapOnCheckMark(sender: UITapGestureRecognizer) {
        if self.getCurrentCellIndex() < 0 { return }
        
        let cellIndex = self.getCurrentCellIndex()
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
        
        self.updateCheckMark()
    }
    
    // MARK: - private funcs
    
    private func updateCheckMark() {
        
        if self.getCurrentCellIndex() < 0 { return }
        
        let cellIndex = self.getCurrentCellIndex()
        
        if self.rowIndex != nil {
            self.checkMark.checked = MPCheckMarkStorage.sharedInstance.isEntryAlreadySelected(row: self.rowIndex!, cellIndex: cellIndex)
        } else {
            self.checkMark.checked = MPCheckMarkStorage.sharedInstance.isEntryAlreadySelected(cellIndex: cellIndex)
        }
    }
    
    private func getCurrentCellIndex() -> Int {
        if self.collectionView.indexPathsForVisibleItems().count > 0 {
            return self.collectionView.indexPathsForVisibleItems()[0].item
        }
        return self.startCellIndex
    }
    
    private func buildIndicatorText(currentIndex currentIndex: Int) -> String {
        let total = self.assetsFetchResults?.count ?? 0
        return "\(currentIndex) / \(total)"
    }
}