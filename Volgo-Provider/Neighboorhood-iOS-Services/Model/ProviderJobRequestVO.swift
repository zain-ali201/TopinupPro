//
//  ProviderJobRequestVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 02/04/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProviderJobRequestVO : NSObject {
    
    var _id : String!
    var status : String!
    var created : String!
    var when : String!
    var wheree : String!
    var clientID : String!
    var profileImageURL : String!
    var displayName : String!
    var categoryName : String = ""
    var requestID : String!
    
    
    override init()
    {
        super.init()
        _id = ""
        status = ""
        created = ""
        when = ""
        wheree = ""
        clientID = ""
        profileImageURL = ""
        displayName = ""
        
        
        
    }
    
    init(withJSON json: NSDictionary) {
        self.categoryName = json["categoryName"] as? String ?? ""
        print(json)
        let obj = JSON(json)
         
        if let job = obj["job"].dictionaryObject {
            
            self._id            = job["_id"] as? String
            self.status         = job["status"] as? String
            self.created        = job["created"] as? String
            self.when           = job["when"] as? String
            self.wheree         = job["where"] as? String
            self.categoryName   = job["categoryName"] as? String ?? ""
           
            
            
            
            if let client = job["client"] as? NSDictionary {
                
                self.clientID = client["_id"] as? String
                self.profileImageURL = client["profileImageURL"] as? String
                self.displayName = client["displayName"] as? String
            }
            
            if let request = obj["_id"].string {
                self.requestID = request
                
                ///nnn
                if job["status"] as! String == "arounded"
                {
                    self.status = "invited"
                }
            }
        }
        else
        {
            self._id = obj["_id"].stringValue
            self.status = obj["status"].stringValue
            self.created = obj["created"].stringValue
            self.when = obj["when"].stringValue
            self.wheree = obj["where"].stringValue
            
            
            
            if let client = obj["client"].dictionaryObject {
                
                self.clientID = client["_id"] as? String
                self.profileImageURL = client["profileImageURL"] as? String
                self.displayName = client["displayName"] as? String
            }else{
                self.clientID = ""
                self.profileImageURL = ""
                self.displayName = ""
            }
        }
    }
    
    init(requestID : String) {
        
        self.requestID = requestID
        return;
    }
}
