//
//  CreateQuotationVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
var textViewQueryPlaceholder = "Write your proposal here..."

class CreateQuotationVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var viewRate: UIView!
    @IBOutlet weak var txtRate: UITextField!
    @IBOutlet weak var viewBackgroundProposal: UIView!
    @IBOutlet weak var txtViewProposal: UITextView!
    @IBOutlet weak var btnQuotation: UIButton!
    @IBOutlet weak var lblJobType: UILabel!
    
    var params : [String:Any]! = nil
    var jobID = String()
    var jobType = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewInitializer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewInitializer() {
        
        if jobType == "hourly"
        {
            self.lblJobType.text = "This is an hourly based job"
        }
        else
        {
            self.lblJobType.text = "This is a fixed budget job"
        }
        
        self.viewRate.layer.cornerRadius = self.viewRate.frame.height/2
        self.btnQuotation.layer.cornerRadius = self.btnQuotation.frame.height/2
        self.btnQuotation = addButtonShadow(button: self.btnQuotation)
        self.viewBackgroundProposal.layer.cornerRadius = 10
        txtViewProposal.text = textViewQueryPlaceholder
        txtViewProposal.textColor = UIColor.lightGray
        tapAnywhere()
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnQuotationAction(_ sender: Any) {
//        self.performSegue(withIdentifier: "startJobDetailSegue", sender: nil)
        
        self.callingApiCreateQuotation()
    }
    
    func callingApiCreateQuotation() {
        
        let validationResult = validateFields()
        if (validationResult == kResultIsValid)
        {
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            
            print("All data is valid \(jobID)")
        
            showProgressHud(viewController: self)
        
            Api.addQuotationApi.createQuotationWith(jobID : jobID, params: self.params, completion: { (success:Bool, message : String) in
            
                hideProgressHud(viewController: self)
            
                if success
                {
                    self.txtRate.text = ""
                    self.txtViewProposal.text = nil
                    
                    let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                    
                    let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                        
                        let _ = self.navigationController?.popToRootViewController(animated: true)
                        
                    })
                    
                    alertController.addAction(confirmAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                else
                {
                    self.showInfoAlertWith(title: "Error", message: message)
                }
            })
        }
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
    }
    
    func validateFields() -> String
    {
        var result = kResultIsValid
        
        let rate = txtRate.text?.trimmed()
        let proposal = txtViewProposal.text?.trimmed()
        
        if (rate?.length())! < 1
        {
            result = "Please enter a rate amount"
            return result
            
            
        }
        else if Double(txtRate.text!) == nil {
            result = "Please enter a valid rate amount"
            return result
        }
         
        
        else if proposal == textViewQueryPlaceholder {
            result = "Please write a proposal"
            return result
        }
        
        
        self.params = [
            "status" : "quoted",
            "rate" :  rate!,
            "proposal" : proposal!
        ]
        
        return result
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtViewProposal.textColor == UIColor.lightGray {
            txtViewProposal.text = nil
            txtViewProposal.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtViewProposal.text.isEmpty {
            txtViewProposal.text = textViewQueryPlaceholder
            txtViewProposal.textColor = UIColor.lightGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }
    
    func tapAnywhere() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateQuotationVC.endEditing))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func endEditing() {
        self.view.endEditing(true)
    }
    
 

}
