//
//  JobHistoryApi.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 07/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class JobHistoryApi : NSObject {
    
    
    func providerHome(params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String, _ jobRequestObject: [ProviderJobRequestVO?] , _ jobsObject : [ProviderJobRequestVO?], _ jobAcceptedObject : [ProviderJobRequestVO?]) -> Void))
    {
        
        print("URL: \(URLConfiguration.providerHome)")
        print("PAR: \(params)")
        
        Alamofire.request(URLConfiguration.providerHome, method: .post,parameters: params, encoding: URLEncoding.default, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                if let serverResponse = response.result.value
                {
                    print(serverResponse)
                    let swiftyJsonVar = JSON(serverResponse)
                    print(swiftyJsonVar)
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    let msg = swiftyJsonVar["message"].string
                    
                    
                    var jobsObject = [ProviderJobRequestVO]()
                    var jobRequest = [ProviderJobRequestVO]()
                    var jobAcceptedObject = [ProviderJobRequestVO]()
                    
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!, [],[],[])
                    }
                    else
                    {
                        if let requests = swiftyJsonVar["requests"].arrayObject as NSArray?
                        {
                            jobRequest.removeAll()
                            
                            for i in requests
                            {
                                jobRequest.append(ProviderJobRequestVO(withJSON: i as! NSDictionary))
                                
                            }
                        }
                        
                        if let quotations = swiftyJsonVar["quotations"].arrayObject as NSArray?
                        {
                            print(quotations)
                        }
                        
                        if let accepted = swiftyJsonVar["accepted"].arrayObject as NSArray?
                        {
                            jobAcceptedObject.removeAll()
                            
                            for i in accepted {
                                jobAcceptedObject.append(ProviderJobRequestVO(withJSON: i as! NSDictionary))
                            }
                        }
                        
                        if let jobs = swiftyJsonVar["jobs"].arrayObject as NSArray?
                        {
                            jobsObject.removeAll()
                            
                            for i in jobs {
                                jobsObject.append(ProviderJobRequestVO(withJSON: i as! NSDictionary))
                            }
                        }
                        
                        completion(true, msg!, jobRequest, jobsObject, jobAcceptedObject)
                    }
                }
                else
                {
                    completion(false, "Could not obtain response from server", [],[],[])
                }
        }
    }
    
    func jobFeedback(jobID: String, params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        let jobURL = URLConfiguration.jobRatingURL //+ jobID
        print(jobURL)
        
        Alamofire.request(jobURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: URLConfiguration.headers())
            .responseJSON { response in
                print(response.result.debugDescription)
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    print(serverResponse)
                    
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
                    completion(false, "Could not obtain response from server")
                }
        }
    }
    
    func removeJobCommunication(messageID: String, params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        let jobURL = URLConfiguration.jobDeleteURL// + jobID
        
        print(jobURL)
        
        Alamofire.request(jobURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                print(response.result.value as Any)
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    print(swiftyJsonVar)
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["msg"].string
                        completion(false, msg!)
                    }
                    else
                    {
                        let msg = swiftyJsonVar["msg"].string
                        completion(true, msg!)
                    }
                }
                else
                {
                    completion(false, "Timed out Error.  We’re sorry we’re not able to fetch data at this time. Please try again.")
                }
        }
    }
}
