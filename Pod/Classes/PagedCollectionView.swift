//
//  PagedCollectionView.swift
//  Pods
//
//  Created by Wang Zhenghong on 2016/02/29.
//
//

import Foundation

protocol PagedCollectionViewDelegate {
    func didPageChanged(fromIndex fromIndex: Int, toIndex: Int)
}

class PagedCollectionView: UICollectionView {
    
    var pageDelegate: PagedCollectionViewDelegate?
    var currentPageIndex: Int = 0
    
    func didPageScrolled() {
        let newPageIndex = Int((self.contentOffset.x + self.bounds.width/2) / self.bounds.width)
        if self.currentPageIndex != newPageIndex {
            print("a: \(currentPageIndex) -> b: \(newPageIndex)")
            self.pageDelegate?.didPageChanged(fromIndex: self.currentPageIndex, toIndex: newPageIndex)
            self.currentPageIndex = newPageIndex
        }
    }
    
}