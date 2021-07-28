//
//  JobDetailImageView.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 28/10/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit

class JobDetailImageView: UIView {

    @IBOutlet weak var imgView: UIImageView!
    
    class func instanceFromNib() -> JobDetailImageView {
        return UINib(nibName: "JobDetailImagesView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! JobDetailImageView
    }
}
