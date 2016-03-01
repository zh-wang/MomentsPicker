//
//  MPMomentsListViewController.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/11/24.
//
//

import Foundation
import Photos

class MPMomentsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPMomentsListViewCellDelegate {
    
    var config: MPConfig?
    var delegate: MPViewControllerDelegate?
    
    var assetsFetchResults: PHFetchResult? = nil /* group of assets group, which may contains videos */
    var assetsFetchResultsOnlyImage: [PHFetchResult] = []
    
    var tableView: UITableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
    var footerView: DynamicBottomBar = DynamicBottomBar(frame: CGRectZero)
    
    override func loadView() {
        super.loadView()
        
        self.tableView.frame = self.view.bounds
        self.tableView.registerClass(MPMomentsListViewCell.classForCoder(), forCellReuseIdentifier: "mcell")
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.allowsSelection = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
//        let doneBtn = UIBarButtonItem(title: self.config?.barBtnTitleDone, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onTapDoneButton"))
//        self.navigationItem.rightBarButtonItem = doneBtn
        
        let cancelBtn = UIBarButtonItem(title: self.config?.barBtnTitleCancel, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onTapCancelButton"))
        self.navigationItem.rightBarButtonItem = cancelBtn
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add footer view if needed
//        if let footerView = self.config?.staticFooterView {
//            let footerHeight = footerView.frame.height
//            let bounds = UIScreen.mainScreen().bounds
//            self.tableView.frame = CGRectMake(0, 0, bounds.width, bounds.height - footerHeight)
//            
//            let footerFrame = CGRectMake(0, bounds.height - footerHeight, bounds.width, footerHeight)
//            footerView.frame = footerFrame
//            self.view.addSubview(footerView)
//        }
        
        self.footerView.frame = CGRectMake(0, self.view.bounds.height - 48, self.view.bounds.width, 48)
        let footerHeight = footerView.frame.height
        self.tableView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - footerHeight)
        self.view.addSubview(footerView)
        if let okBtnColor = self.config?.selectionEnabledColor {
            self.footerView.setOkBtnHighlightColor(okBtnColor)
        }

        // TODO
        if let range = self.config?.selectionRange {
            self.footerView.updateSelectionRange(range)
        }
        self.footerView.okBtn.addTarget(self, action: Selector("onTapDoneButton"), forControlEvents: UIControlEvents.TouchUpInside)
        
        if self.config?.startingPosition == .BOTTOM {
            self.tableView.scroll2Bottom(dataSource: self.assetsFetchResultsOnlyImage, animated: false) // scroll to bottom
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = false
        
        self.footerView.updateSelectionCounter()
        self.tableView.reloadData()
    }
    
    // MARK: - delegates
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let numberOfSubCollectionRows = (assetsFetchResultsOnlyImage[indexPath.row].count + NUMBER_OF_COLUMN_IN_SUB_COLLECTION - 1) / NUMBER_OF_COLUMN_IN_SUB_COLLECTION
        
        let totalLineSpacing = (numberOfSubCollectionRows - 0) * Int(LINE_HEIGHT_IN_SUB_COLLECTION)
        
        let width = floor(UIScreen.mainScreen().bounds.width / CGFloat(NUMBER_OF_COLUMN_IN_SUB_COLLECTION))
        
        let height =  CGFloat(totalLineSpacing + MOMENTS_LIST_CELL_TITLE_AREA_HEIGHT + Int(width) * numberOfSubCollectionRows)
        return height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assetsFetchResultsOnlyImage.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("mcell", forIndexPath: indexPath) as! MPMomentsListViewCell
        
        cell.title.text = ""
        cell.subtitle.text = ""
        cell.dateLabel.text = ""
        
        let collection = assetsFetchResults![indexPath.row]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        //        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        var collectionTitle = "No Name Group"
        if collection.localizedTitle != "" {
            collectionTitle = collection.localizedTitle!
            if let sdate = collection.startDate as NSDate? {
                cell.dateLabel.text = sdate.toLocalizedString(needDate: true, needTime: false)
            }
        } else {
            if let sdate = collection.startDate as NSDate? {
                if let edate = collection.endDate as NSDate? {
                    collectionTitle = sdate.toLocalizedString(needDate: true, needTime: false) + " - " + edate.toLocalizedString(needDate: true, needTime: false)
                }
            }
        }
        
        cell.title.text = collectionTitle
        
        if let locationNames = collection.localizedLocationNames {
            let locationString = locationNames.joinWithSeparator(", ")
            cell.subtitle.text = locationString
        }
        
        cell.prepareData(self.assetsFetchResultsOnlyImage[indexPath.row], row: indexPath.row)
        cell.cellDelegate = self
        cell.cellGrid!.reloadData()
        
        /*
        
        let fetchResult = PHAssetCollection.fetchMomentsInMomentList(collection as! PHCollectionList, options: nil)
//        print(fetchResult) // -> PHMoment: PHAssetCollection
        
        let n = fetchResult.count
        
        var res: [PHFetchResult] = []
        
        for i in 0..<n {
            let fetchResult2 = PHAsset.fetchAssetsInAssetCollection(fetchResult[i] as! PHAssetCollection, options: nil)
            res.append(fetchResult2)
            
        }
        
        cell.test = res

        */
        
        return cell
    }
    
