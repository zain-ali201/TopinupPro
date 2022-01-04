//
//  UserApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD

class UserApi : NSObject {
    
    
    func resize(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
        let destImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage!
    }
    
    func loginUserWith(params : [String : Any], completion: @escaping ((_ success: Bool, _ message : String, _ userObj: UserVO?) -> Void))
    {
        
        print(URLConfiguration.loginURL)
        Alamofire.request(URLConfiguration.loginURL, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                
            if let serverResponse = response.result.value
            {
                let swiftyJsonVar = JSON(serverResponse)
                let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                if (!isSuccessful)
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!, nil)
                }
                else
                {
                    if let usr = swiftyJsonVar["user"].dictionaryObject as? NSDictionary
                    {
                        var user = UserVO()
                        
                        print(usr)
                        if let token = swiftyJsonVar["token"].string {
                            let tokenDict:NSMutableDictionary = ["token":token]
                            tokenDict.addEntries(from: usr as! [AnyHashable : Any])
                            user = UserVO(withJSON: tokenDict)
                            completion(true, "", user)
                            
                        }
                        else
                        {
                            completion(false, "Token not received in login response", user)
                        }
                    }
                }
            }
            else
            {
                completion(false, "Could not obtain response from server", nil)
            }
        }
    }
    
    func isEmailAlreadyUsed(userEmail : String, completion: @escaping ((_ emailAvailable: Bool, _ message : String) -> Void))
    {
        let urlString = URLConfiguration.isEmailExistURL + userEmail
        
        Alamofire.request(urlString).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                if (isSuccessful)
                {
                    completion(true, "")
                }
                else
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!)
                }
            }
            else
            {
                completion(false, "Unable to retrieve response from server. Please try later")
            }
        }
    }
    
    func sendRateRequest(providerID : String, clientID : String, completion: @escaping ((_ emailAvailable: Bool, _ message : String) -> Void))
    {
        let urlString = "\(URLConfiguration.rateProvider)\(providerID)/ask-to-rate/\(clientID)"
        print(urlString)
        Alamofire.request(urlString).responseJSON { response in
            print(response.result as Any)   // result of response serialization
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["status"].string
                if isSuccessful == "success"
                {
                    completion(true, "success")
                }
                else
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg ?? "Please try again later.")
                }
            }
            else
            {
                completion(false, "Unable to retrieve response from server. Please try later")
            }
        }
    }
    
    func forgotPasswordOf(email : String, completion: @escaping ((_ emailAvailable: Bool, _ message : String) -> Void))
    {
        let params = ["usernameOrEmail" : email]
        
        Alamofire.request(URLConfiguration.forgotPasswordURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                let msg = swiftyJsonVar["message"].string
                
                completion(isSuccessful, msg!)
            }
            else
            {
                completion(false, "Unable to retrieve response from server. Please try later")
            }
        }
    }
    
    func providerList(completion: @escaping ((_ success: Bool, _ message : String, _ list : [String]) -> Void))
    {
        Alamofire.request(URLConfiguration.getProviderListURL).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                if (isSuccessful)
                {
                    let providerList = [String]()
                    
                    
                    
                    completion(true, "",providerList)
                }
                else
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!,[])
                }
            }
            else
            {
                completion(false, "Unable to retrieve response from server. Please try later",[])
            }
        }
    }
    
    func signUpUser(with params : [String : Any]!, profileImage : [UIImage],completion: @escaping ((_ success: Bool, _ message : String, _ userObj: UserVO?) -> Void))
    {
        Alamofire.upload( multipartFormData: { MultipartFormData in
            
            
            
            for (key, value) in params {
                
                if key == "categories"
                {
                    if let jsonObject = value as? [String]
                    {
                        for i in (jsonObject as? [String])!
                        {
                            MultipartFormData.append(((i) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key )
                        }
                    }
                }
                else
                {
                    MultipartFormData.append(((value) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String)
                }
            }
            
            for i in profileImage {
                
                
                
                let image = self.resize(image: i, toSize: CGSize(width: 200.0, height: 200.0))
                
                
                let timestamp = NSDate().timeIntervalSince1970
                MultipartFormData.append(image.pngData() ?? Data(), withName: "newProfilePicture", fileName: "\(timestamp).png", mimeType: "image/png")
                
            }
            
        }, to: URLConfiguration.signUpURL) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    print(response.result.value as Any)
                    
                    let swiftyJsonVar = JSON(response.result.value!)
                    print(swiftyJsonVar)
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!, nil)
                    }
                    else
                    {
                        if let usr = swiftyJsonVar["user"].dictionaryObject as? NSDictionary
                        {
                            var user = UserVO()
                            if let token = swiftyJsonVar["token"].string {
                                let tokenDict:NSMutableDictionary = ["token":token]
                                tokenDict.addEntries(from: usr as! [AnyHashable : Any])
                                user = UserVO(withJSON: tokenDict)
                            }
                            completion(true, "", user)
                        }
                    }
                }
                
                break
                
            case .failure(let encodingError):
                print(encodingError)
                completion(false, encodingError as! String, nil)
                break
                
            }
        }
    }
    
    func changePassword(params : [String : Any], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        Alamofire.request(URLConfiguration.changePasswordURL, method: .post,parameters: params, encoding: URLEncoding.httpBody, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                print(params)
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!)
                    }
                    else
                    {
                        completion(true, "")
                    }
                }
                else
                {
                    completion(false, "Could not obtain response from server")
                }
        }
    }
    
    func updateProfile(params : [String : Any], completion: @escaping ((_ success: Bool, _ message : String, _ userObj: UserVO?) -> Void))
    {
        
        Alamofire.request(URLConfiguration.updateProfileURL, method: .put, parameters: params, encoding: URLEncoding.httpBody, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    
                    
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!, nil)
                    }
                    else
                    {
                        if let usr = swiftyJsonVar["user"].dictionaryObject as NSDictionary?
                        {
                            var user = UserVO()
                            
                            print(usr)
                            if let token = swiftyJsonVar["token"].string {
                                let tokenDict:NSMutableDictionary = ["token":token]
                                tokenDict.addEntries(from: usr as! [AnyHashable : Any])
                                user = UserVO(withJSON: tokenDict)
                                completion(true, "", user)
                                
                            }
                            else
                            {
                                if let usrrr = AppUser.getUser() {
                                    
                                    var tokenDict:NSMutableDictionary = ["token":usrrr.token!]
                                    tokenDict.addEntries(from: usr as! [AnyHashable : Any])
                                    user = UserVO(withJSON: tokenDict)
                                    completion(true, "", user)
                                    return;
                                }
                                
                                
                                completion(false, "Token not received in login response", user)
                            }
                        }
                    }
                }
                    
                else
                {
                    completion(false, "Could not obtain response from server", nil)
                }
        }
    }
    
    func changeProfileImage(image : UIImage , completion : @escaping ( _ suc : Bool , _ msg : String , _ url : String) -> Void)
    {
        
        let avatarImage = self.resize(image: image, toSize: CGSize(width: 200.0, height: 200.0))
        Alamofire.upload(multipartFormData: { (multiFormData) in
            //
            multiFormData.append(avatarImage.pngData()!, withName: "newProfilePicture", fileName: "newProfilePicture", mimeType: "image/png")
            
        }, usingThreshold: .max, to: URLConfiguration.updateProfileImage, method: .post, headers: URLConfiguration.headers()) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    //print(response.result.value as Any)
                    
                    
                    let swiftyJsonVar = JSON(response.result.value!)
                    print(swiftyJsonVar)
                    let msg = swiftyJsonVar["message"].string
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        
                        completion(false, msg! , "")
                        
                    }
                    else
                    {
                        print(swiftyJsonVar["user"]["profileImageURL"].string!)
                        let newImageUrl = swiftyJsonVar["user"]["profileImageURL"].string!
                        var imageURl = swiftyJsonVar["user"]["profileImageURL"].string!
                        print(imageURl)
                        imageURl.remove(at: (newImageUrl.startIndex))
                        let URl = URLConfiguration.ServerUrl + imageURl
                        
                        if let user = AppUser.getUser() {
                            user.profileImageURL = newImageUrl
                            AppUser.setUser(user: user)
                        }
                        
                        completion(true, msg!, URl)
                    }
                }
                
                break
                
            case .failure(let encodingError):
                print(encodingError)
                completion(false, encodingError as! String , "")
                break
                
            }
            
        }
    }
    
    func getSkillsList (completion : @escaping ( _ success : Bool , _ msg : String, _ skills : [JSON]?) -> Void)
    {
        //let user = AppUser.getUser()
        let urlString = URLConfiguration.ServerUrl + "/api/categories"
        //let headers: HTTPHeaders = ["Authorization" : "JWT " + (user?.token)!, "Accept": "application/json"]
        
        let headersWithContentType : HTTPHeaders = ["Content-Type" : "application/x-www-form-urlencoded"]
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headersWithContentType).responseJSON { (response) in
            
            print(response.debugDescription)
            if(response.result.value != nil)
            {
                let json = JSON(response.result.value)
                
                print("ResJSON = ", json)
                let suc = json["isSuccess"].boolValue
                let msg = json["message"].stringValue
                
                if suc
                {
                    let skills = json["categories"].array
                    completion(true, msg, skills)
                }
                else
                {
                    completion(false, msg, nil)
                }
            } else {
                completion(false, "Something went wrong", nil)
            }
        }
    }
    
    func updateFirebaseToken(params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        Alamofire.request(URLConfiguration.updateFirebaseToken, method: .post,parameters: params, encoding: URLEncoding.httpBody, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                print(params)
                if let serverResponse = response.result.value
                {
                    print(serverResponse)
                    let swiftyJsonVar = JSON(serverResponse)
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!)
                    }
                    else
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(true, msg!)
                    }
                }
                else
                {
                    completion(false, "Timed out Error.  We’re sorry we’re not able to fetch data at this time. Please try again.")
                }
        }
    }
    
    func fetchUserProfile(clientID : String, completion: @escaping ((_ success: Bool, _ message : String, _ userObj: UserVO?) -> Void))
    {
        
        Alamofire.request(URLConfiguration.userProfileURL + clientID, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                
                
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    
                    print(swiftyJsonVar)
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!, nil)
                    }
                    else
                    {
                        if let usr = swiftyJsonVar["client"].dictionaryObject as? NSDictionary
                        {
                            var user = UserVO()
                            
                            print(usr)
                            if let token = swiftyJsonVar["token"].string {
                                let tokenDict:NSMutableDictionary = ["token":token]
                                tokenDict.addEntries(from: usr as! [AnyHashable : Any])
                                user = UserVO(withJSON: tokenDict)
                                completion(true, "", user)
                                
                            }
                            else
                            {
                                if let usrrr = AppUser.getUser() {
                                    
                                    var tokenDict:NSMutableDictionary = ["token":usrrr.token!]
                                    tokenDict.addEntries(from: usr as! [AnyHashable : Any])
                                    user = UserVO(withJSON: tokenDict)
                                    completion(true, "", user)
                                    return;
                                }
                                
                                
                                completion(false, "Token not received in login response", user)
                            }
                        }
                    }
                }
                else
                {
                    completion(false, "Timed out Error.  We’re sorry we’re not able to fetch data at this time. Please try again.", nil)
                }
        }
    }
    
    func documentsWith(with params : [String : Any]!,detailImages : [UIImage], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        
        
        Alamofire.upload(multipartFormData: { MultipartFormData in
            
            print(params)
            
            for (key, value) in params {
                print(key)
                print(value)
                MultipartFormData.append(((value) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String)
            }
            
            
            for i in detailImages {
                
                let image = self.resize(image: i, toSize: CGSize(width: 200.0, height: 200.0))
                
                let timestamp = NSDate().timeIntervalSince1970
                
                MultipartFormData.append(image.pngData() ?? Data(), withName: "documents", fileName: "\(timestamp).png", mimeType: "image/png")
                
            }
            print(MultipartFormData)
            
        }, to: URLConfiguration.documentsURL, method: .post , headers: URLConfiguration.headersAuth())  { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    print(response.result.value as Any)
                    
                    if response == nil
                    {
                        return;
                    }
                    
                    let swiftyJsonVar = JSON(response.result.value!)
                    print(swiftyJsonVar)
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!)
                    }
                    else
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(true, msg!)
                    }
                }
                
                break
                
            case .failure(let encodingError):
                print(encodingError)
                completion(false, encodingError as! String)
                break
                
            }
        }
     }
    
}
