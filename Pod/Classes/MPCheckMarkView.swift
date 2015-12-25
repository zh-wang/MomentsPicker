//
//  CheckMark.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/12/01.
//
//

import Foundation

enum MPCheckMarkStyle: Int {
    case OpenCircle = 1
    case GrayedOut = 2
}

class MPCheckMarkView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var checked = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var checkMarkStyle: MPCheckMarkStyle = .OpenCircle {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    func toggle() {
        if self.checked {
            self.checked = false
        } else {
            self.checked = true
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if self.checked {
            self.drawRectChecked(rect)
        } else {
            switch self.checkMarkStyle {
            case .OpenCircle:
                drawRectOpenCircle(rect)
            case .GrayedOut:
                drawRectGrayedOut(rect)
            }
        }
        
    }
    
    func drawRectChecked(rect: CGRect) {
        // General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        // Color Declarations
        let checkmarkBlue2 = UIColor(red: 0.078, green: 0.435, blue: 0.875, alpha: 1)

        //// Shadow Declarations
        let shadow2 = UIColor.blackColor()
        let shadow2Offset = CGSizeMake(0.1, -0.1)
        let shadow2BlurRadius: CGFloat = 2.5

        // Frames
        let frame = self.bounds

        // Subframes
        let group = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6)
        
        // CheckedOval Drawing
        let checkedOvalPath = UIBezierPath(ovalInRect:
            CGRectMake(CGRectGetMinX(group) + floor(CGRectGetWidth(group) * 0.00000 + 0.5), CGRectGetMinY(group) + floor(CGRectGetHeight(group) * 0.00000 + 0.5), floor(CGRectGetWidth(group) * 1.00000 + 0.5) - floor(CGRectGetWidth(group) * 0.00000 + 0.5), floor(CGRectGetHeight(group) * 1.00000 + 0.5) - floor(CGRectGetHeight(group) * 0.00000 + 0.5))
        )
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor)
        checkmarkBlue2.setFill()
        checkedOvalPath.fill()
        CGContextRestoreGState(context)

        UIColor.whiteColor().setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        // Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group)))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group)))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group)))
        bezierPath.lineCapStyle = CGLineCap.Square

        UIColor.whiteColor().setStroke()
        bezierPath.lineWidth = 1.3
        bezierPath.stroke()
        
    }
    
    func drawRectGrayedOut(rect: CGRect) {
        // General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        // Color Declarations
        let grayTranslucent = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        // Shadow Declarations
        let shadow2 = UIColor.blackColor()
        let shadow2Offset = CGSizeMake(0.1, -0.1)
        let shadow2BlurRadius: CGFloat = 2.5
        
        // Frames
        let frame = self.bounds
        
        // Subframes
        let group = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6)
        
        
        // UncheckedOval Drawing
        let uncheckedOvalPath = UIBezierPath(ovalInRect:
            CGRectMake(CGRectGetMinX(group) + floor(CGRectGetWidth(group) * 0.00000 + 0.5), CGRectGetMinY(group) + floor(CGRectGetHeight(group) * 0.00000 + 0.5), floor(CGRectGetWidth(group) * 1.00000 + 0.5) - floor(CGRectGetWidth(group) * 0.00000 + 0.5), floor(CGRectGetHeight(group) * 1.00000 + 0.5) - floor(CGRectGetHeight(group) * 0.00000 + 0.5))
        )
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor)
        grayTranslucent.setFill()
        uncheckedOvalPath.fill()
        CGContextRestoreGState(context)
            
        UIColor.whiteColor().setStroke()
        uncheckedOvalPath.lineWidth = 1
        uncheckedOvalPath.stroke()
        
        // Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group)))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group)))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group)))
        bezierPath.lineCapStyle = CGLineCap.Square
        
        UIColor.whiteColor().setStroke()
        bezierPath.lineWidth = 1.3
        bezierPath.stroke()
    }
    
    func drawRectOpenCircle(rect: CGRect) {
        // General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        // Shadow Declarations
        let shadow = UIColor.blackColor()
        let shadowOffset = CGSizeMake(0.1, -0.1)
        let shadowBlurRadius: CGFloat = 0.5
        let shadow2 = UIColor.blackColor()
        let shadow2Offset = CGSizeMake(0.1, -0.1)
        let shadow2BlurRadius: CGFloat = 2.5
        
        // Frames
        let frame = self.bounds
        
        // Subframes
        let group = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6)
        
        // EmptyOval Drawing
        let emptyOvalPath = UIBezierPath(ovalInRect: CGRectMake(CGRectGetMinX(group) + floor(CGRectGetWidth(group) * 0.00000 + 0.5), CGRectGetMinY(group) + floor(CGRectGetHeight(group) * 0.00000 + 0.5), floor(CGRectGetWidth(group) * 1.00000 + 0.5) - floor(CGRectGetWidth(group) * 0.00000 + 0.5), floor(CGRectGetHeight(group) * 1.00000 + 0.5) - floor(CGRectGetHeight(group) * 0.00000 + 0.5)))
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor)
        CGContextRestoreGState(context)
            
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor)
        UIColor.whiteColor().setStroke()
        emptyOvalPath.lineWidth = 1
        emptyOvalPath.stroke()
        CGContextRestoreGState(context)
    }
    
}