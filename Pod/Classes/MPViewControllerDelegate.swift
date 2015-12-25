//
//  MPImagePickedDelegate.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/12/08.
//
//

import Foundation

public protocol MPViewControllerDelegate {
    func pickCancelled(picker: UIViewController!)
    func pickedAssets(picker: UIViewController!, didFinishPickingAssets assets: [AnyObject]!)
}
