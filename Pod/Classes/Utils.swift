//
//  Utils.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/12/02.
//
//

import Foundation
import Photos

class MeasureUtils {
    class func widthForText(text:String, font:UIFont) -> CGFloat{
        return widthHeightForText(text, font: font).0
    }
    
    class func widthForText(text:String, fontSize:CGFloat) -> CGFloat{
        let font = UIFont.systemFontOfSize(fontSize)
        return widthHeightForText(text, font: font).0
    }
    
    class func widthHeightForText(text:String, font:UIFont) -> (CGFloat, CGFloat) {
        let attributes = [NSFontAttributeName: font]
        let rect = (text as NSString).boundingRectWithSize(CGSizeMake(0, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        return (rect.size.width, rect.size.height)
    }
}

extension Array {
    func each (blk: Element -> ()) {
        for object in self {
            blk(object)
        }
    }
}

extension String {
    func length() -> Int {
        return self.characters.count
    }
}

extension NSDate {
    func toLocalizedString(needDate needDate: Bool, needTime: Bool) -> String {
        let formatter = NSDateFormatter()
        if needDate { formatter.dateStyle = NSDateFormatterStyle.MediumStyle }
        if needTime { formatter.timeStyle = NSDateFormatterStyle.MediumStyle }
        return formatter.stringFromDate(self)
    }
    
    func toString() -> String {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(self)
    }
    
    func toString(format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}

extension UITableView {
    func scroll2Bottom(dataSource dataSource: [AnyObject], animated: Bool) {
        if dataSource.count == 0 {
            return
        }
        let path = NSIndexPath(forRow: dataSource.count - 1, inSection: 0)
        self.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Top, animated: animated)
    }
}

extension UICollectionView {
    func scroll2Bottom(dataSourceCount dataSourceCount: Int, animated: Bool) {
        if dataSourceCount == 0 {
            return
        }
        let path = NSIndexPath(forRow: dataSourceCount - 1, inSection: 0)
        self.scrollToItemAtIndexPath(path, atScrollPosition: UICollectionViewScrollPosition.Top, animated: animated)
    }
    
    func scroll2Bottom(dataSource dataSource: [AnyObject], animated: Bool) {
        if dataSource.count == 0 {
            return
        }
        let path = NSIndexPath(forRow: dataSource.count - 1, inSection: 0)
        self.scrollToItemAtIndexPath(path, atScrollPosition: UICollectionViewScrollPosition.Top, animated: animated)
    }
}

public class Utils {
    
    public class func isPhotoAccessible() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized
    }
    
    public class func safetyPhotoPickerWrapper(allowBlock allowBlock: Void -> Void, notAllowBlock: Void -> Void) {
        if isPhotoAccessible() {
            allowBlock()
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                dispatch_sync(dispatch_get_main_queue(), {
                    switch status {
                    case .Authorized:
                        allowBlock()
                    default:
                        notAllowBlock()
                    }
                })
            }
        }
    }
    
}