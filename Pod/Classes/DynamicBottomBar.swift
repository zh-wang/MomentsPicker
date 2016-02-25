//
//  DynamicBottomBar.swift
//  Pods
//
//  Created by Wang Zhenghong on 2016/02/09.
//
//

import Foundation

class DynamicBottomBar: UIView {
    
    var label: UILabel = UILabel(frame: CGRectZero)
    var okBtn: UIButton = UIButton(frame: CGRectZero)
    var roundLabel: UILabel = UILabel(frame: CGRectZero)
    var selectionRange: (Int, Int)?
    
    override var frame: CGRect {
        didSet {
            self.buildLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.label)
        self.addSubview(self.okBtn)
        self.addSubview(self.roundLabel)
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.buildLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSelectionCounter() {
        let counter = MPCheckMarkStorage.sharedInstance.getSelectedCounter()
        self.updateSelectionCounter(counter)
    }
    
    func updateSelectionCounter(counter: Int) {
        self.roundLabel.text = "\(counter)"
        if let range = self.selectionRange {
            if counter <= range.1 && counter >= range.0 {
                self.okBtn.enabled = true
            } else {
                self.okBtn.enabled = false
            }
        }
    }
    
    func updateSelectionRange(range: (Int, Int)) {
        self.buildLayout(range)
    }
    
    func setOkBtnHighlightColor(color: UIColor) {
        self.okBtn.setBackgroundImage(imageWithColor(color), forState: UIControlState.Normal)
    }
    
    private func buildLayout(range: (Int, Int)? = nil) {
        
        self.selectionRange = range
        
        let labelWidth = self.bounds.width * 0.7
        let okBtnWidth = self.bounds.width - labelWidth
        
        self.label.frame = CGRectMake(0, 0, labelWidth, self.bounds.height)
        self.label.textColor = UIColor.blackColor()
        self.label.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        self.label.textAlignment = NSTextAlignment.Center
        self.label.font = UIFont.systemFontOfSize(16)
        
        if let range = range {
            if range.0 == range.1 {
                self.label.text = "\(range.0)枚選んでください"
            } else {
                self.label.text = "\(range.0)-\(range.1)枚選んでください"
            }
        } else {
            self.label.text = "写真を選んでください"
        }
        
        self.okBtn.frame = CGRectMake(self.label.frame.origin.x + self.label.frame.size.width, 0, okBtnWidth, self.bounds.height)
        self.okBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.okBtn.setTitle("完成", forState: UIControlState.Normal)
        self.okBtn.setBackgroundImage(imageWithColor(UIColor.grayColor()), forState: UIControlState.Disabled)
        self.okBtn.enabled = false
        
        self.roundLabel.frame = CGRectMake(self.label.frame.origin.x + self.label.frame.size.width + 4, (self.bounds.height - 22) / 2, 22, 22)
        self.roundLabel.textAlignment = NSTextAlignment.Center
        self.roundLabel.text = "0"
        self.roundLabel.font = UIFont.systemFontOfSize(15)
        self.roundLabel.textColor = UIColor.blackColor()
        self.roundLabel.userInteractionEnabled = false
        self.roundLabel.backgroundColor = UIColor.whiteColor()
        self.roundLabel.clipsToBounds = true
        self.roundLabel.layer.cornerRadius = max(self.roundLabel.frame.width / 2, self.roundLabel.frame.height / 2)
    }
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}