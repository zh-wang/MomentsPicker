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

    override func loadView() {
        super.loadView()
        
        self.tableView.frame = self.view.bounds
        self.tableView.registerClass(MPMomentsListViewCell.classForCoder(), forCellReuseIdentifier: "mcell")
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.allowsSelection = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        let doneBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onTapDoneButton"))
        self.navigationItem.rightBarButtonItem = doneBtn
    }
    
    override func viewDidLoad() {
        // Add footer view if needed
        if let footerView = self.config?.staticFooterView {
            let footerHeight = footerView.frame.height
            let bounds = UIScreen.mainScreen().bounds
            self.tableView.frame = CGRectMake(0, 0, bounds.width, bounds.height - footerHeight)
            
            let footerFrame = CGRectMake(0, bounds.height - footerHeight, bounds.width, footerHeight)
            footerView.frame = footerFrame
            self.view.addSubview(footerView)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.scroll2Bottom(dataSource: self.assetsFetchResultsOnlyImage, animated: false) // scroll to bottom
    }
    
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
        
        let collection = assetsFetchResults![indexPath.row]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        //        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        var collectionTitle = "No Name Group"
        if collection.localizedTitle != "" {
            collectionTitle = collection.localizedTitle!
        } else {
            if let sdate = collection.startDate as NSDate? {
                if let edate = collection.endDate as NSDate? {
                    collectionTitle = dateFormatter.stringFromDate(sdate) + " - " + dateFormatter.stringFromDate(edate)
                }
            }
        }
        cell.title.text = collectionTitle
        
        if let locationNames = collection.localizedLocationNames {
            let locationString = locationNames.joinWithSeparator(", ")
            cell.subtitle.text = locationString
        }
        
        cell.prepareData(self.assetsFetchResultsOnlyImage[indexPath.row], row: indexPath.row)
        cell.selectDelegate = self
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
    
    func onTapDoneButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickedAssets(self, didFinishPickingAssets: MPCheckMarkStorage.sharedInstance.getCheckedAssets())
        }
    }
    
    func isSelectionEnable(row row: Int, cellIndex: Int) -> Bool {
        // If already selected too many and want to select a new one, disallow
        return !(self.isSelectedTooMany() && isSelectingNewItem(row: row, cellIndex: cellIndex))
    }
    
    func didSelectImageInCell(row row: Int, cellIndex: Int) {
        self.changeTitleWhenSelected()
        self.toggleDoneAvailability()
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