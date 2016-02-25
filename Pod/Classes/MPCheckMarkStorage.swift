//
//  MPCheckedStorage.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/12/02.
//
//

import Foundation
import Photos

class MPCheckMarkStorage {
    
    static let sharedInstance = MPCheckMarkStorage()
    
    /*
        Row Index, Cell Index, Asset
        if (Row Index) is not used, set to 0
    */
    private var checkedEntry: [(Int, Int, PHAsset)] = []
    
    func clear() {
        self.checkedEntry = []
    }
    
    func getSelectedCounter() -> Int {
        return self.checkedEntry.count
    }
    
    func addEntry(cellIndex cellIndex: Int, asset: PHAsset) {
        self.addEntry(row: 0, cellIndex: cellIndex, asset: asset)
    }
    
    func addEntry(row row: Int, cellIndex: Int, asset: PHAsset) {
        checkedEntry.append(row, cellIndex, asset)
    }
    
    func isEntryAlreadySelected(cellIndex cellIndex: Int) -> Bool {
        return self.isEntryAlreadySelected(row: 0, cellIndex: cellIndex)
    }
    
    func isEntryAlreadySelected(row row: Int, cellIndex: Int) -> Bool {
        for (r, c, _) in checkedEntry {
            if r == row && cellIndex == c {
                return true
            }
        }
        return false
    }
    
    func removeIfAlreadyChecked(cellIndex cellIndex: Int, asset: PHAsset) -> Bool {
        return self.removeIfAlreadyChecked(row: 0, cellIndex: cellIndex, asset: asset)
    }
    
    func removeIfAlreadyChecked(row row: Int, cellIndex: Int, asset: PHAsset) -> Bool {
        var index = 0
        for (r, c, _) in checkedEntry {
            if r == row && cellIndex == c {
                checkedEntry.removeAtIndex(index)
                return true
            }
            index++
        }
        return false
    }
    
    func getCheckedCellIndexList() -> [Int] {
        return self.getCheckedCellIndexListInRow(0)
    }
    
    func getCheckedRowIndexList() -> [Int] {
        var rowIndexes: [Int] = []
        for (r, _, _) in checkedEntry {
            if r >= 0 {
                rowIndexes.append(r)
            }
        }
        return rowIndexes
    }
    
    func getCheckedCellIndexListInRow(row: Int) -> [Int] {
        var result: [Int] = []
        checkedEntry.each { (r, c, asset) in
            if r == row {
                result.append(c)
            }
        }
        return result
    }
    
    func getCheckedAssets() -> [PHAsset] {
        var result: [PHAsset] = []
        for (_, _, asset) in checkedEntry {
            result.append(asset)
        }
        return result
    }
    
    func getAllCheckedIndexPaths() -> [NSIndexPath] {
        var paths: [NSIndexPath] = []
        let rowIndexes = self.getCheckedRowIndexList()
        for _rowIndex in rowIndexes {
            for _cellIndex in self.getCheckedCellIndexListInRow(_rowIndex) {
                paths.append(NSIndexPath(forItem: _cellIndex, inSection: _rowIndex))
            }
        }
        return paths
    }
}