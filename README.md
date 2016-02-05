# MomentsPicker

__iOS Moments-like image picking library__

[![CI Status](http://img.shields.io/travis/zh-wang/MomentsPicker.svg?style=flat)](https://travis-ci.org/zh-wang/MomentsPicker)
[![Version](https://img.shields.io/cocoapods/v/MomentsPicker.svg?style=flat)](http://cocoapods.org/pods/MomentsPicker)
[![License](https://img.shields.io/cocoapods/l/MomentsPicker.svg?style=flat)](http://cocoapods.org/pods/MomentsPicker)
[![Platform](https://img.shields.io/cocoapods/p/MomentsPicker.svg?style=flat)](http://cocoapods.org/pods/MomentsPicker)

![Sample Image](http://i.imgur.com/jskUS9P.png)

## Usage

This lib provides a moment-like style for picking multiple images from iOS device's gallery.  

Only support for picking static images. So GIFs or videos will be treated as static images.  

How to use  

    // ----------
    // Ask for photo access first
    Utils.safetyPhotoPickerWrapper(allowBlock: {
        // Use custom configurations here
        let config = MPConfig()
        config.selectionRange = (1, 2)
        config.showSelectedCounter = true
        config.startingContents = .Moments

        // Add a static foot view
        let label = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44))
        label.text = "Select 1 - 2 photos"
        label.textColor = UIColor.blackColor()
        label.backgroundColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Center
        config.staticFooterView = label

        self.presentViewController(MPRootViewController.newInstance(delegate: self, config: config), animated: true, completion: nil)

    }, notAllowBlock: {
        // Not allowed. Please Enable Photo Access in settings.
    })
    // ----------

Other configuration options(See `MPConfig.swift`)  

    // ---------- MPConfig.swift -----------
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

        // Configurations
        public var onlyIncludeStaticImage = true
        public var selectionRange: (Int, Int)? = nil
        public var staticFooterView: UIView? = nil
        public var showSelectedCounter = true
        public var startingContents = MPContentsType.Moments
        public var startingPosition = MPStartingPosition.BOTTOM

        // You can provide localizations text here
        public var viewControllerTitlePhotos = "Photos"
        public var viewControllerTitleMoments = "Moments"
        public var barBtnTitleDone = "Done"
        public var barBtnTitleCancel = "Cancel"
        public var categoryTitleAllPhotos = "All Photos"
        public var categoryTitleMoments = "Moments"
        public var categoryTitleSmartAlbums = "Smart Albums"
        public var categoryTitleUserAlbums = "User Albums"
        public var selectedCounterText = "%d selected"

        public init() {
            onlyIncludeStaticImage = true
        }

        func safetyCheck() {
            assert(selectedCounterText.componentsSeparatedByString("%d").count == 2, "only one %d is expected")
        }

    }

## Requirements

iOS 8.3  
Use `Photos` framework  

## Installation

MomentsPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MomentsPicker"
```

## Author

zh-wang, viennakanon@gmail.com

## License

MomentsPicker is available under the MIT license. See the LICENSE file for more info.
