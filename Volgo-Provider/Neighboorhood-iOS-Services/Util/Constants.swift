//
//  Constants.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 15/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Alamofire

let kResultIsValid : String = "Valid Result"

struct URLConfiguration
{
    static let devMode = true
    
    //static let devServerUrl = "http://172.99.75.33:3001" // Volgo Dev
//    static let devServerUrl = "http://157.230.41.251:3001"
    static let devServerUrl = "http://178.128.26.125:3001"
    static let prodServerUrl = "http://104.130.11.85"   // Volgo live
    
    static let ServerUrl : String = {
        
        if (URLConfiguration.devMode == true)
        {
            print(" \n\n\n #@$@#$@#$@#$@#$@#$@$   CHANGE TO PRODUCTION BEFORE RELEASE #@$@#$@#$@#$@#$@#$@$\n\n")
            print("  #@$@#$@#$@#$@#$@#$@$   CHANGE TO PRODUCTION BEFORE RELEASE #@$@#$@#$@#$@#$@#$@$")
            print("  #@$@#$@#$@#$@#$@#$@$   CHANGE TO PRODUCTION BEFORE RELEASE #@$@#$@#$@#$@#$@#$@$")
            print("  #@$@#$@#$@#$@#$@#$@$   CHANGE TO PRODUCTION BEFORE RELEASE #@$@#$@#$@#$@#$@#$@$ \n\n")
            return URLConfiguration.devServerUrl
        }
        else
        {
            return URLConfiguration.prodServerUrl
        }
    }()

    static func headers() -> HTTPHeaders {
        let user = AppUser.getUser()
        
        print(String(describing: user?.token ?? ""))
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "bearer" + " " + "\(String(describing: user?.token ?? ""))"
        ]
        return headers
    }
    
    static func headersContentType() -> HTTPHeaders {
        let user = AppUser.getUser()
        let headers: HTTPHeaders = [
           "Content-Type" : "application/x-www-form-urlencoded"
        ]
        return headers
    }

    static func headersAuth() -> HTTPHeaders {
        let user = AppUser.getUser()
        let headers: HTTPHeaders = [
            "Authorization" : "bearer" + " " + "\(String(describing: user?.token ?? ""))"
            //"Authorization" : "JWT" + " " + ""
        ]
        return headers
    }
    
    static let googleAPIKey = "AIzaSyC4JOqbEZ1YzrUrH5dePNC-gtZY4EzdQbo"
//    AIzaSyC4JOqbEZ1YzrUrH5dePNC-gtZY4EzdQbo
    static let loginURL = serverURL + "/api/providers/signin" 
    static let signUpURL = serverURL + "/api/auth/provider"
    static let isEmailExistURL = serverURL + "/api/providers/email/"
    static let getProviderListURL = serverURL + ""
    static let forgotPasswordURL = serverURL + "/api/auth/forgot"
    static let changePasswordURL = serverURL + "/api/users/password"
    static let updateProfileURL = serverURL + "/api/users"
    static let userProfileURL = serverURL + "/api/clients/profile/"
    static let reportURL = serverURL + "/api/users/report"
    static let uploadMessageMedia = serverURL + "/api/users/file/"
    static let updateFirebaseToken = serverURL + "/api/users/update/token"
    static let documentsURL = serverURL + "/api/users/documents"
    
    
    // provider apis
    static let providerHome = serverURL + "/api/providers/home"
    static let providerJobDetail = serverURL + "/api/jobs/"
    static let providerQuote = serverURL + "/api/requests/"
    static let providerjobStatusURL = serverURL + "/api/jobs/status/"
    static let updateProfileImage = serverURL + "/api/users/picture"
    static let providerUserStatusURL = serverURL + "/api/status/provider/"
    
    static let jobRatingURL = serverURL + "/api/users/rating/"
    
    
    static let jobHistoryURL = serverURL + "/api/jobs"
    static let categoryListURL = serverURL + "/api/categories"
    static let createJobURL = serverURL + "/api/jobs"
    static let nearbyProviderURL = serverURL + "/api/providers/near/"
    static let requestInvitationURL = serverURL + "/api/jobs/"
    static let jobDeleteURL = serverURL + "/api/jobs/delete/chat"
    static let requestInvitationJobDetailURL = serverURL + "/api/requests/"
    
    
    // old one
    static let handymanNearbyURL = serverURL + "/api/handymans/nearby"
    static let jobDetailURL = serverURL + "/api/handymans/"
    //static let jobHistoryURL = serverURL + "/api/handymans"
    static let currentJobsURL = serverURL + "/api/handymans/current"
    static let addQuotationURL = serverURL + "/api/quotations"
    static let proposedJobURL = serverURL + "/api/quotations"
    static let jobQuotationDetailURL = serverURL + "/api/quotations/"
    static let requestJobDetailURL = serverURL + "/api/requests/"
}

