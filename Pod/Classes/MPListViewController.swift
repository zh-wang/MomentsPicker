//
//  MPListViewController.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/11/24.
//
//

import Foundation
import Photos

class MPListViewController: UITableViewController {
    
    var delegate: MPViewControllerDelegate?
    var config: MPConfig?
    
    var sectionTitles: [String] = []
    var sectionFetchResults: [PHFetchResult] = []
    
    override func loadView() {
        super.loadView()
        
        MPCheckMarkStorage.sharedInstance.clear()
        
        self.tableView.registerClass(MPListViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let allPhotos = PHAsset.fetchAssetsWithOptions(allPhotosOptions)
        
        let moments = PHAssetCollection.fetchMomentsWithOptions(nil)
//        let moments = PHCollectionList.fetchMomentListsWithSubtype(PHCollectionListSubtype.MomentListCluster, options: nil) // -> PHMomentList: PHCollectionList
        
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.AlbumRegular, options: nil)
        
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        
        self.sectionFetchResults.append(allPhotos)
        self.sectionFetchResults.append(moments)
        self.sectionFetchResults.append(smartAlbums)
        self.sectionFetchResults.append(topLevelUserCollections)
        
        self.sectionTitles.append(self.config?.categoryTitleAllPhotos ?? "All Photos")
        self.sectionTitles.append(self.config?.categoryTitleMoments ?? "Moments")
        self.sectionTitles.append(self.config?.categoryTitleSmartAlbums ?? "Smart Albums")
        self.sectionTitles.append(self.config?.categoryTitleUserAlbums ?? "User Albums")
        
        let cancelBtn = UIBarButtonItem(title: self.config?.barBtnTitleCancel ?? "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onTapCancelButton"))
        self.navigationItem.leftBarButtonItem = cancelBtn
        
        self.navigationItem.title = self.config?.viewControllerTitlePhotos ?? "Photos"
        
        if let config = config {
            switch config.startingContents {
            case .Moments:
                self.jump2MomentsList(moments, animated: false)
            case .AllPhotos:
                self.jump2AllPhotos(allPhotos, animated: false)
            default:
                return
            }
        }
    }
    
    override func viewDidLoad() {
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if section == 0 || section == 1 {
            numberOfRows = 1
        } else {
            let fetchResult = self.sectionFetchResults[section]
            numberOfRows = fetchResult.count
        }
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if indexPath.section == 0 {
            cell.textLabel!.text = self.config?.categoryTitleAllPhotos ?? "All Photos"
        } else if indexPath.section == 1 {
            cell.textLabel!.text = self.config?.categoryTitleMoments ?? "Moments"
            /*
            let fetchResult = self.sectionFetchResults[indexPath.section]
            let collection = fetchResult[indexPath.row]
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            
            print(collection)
            
//            cell.textLabel!.text = dateFormatter.stringFromDate(collection.localizedInfoDictionary)
            cell.textLabel!.text = collection.localizedTitle
            */
        } else {
            let fetchResult = self.sectionFetchResults[indexPath.section]
            let collection = fetchResult[indexPath.row]
            
            cell.textLabel!.text = collection.localizedTitle
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let fetchResult = self.sectionFetchResults[indexPath.section]
        
        MPCheckMarkStorage.sharedInstance.clear()
        
        if indexPath.section == 1 {
            self.jump2MomentsList(fetchResult, animated: true)
        } else {
            
            let assetGridViewController = MPAssetGridViewController()
            
            if indexPath.section == 0 {
                assetGridViewController.assetsFetchResults = fetchResult
                assetGridViewController.navigationItem.title = self.config?.viewControllerTitlePhotos ?? "Photos"
            } else {
                let collection = fetchResult[indexPath.row]
                let assetCollection = collection as! PHAssetCollection
                let assetFetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
                assetGridViewController.navigationItem.title = collection.localizedTitle
                assetGridViewController.assetCollection = assetCollection
                assetGridViewController.assetsFetchResults = assetFetchResult
            }
            
            assetGridViewController.delegate = self.delegate
            assetGridViewController.config = self.config
            assetGridViewController.prepareData()
            
            self.navigationController?.pushViewController(assetGridViewController, animated: true)
        }
        
    }
    
    // MARK: - touch event handler
    func onTapCancelButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.delegate {
            delegate.pickCancelled(self)
        }
    }
    
    // MARK: - private methods
    func jump2MomentsList(fetchResult: PHFetchResult, animated: Bool) {
        let momentsListViewController = MPMomentsListViewController()
        momentsListViewController.delegate = self.delegate
        momentsListViewController.config = self.config
        momentsListViewController.prepareData(fetchResult)
        momentsListViewController.title = self.config?.viewControllerTitleMoments ?? "Moments"
        self.navigationController?.pushViewController(momentsListViewController, animated: animated)
    }
    
    func jump2AllPhotos(fetchResult: PHFetchResult, animated: Bool) {
        let assetGridViewController = MPAssetGridViewController()
        assetGridViewController.assetsFetchResults = fetchResult
        assetGridViewController.navigationItem.title = self.config?.viewControllerTitlePhotos ?? "Photos"
        assetGridViewController.delegate = self.delegate
        assetGridViewController.config = self.config
        assetGridViewController.prepareData()
        self.navigationController?.pushViewController(assetGridViewController, animated: animated)
    }
}