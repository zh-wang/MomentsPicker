//
//  Config.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/12/01.
//
//

import Foundation

public enum MPContentsType {
    case Category
    case Moments
    case AllPhotos
}

public class MPConfig {

    public var onlyIncludeStaticImage = true
    public var selectionRange: (Int, Int)? = nil
    public var staticFooterView: UIView? = nil
    public var showSelectedCounter = true
    public var startingContents = MPContentsType.Moments
    
    public init() {
        onlyIncludeStaticImage = true
    }
    
}