    func onTapCancelButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickCancelled(self)
        }
    }
    
    /* delegate funcs of moments cell */
    
    func isSelectionEnable(row row: Int, cellIndex: Int, cell: MPMomentsListViewCell) -> Bool {
        // If already selected too many and want to select a new one, disallow
        return !(self.isSelectedTooMany() && isSelectingNewItem(row: row, cellIndex: cellIndex))
    }
    
    func didSelectImageInCell(row row: Int, cellIndex: Int, cell: MPMomentsListViewCell) {
        if (self.config?.needDetailViewController ?? true) {
            self.pushDetailViewController(cellIndex: cellIndex, row: row)
        } else {
            
            cell.updateCheckMarkInMomentsCell(cellIndex: cellIndex)
            
            self.changeTitleWhenSelected()
            
            let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
            self.footerView.updateSelectionCounter()
            
            if let delegate = self.delegate {
                delegate.didSelectionCounterChanged(self, counter: counter)
            }
        }
    }
    
    func didTapCheckMark(row row: Int, cellIndex: Int, cell: MPMomentsListViewCell) {
        
        cell.updateCheckMarkInMomentsCell(cellIndex: cellIndex)
        
        self.changeTitleWhenSelected()
        
        let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
        self.footerView.updateSelectionCounter()
        
        if let delegate = self.delegate {
            delegate.didSelectionCounterChanged(self, counter: counter)
        }
    }
    
    // MARK: - funcs
    
    func prepareData(asstesFetchResults: PHFetchResult) {
        self.assetsFetchResults = asstesFetchResults
        
        self.assetsFetchResultsOnlyImage = []
        
        for i in 0..<assetsFetchResults!.count {
            let assetCollection = self.assetsFetchResults![i]
            
            /* fetch image only */
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
            
            let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection as! PHAssetCollection, options: options)
            
            if fetchResult.count > 0 {
                assetsFetchResultsOnlyImage.append(fetchResult)
            }
        }
    }
    
    // MARK: - private funcs
    
    @objc private func onTapDoneButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickedAssets(self, didFinishPickingAssets: MPCheckMarkStorage.sharedInstance.getCheckedAssets())
        }
    }
    
    private func pushDetailViewController(cellIndex cellIndex: Int, row: Int) {
        let detailVC = MPDetailViewController()
        detailVC.config = self.config
        let assets = self.assetsFetchResultsOnlyImage[row]
        detailVC.rowIndex = row
        detailVC.startCellIndex = cellIndex
        detailVC.assetsFetchResults = assets
        detailVC.delegate = self.delegate
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func isSelectingNewItem(row row: Int, cellIndex: Int) -> Bool {
        return !MPCheckMarkStorage.sharedInstance.isEntryAlreadySelected(row: row, cellIndex: cellIndex)
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
