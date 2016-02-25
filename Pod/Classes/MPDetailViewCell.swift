//
//  MPDetailViewCell.swift
//  Pods
//
//  Created by Wang Zhenghong on 2016/02/24.
//
//

import Foundation

class MPDetailViewCell: UICollectionViewCell {
    
    var imageView: UIImageView = UIImageView(frame: CGRectZero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if self.imageView.isDescendantOfView(self) {
            
        } else {
            self.imageView.frame = self.bounds
            self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
            self.contentView.addSubview(self.imageView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
}