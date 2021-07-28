//
//  NearbyProviderVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON

class NearbyProviderVO : NSObject {
    
    var _id : String!
    var displayName : String!
    var categories : String!
    var rating : Double!
    var hourlyRate : String!
    var request : String!
    var profileImageURL : String!
    
    var status : String!
    var requestID : String!
    var created : String!
    var jobID : String!
    var providerID : String!
    var type : String!
    var rate : Int!
    var proposal : String!
    
    
    
    override init()
    {
        super.init()
        _id = ""
        displayName = ""
        categories = ""
        rating = 0.0
        hourlyRate = ""
        request = ""
        profileImageURL = ""
        
        status = ""
        requestID = ""
        created = ""
        jobID = ""
        providerID = ""
        type = ""
        rate = 0
        proposal = ""
    }
    
    public init(withJSON json: NSDictionary) {
        
        let obj = JSON(json)
        print(obj)
        
        self._id = obj["_id"].stringValue
        self.displayName = obj["displayName"].stringValue
        self.categories = obj["categories"].stringValue
        self.hourlyRate = obj["hourlyRate"].stringValue
        self.profileImageURL = obj["profileImageURL"].stringValue
        
        if let requestt = obj["request"].dictionary {
            
            self.status = requestt["status"]?.stringValue
            self.requestID = requestt["_id"]?.stringValue
            self.created = requestt["created"]?.stringValue
            self.jobID = requestt["job"]?.stringValue
            self.providerID = requestt["provider"]?.stringValue
            self.type = requestt["type"]?.stringValue
            self.rate = requestt["rate"]?.intValue
            self.proposal = requestt["proposal"]?.stringValue
            
        }  else {
            self.status = "none"
            self.request = obj["request"].stringValue
        }
        
        
        
    }
    
}
