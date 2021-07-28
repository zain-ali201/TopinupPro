//
//  NearbyProviderApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class NearbyProviderApi : NSObject {
    
    
    func getNearbyProviderList(id : String , params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String, _ nearybyProviders : [NearbyProviderVO]?) -> Void))
    {
        
        let urlString = URLConfiguration.nearbyProviderURL + id
        
        Alamofire.request(urlString, method: .post,parameters: params, encoding: URLEncoding.httpBody, headers: URLConfiguration.headersContentType())
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
                        if let providers = swiftyJsonVar["providers"].arrayObject as NSArray?
                        {
                            var nearbyObject = [NearbyProviderVO]()
                            
                            for i in providers {
                                nearbyObject.append(NearbyProviderVO(withJSON: i as! NSDictionary))
                            }
                            completion(true, "", nearbyObject)
                            
                        }
                        else
                        {
                            completion(false, "Error occurred", [])
                        }
                    }
                }
                else
                {
                    completion(false, "Could not obtain response from server", nil)
                }
        }
    }
    
    func requestInvitation(id : String , params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        
        let urlString = URLConfiguration.requestInvitationURL + id
        
        Alamofire.request(urlString, method: .post,parameters: params, encoding: URLEncoding.httpBody, headers: URLConfiguration.headersContentType())
            .responseJSON { response in
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
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
                else
                {
                    completion(false, "Could not obtain response from server")
                }
        }
    }
    
    func requestInvitationJobDetail(id : String, completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        
        let urlString = URLConfiguration.requestInvitationJobDetailURL + id
        
        Alamofire.request(urlString, method: .get,parameters: nil, encoding: URLEncoding.httpBody, headers: URLConfiguration.headersContentType())
            .responseJSON { response in
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
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
                else
                {
                    completion(false, "Could not obtain response from server")
                }
        }
    }
    
}
