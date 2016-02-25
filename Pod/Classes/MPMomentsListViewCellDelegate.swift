//
//  MPMomentsListViewCellDelegate.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/12/14.
//
//

import Foundation

protocol MPMomentsListViewCellDelegate {
    func isSelectionEnable(row row: Int, cellIndex: Int) -> Bool
    func didSelectImageInCell(row row: Int, cellIndex: Int)
    func didTapCheckMark(row row: Int, cellIndex: Int)
}