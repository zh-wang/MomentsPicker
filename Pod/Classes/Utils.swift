//
//  Utils.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/12/02.
//
//

import Foundation

extension Array {
    func each (blk: Element -> ()) {
        for object in self {
            blk(object)
        }
    }
}

extension UITableView {
    func scroll2Bottom(dataSource dataSource: [AnyObject], animated: Bool) {
        if dataSource.count == 0 {
            return
        }
        let path = NSIndexPath(forRow: dataSource.count - 1, inSection: 0)
        self.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Top, animated: animated)
    }
}

extension UICollectionView {
    func scroll2Bottom(dataSourceCount dataSourceCount: Int, animated: Bool) {
        if dataSourceCount == 0 {
            return
        }
        let path = NSIndexPath(forRow: dataSourceCount - 1, inSection: 0)
        self.scrollToItemAtIndexPath(path, atScrollPosition: UICollectionViewScrollPosition.Top, animated: animated)
    }
    
    func scroll2Bottom(dataSource dataSource: [AnyObject], animated: Bool) {
        if dataSource.count == 0 {
            return
        }
        let path = NSIndexPath(forRow: dataSource.count - 1, inSection: 0)
        self.scrollToItemAtIndexPath(path, atScrollPosition: UICollectionViewScrollPosition.Top, animated: animated)
    }
}