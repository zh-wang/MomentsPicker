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

public enum MPStartingPosition {
    case TOP
    case BOTTOM
}

public class MPConfig {

    public var onlyIncludeStaticImage = true
    public var selectionRange: (Int, Int)? = nil
    public var staticFooterView: UIView? = nil
    public var showSelectedCounter = true
    public var startingContents = MPContentsType.Moments
    public var startingPosition = MPStartingPosition.BOTTOM
    
    public var viewControllerTitlePhotos = "Photos"
    public var viewControllerTitleMoments = "Moments"
    public var barBtnTitleDone = "Done"
    public var barBtnTitleCancel = "Cancel"
    public var categoryTitleAllPhotos = "All Photos"
    public var categoryTitleMoments = "Moments"
    public var categoryTitleSmartAlbums = "Smart Albums"
    public var categoryTitleUserAlbums = "User Albums"
    public var selectedCounterText = "%d selected"
    public var selectionEnabledColor: UIColor = UIColor.cyanColor()
    
    public init() {
        onlyIncludeStaticImage = true
    }
    
    func safetyCheck() {
        assert(selectedCounterText.componentsSeparatedByString("%d").count == 2, "only one %d is expected")
    }
    
}
