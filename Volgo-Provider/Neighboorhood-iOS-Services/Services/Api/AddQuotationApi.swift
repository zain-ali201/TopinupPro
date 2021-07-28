//
//  AddQuotationApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AddQuotationApi : NSObject {

    func createQuotationWith(jobID : String , params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        
        let quoteURL = URLConfiguration.providerQuote + jobID
        
        Alamofire.request(quoteURL, method: .put,parameters: params, encoding: URLEncoding.default, headers: URLConfiguration.headers())
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
