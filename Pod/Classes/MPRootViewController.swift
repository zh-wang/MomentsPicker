//
//  MPRootViewController.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/11/24.
//
//

import Foundation

public class MPRootViewController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public class func newInstance(delegate delegate: MPViewControllerDelegate, config: MPConfig) -> MPRootViewController {
        let tableViewController = MPListViewController(style: UITableViewStyle.Grouped)
        tableViewController.delegate = delegate
        tableViewController.config = config
        return MPRootViewController(rootViewController: tableViewController)
    }
    
}