extension UIButton {
    
    static func makeCornerRadius(button: UIButton) -> UIButton {
        let btn = button
        btn.layer.cornerRadius = btn.frame.height/2
        return btn
    }
}

extension UIStoryboard {
    
    static func main() -> UIStoryboard
    {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static func login() -> UIStoryboard
    {
        return UIStoryboard(name: "Login", bundle: nil)
    }
}

extension UIViewController
{
    func showInfoAlertWith(title : String, message : String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showInfoAlert(title titleIn:String?, message messageIn:String?, handler: (() -> Void)?){
        
        let alert=UIAlertController(title:titleIn, message:messageIn, preferredStyle: .alert);
        let alertActionOk = UIAlertAction(title:"Ok", style: .default, handler: { (UIAlertAction) in
            
            if handler != nil
            {
                handler!()
            }
        })
        alert.addAction(alertActionOk)
        present(alert, animated: true, completion: nil)
    }
}

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        if let swRevealController = controller as? SWRevealViewController
        {
            return topViewController(controller: swRevealController.frontViewController)
        }
        return controller
    }
    
}

extension String
{
    func isValidEmail() -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func trimmed() -> String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func length() -> Int
    {
        return self.characters.count
    }
}

extension UIImage {
    
    func isEqualToImage(image: UIImage) -> Bool {
        let data1: NSData = self.pngData()! as NSData
        let data2: NSData = image.pngData()! as NSData
        return data1.isEqual(data2)
    }
    
}

func showProgressHud(viewController: UIViewController) {
//    MBProgressHUD.showAdded(to: viewController.view, animated: true)
    SVProgressHUD.show()
}

func hideProgressHud(viewController: UIViewController) {
//    MBProgressHUD.hide(for: viewController.view, animated: true)
    SVProgressHUD.dismiss()
}

func validatePhoneNumber(value: String) -> Bool {
    let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
    let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
    let result =  phoneTest.evaluate(with: value)
    return result
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

func setImageWithUrl(url: String) -> Data? {
    
    var newStr = url
    
    if newStr.first == "." {
        newStr.remove(at: (newStr.startIndex))
    }
    
    
    let imageURl = URLConfiguration.ServerUrl + newStr
    print(imageURl)
    if let data = try? Data(contentsOf: URL(string: imageURl)!)
    {
        return data
    }
 
    return nil
}

public func addButtonShadow(button : UIButton) -> UIButton {
    
    //    button.layer.shadowColor = UIColor(red: 200/255, green: 228/255, blue: 228/255, alpha: 1).cgColor
    button.layer.shadowColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
    
    button.layer.shadowOpacity = 1
    button.layer.shadowOffset = CGSize(width: 2, height: 2)
    button.layer.shadowRadius = 5
    //button.layer.shadowPath = UIBezierPath(roundedRect: (button.bounds), cornerRadius: button.frame.height/2).cgPath
    button.layer.masksToBounds = false
    return button
}

public func addViewShadow(view : UIView) -> UIView {
    
    //    button.layer.shadowColor = UIColor(red: 200/255, green: 228/255, blue: 228/255, alpha: 1).cgColor
    view.layer.shadowColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
    
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = CGSize(width: 2, height: 2)
    view.layer.shadowRadius = 5
    //button.layer.shadowPath = UIBezierPath(roundedRect: (button.bounds), cornerRadius: button.frame.height/2).cgPath
    view.layer.masksToBounds = false
    return view
}

enum JobStatus : String {
     
    
    case invite = "invite"
    case invited = "invited"
    
    
    case arrounded = "arrounded"
    case quoted    = "quoted"
    case onway     = "onway"
    case arrived   = "arrived"
    
    case hired     = "hired"
    case accepted  = "accepted"
    case started   = "started"
    case completed = "completed"
    case done      = "done"
    case cancelled = "cancelled"
    
}

