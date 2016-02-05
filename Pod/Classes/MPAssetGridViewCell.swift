//
//  MPGridViewCell.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/11/24.
//
//

import Foundation

class MPAssetGridViewCell: UICollectionViewCell {
    
    var checkMark: MPCheckMarkView = MPCheckMarkView(frame: CGRectMake(0, 0, 0, 0))
    var imageView: UIImageView = UIImageView(frame: CGRectMake(0, 0, 0, 0))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if self.imageView.isDescendantOfView(self) {
            // Do nothing
        } else {
            let imageViewFrame = CGRectMake(0, 0, frame.width, frame.height)
            self.imageView.frame = imageViewFrame
            self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            self.imageView.clipsToBounds = true
            self.contentView.addSubview(imageView)
            
            let checkMarkFrame = CGRectMake(4, 4, frame.width / 4, frame.width / 4)
            self.checkMark.frame = checkMarkFrame
            self.checkMark.checked = false
            self.checkMark.checkMarkStyle = MPCheckMarkStyle.OpenCircle
            self.contentView.addSubview(checkMark)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}