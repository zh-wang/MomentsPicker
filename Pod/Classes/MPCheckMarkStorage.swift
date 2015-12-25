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
    
    private var checkedEntry: [(Int, Int, PHAsset)] = []
    
    func clear() {
        self.checkedEntry = []
    }
    
    func getSelectedCounter() -> Int {
        return self.checkedEntry.count
    }
    
    func addEntry(cellIndex cellIndex: Int, asset: PHAsset) {
        self.addEntry(row: -1, cellIndex: cellIndex, asset: asset)
    }
    
    func addEntry(row row: Int, cellIndex: Int, asset: PHAsset) {
        checkedEntry.append(row, cellIndex, asset)
    }
    
    func isEntryAlreadySelected(cellIndex cellIndex: Int) -> Bool {
        return self.isEntryAlreadySelected(row: -1, cellIndex: cellIndex)
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
        return self.removeIfAlreadyChecked(row: -1, cellIndex: cellIndex, asset: asset)
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
        return self.getCheckedCellIndexListInRow(-1)
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
    
}