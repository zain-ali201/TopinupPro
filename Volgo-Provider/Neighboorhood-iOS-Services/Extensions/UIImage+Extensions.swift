//
//  UIImage+Extensions.swift
//  Petbuds
//
//  Created by Sarim Ashfaq on 12/11/2018.
//  Copyright © 2018 ArhamSoft. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizedImage(newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizedImageWithAspectFit(newSize:CGSize) -> UIImage {
        // Resize with aspect
        var resizeFactor = size.width / newSize.width
        if size.height > size.width {
            // But if height is bigger
            resizeFactor = size.height / newSize.height
        }
        let newSizeFixedAspect = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSizeFixedAspect)
        return resized
    }
    
    
}

extension UIImagePickerController {
    open override var childForStatusBarHidden: UIViewController? {
        return nil
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension UIImageView {
    func imageTintColor(_ color: UIColor){
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}

@IBDesignable extension UIImageView {
    @IBInspectable var imageTintColor:UIColor {
        set {
            self.imageTintColor(newValue)
        }
        get {
            return self.tintColor
        }
    }
}
