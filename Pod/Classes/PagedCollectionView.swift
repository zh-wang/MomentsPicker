//
//  PagedCollectionView.swift
//  Pods
//
//  Created by Wang Zhenghong on 2016/02/29.
//
//

import Foundation

class PagedCollectionView: UICollectionView {
    
    private var currentPageIndex: Int = 0
    
    var pageIndexObv: Observable<Int> = Observable<Int>(value: 0)
    
    func didPageScrolled() {
        let newPageIndex = Int((self.contentOffset.x + self.bounds.width/2) / self.bounds.width)
        if self.currentPageIndex != newPageIndex {
            self.currentPageIndex = newPageIndex
            self.pageIndexObv.updateValue(newPageIndex)
        }
    }
    
    func getCurrentPageIndex() -> Int {
        return self.currentPageIndex
    }
    
}