//
//  MPMomentsListViewCellDelegate.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/12/14.
//
//

import Foundation

protocol MPMomentsListViewCellDelegate {
    func isSelectionEnable(row row: Int, cellIndex: Int, cell: MPMomentsListViewCell) -> Bool
    func didSelectImageInCell(row row: Int, cellIndex: Int, cell: MPMomentsListViewCell)
    func didTapCheckMark(row row: Int, cellIndex: Int, cell: MPMomentsListViewCell)
}
