//
//  FALBackButton.swift
//  PopInNext
//
//  Created by Wang Zhenghong on 2015/12/22.
//
//

import Foundation

class FALBackButton: UIButton {
    
    var point1: CGPoint = CGPointZero
    var point2: CGPoint = CGPointZero
    var point3: CGPoint = CGPointZero
    
    override var frame: CGRect {
        didSet {
            self.setPoints()
        }
    }
    
    var lineColor: UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setPoints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let line = UIBezierPath()
        line.moveToPoint(point1)
        line.addLineToPoint(point2)
        line.addLineToPoint(point3)
        
        self.lineColor.setStroke()
        line.lineWidth = 2.5
        line.stroke()
    }
    
    private func setPoints() {
        let w = self.frame.width
        let h = self.frame.height
        self.point1 = CGPointMake(w * (14 + 3) / 28, h * 10 / 14)
        self.point2 = CGPointMake(w * (14 - 3) / 28, h * 7 / 14)
        self.point3 = CGPointMake(w * (14 + 3) / 28, h * 4 / 14)
    }
    
}