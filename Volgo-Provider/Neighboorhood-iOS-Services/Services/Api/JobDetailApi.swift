//
//  JobDetailApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class JobDetailApi : NSObject {
    
    
    func jobDetailWith(jobID : String, completion: @escaping ((_ success: Bool, _ message : String, _ jobDetail: JobHistoryVO?) -> Void))
    {
        print(jobID)
        let urlString = URLConfiguration.providerJobDetail + jobID
        
        Alamofire.request(urlString,method: .get, encoding: JSONEncoding.default, headers: URLConfiguration.headers()).responseJSON { response in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                if (isSuccessful)
                {
                    if let usr = swiftyJsonVar["job"].dictionaryObject as NSDictionary?
                    {
                        var jobDetail = JobHistoryVO()
                        jobDetail = JobHistoryVO(withJSON: usr)
                        completion(true, "", jobDetail)
                    }
                }
                else
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!,nil)
                }
            }
            else
            {
                completion(false, "Unable to retrieve response from server. Please try later",nil)
            }
        }
    }
    
    func jobHistoryWith(params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String, _ jobHistory: [JobHistoryVO]?) -> Void))
    {
       Alamofire.request(URLConfiguration.jobHistoryURL,method: .get, parameters: params,encoding: URLEncoding.default, headers: URLConfiguration.headersAuth()).responseJSON { response in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                if (isSuccessful)
                {
                    var jobHistoryObject = [JobHistoryVO]()
                    
                    if let jobs = swiftyJsonVar["jobs"].arrayObject as NSArray?
                    {
                        
                        for i in jobs
                        {
                            jobHistoryObject.append(JobHistoryVO(withJSON: i as! NSDictionary))
                        }
                        completion(true, "", jobHistoryObject)
                    }
                    
                    if let cancelled = swiftyJsonVar["cancelled"].arrayObject as NSArray?
                    {
                        
                        
                        for i in cancelled
                        {
                            jobHistoryObject.append(JobHistoryVO(withJSON: i as! NSDictionary))
                        }
                        completion(true, "", jobHistoryObject)
                    }
                    
                    if let completed = swiftyJsonVar["completed"].arrayObject as NSArray?
                    {
                        
                        
                        for i in completed
                        {
                            jobHistoryObject.append(JobHistoryVO(withJSON: i as! NSDictionary))
                        }
                        
                        completion(true, "", jobHistoryObject)
                    }
                    
                    
                    
                    
                    
                }
                else
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!,nil)
                }
            }
            else
            {
                completion(false, "Unable to retrieve response from server. Please try later",nil)
            }
        }
    }
    
    func currentJobsWith(completion: @escaping ((_ success: Bool, _ message : String, _ currentJobs: [HandymanNearbyVO]?) -> Void))
    {
        print("URLCurrentJobs: \(URLConfiguration.currentJobsURL)")
        
        Alamofire.request(URLConfiguration.currentJobsURL,method: .get, headers: URLConfiguration.headersAuth()).responseJSON { response in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["success"].boolValue
                if (isSuccessful)
                {
                    if let handyman = swiftyJsonVar["handymans"].arrayObject as NSArray?
                    {
                        var history = [HandymanNearbyVO]()
                        
                        for i in handyman {
                            history.append(HandymanNearbyVO(withJSON: i as! NSDictionary))
                        }
                        completion(true, "", history)
                        
                    }
                }
                else
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!,nil)
                }
            }
            else
            {
                completion(false, "Unable to retrieve response from server. Please try later",nil)
            }
        }
    }
    
    
    
}
