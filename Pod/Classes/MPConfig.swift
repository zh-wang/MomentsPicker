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

public enum MPStyle {
    case TOP_RIGHT_DONE         // default style
    case BOTTOM_DYNAMIC_BAR     // bottom bar with indicator & done button
}

public class MPConfig {

    public var needDetailViewController = true
    public var style: MPStyle = .TOP_RIGHT_DONE
    
    public var onlyIncludeStaticImage = true
    public var selectionRange: (Int, Int)? = nil
    public var staticFooterView: UIView? = nil // if style is BOTTOM_DYNAMIC_BAR, this will be ignored
    public var showSelectedCounterInTitle = true // if style is BOTTOM_DYNAMIC_BAR, this will be set to false
    public var startingContents = MPContentsType.AllPhotos
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
        
        if self.style == .BOTTOM_DYNAMIC_BAR {
            self.showSelectedCounterInTitle = false
        }
    }
    
}
