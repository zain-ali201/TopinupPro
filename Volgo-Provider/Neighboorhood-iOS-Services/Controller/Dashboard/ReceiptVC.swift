//
//  ReceiptVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 21/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import Cosmos

class ReceiptVC: UIViewController {

    @IBOutlet weak var lblJobID: UILabel!
    @IBOutlet weak var lblJobType: UILabel!
    @IBOutlet weak var lblJobStatus: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var btnBackToHome: UIButton!
    
    @IBOutlet weak var viewBackgroundTimer: UIView!
    @IBOutlet weak var lblTotalTime: UILabel!
    //@IBOutlet weak var heightConstraintTotalTime: NSLayoutConstraint!
//    @IBOutlet weak var heightConstraintReceiptView: NSLayoutConstraint!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var commentFld: UITextField!
    @IBOutlet var remarksTV: UITextView!
    @IBOutlet var _jobType: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgPerson: UIImageView!
    
    var jobDetail : JobHistoryVO!
    var jobType : JobType!
    var totalTime = String()
    var rating : Double = 0.0
    var jobID = String()
    var totalAmount = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnBackToHome.layer.cornerRadius = self.btnBackToHome.frame.height/2
        ratingView.didFinishTouchingCosmos =  didReceiveRating
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.viewInitializer()
        viewSettingAboutJobType()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewSettingAboutJobType() {
        
        if jobType.rawValue == JobType.hourly.rawValue
        {
            self.viewBackgroundTimer.isHidden = true
            //self.heightConstraintTotalTime.constant = 140
//            self.heightConstraintReceiptView.constant = 400
        }
        else if jobType.rawValue == JobType.fixed.rawValue
        {
            self.viewBackgroundTimer.isHidden = true
            //self.heightConstraintTotalTime.constant = 0
//            self.heightConstraintReceiptView.constant = 250
        }
        
        self.view.layoutIfNeeded()
    }
    
    func viewInitializer()
    {
        self.remarksTV.layer.cornerRadius = 5.0
        self.remarksTV.layer.borderWidth = 1.0
        self.remarksTV.layer.borderColor = UIColor.lightGray.cgColor
        
        self.imgPerson.layer.cornerRadius = self.imgPerson.frame.size.height/2.0
        
        var newStr = self.jobDetail.profileImageURL! as String
        newStr.remove(at: (newStr.startIndex))
        let imageUrl = URLConfiguration.ServerUrl + newStr
        if let url = URL(string: imageUrl) {
            //cell.imgPerson.kf.setImage(with: url)
            self.imgPerson.kf.setImage(with: url, placeholder: UIImage(named: "imagePlaceholder"), options: nil, progressBlock: nil) { (image, error, cacheTyle, uurl) in
                //                    self.userBtn.setImage(image, for: .normal)
            }
        }
        
        self.lblName.text = self.jobDetail.displayName
        self.lblTotalTime.text = totalTime
        self._jobType.text = self.jobDetail.type.capitalized
        self.lblJobStatus.text = self.jobDetail.status.capitalized
        self.lblAddress.text = self.jobDetail.wheree
        self.lblTotalAmount.text = (self.jobDetail.currency) + " " + String(describing: self.jobDetail.budget!)
        
        if jobType.rawValue == JobType.hourly.rawValue
        {
            self.lblTotalAmount.text = (self.jobDetail.currency) + String(format: "%.2f", totalAmount)
        }
        else if jobType.rawValue == JobType.fixed.rawValue
        {
            self.lblTotalAmount.text = (self.jobDetail.currency) + String(describing: self.jobDetail.budget!)
        }
    }
    
    func callApiForFeedback()
    {
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = ["rating": self.rating, "details": remarksTV.text ?? "", "userId": AppUser.getUser()?._id ?? "", "jobId": self.jobDetail._id ?? ""] as [String:Any]
        print(params, self.jobDetail._id)
        showProgressHud(viewController: self)
        Api.jobHistoryApi.jobFeedback(jobID: self.jobDetail._id, params: params, completion: { (success : Bool, message : String) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: .gotoDashboardNotification, object: nil)
                }
            }
            else
            {
                self.showInfoAlertWith(title: "Alert", message: message)
                
            }
        })
    }
    
    
    func didReceiveRating(rating : Double)
    {
        print("Rating received is \(rating)")
        self.rating = rating
    }
    
    @IBAction func btnBackToHomeAction(_ sender: Any) {
        
        if rating == 0.0
        {
            showInfoAlertWith(title: "Information Required!", message: "Please rate your experience")
        }
        else
        {
            self.callApiForFeedback()
        }
    }
}
