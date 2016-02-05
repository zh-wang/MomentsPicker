//
//  ViewController.swift
//  MomentsPicker
//
//  Created by zh-wang on 11/24/2015.
//  Copyright (c) 2015 zh-wang. All rights reserved.
//

import UIKit
import MomentsPicker
import Photos

class ViewController: UIViewController, MPViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let importBtn = UIButton(type: UIButtonType.RoundedRect)
        importBtn.frame = CGRectMake(self.view.frame.size.width / 2 - 50, self.view.frame.size.height / 2  - 50, 100, 100)
        importBtn.setTitle("import", forState: UIControlState.Normal)
        importBtn.addTarget(self, action: Selector("tapImportBtn"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(importBtn)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapImportBtn() {
        Utils.safetyPhotoPickerWrapper(allowBlock: {
                let config = MPConfig()
                config.selectionRange = (1, 2)
                config.showSelectedCounter = true
                
                let label = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44))
                label.text = "Select 1 - 2 photos"
                label.textColor = UIColor.blackColor()
                label.backgroundColor = UIColor.lightGrayColor()
                label.textAlignment = NSTextAlignment.Center
                config.staticFooterView = label
                config.startingContents = .Moments
                self.presentViewController(MPRootViewController.newInstance(delegate: self, config: config), animated: true, completion: nil)
            }, notAllowBlock: {
                // Not allowed. Please Enable Photo Access in settings.
            })
    }
    
    func pickCancelled(picker: UIViewController!) {
        print("cancel")
    }
    
    func pickedAssets(picker: UIViewController!, didFinishPickingAssets assets: [AnyObject]!) {
        print("pick")
        var imageList: [UIImage] = []
        var imageInfoList: [AnyObject] = []
        for obj in assets {
            if obj is PHAsset {
                let asset = obj as! PHAsset
                let phImgManager = PHImageManager()
                let options = PHImageRequestOptions()
                options.synchronous = true
                options.resizeMode = PHImageRequestOptionsResizeMode.Fast
                options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
                phImgManager.requestImageForAsset(asset,
                    targetSize: CGSize(width: 512, height: 512),
                    contentMode: .AspectFill,
                    options: options,
                    resultHandler: { maybeImage, maybeInfo in
                        if let image = maybeImage {
                            imageList.append(image)
                            imageInfoList.append(maybeInfo!)
                            print(maybeInfo)
                        }
                    }
                )
            }
        }
    }
    
    func didSelectionCounterChanged(picker: UIViewController!, counter: Int) {
        
    }
    
}

