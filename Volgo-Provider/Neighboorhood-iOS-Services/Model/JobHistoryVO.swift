//
//  JobHistoryVO.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 08/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class JobHistoryVO : NSObject {
    
    var _id : String!
    var wheree : String!
    var type : String!
    var budget : String!
    var latitude : Double!
    var longitude : Double!
    var category : String!
    var created : String!
    var images = [String]()
    var status : String!
    var details : String!
    var when : String!
    var name : String!
    var clientID : String!
    var providerID : String!
    var displayName : String!
    var profileImageURL : String!
    var categoryName : String!
    var categoryDescription : String!
    var categoryID : String!
    var categoryImageURL : String!
    var currency : String = ""
    var clientPhone : String?
    
    var coordinaate : CLLocationCoordinate2D? {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    override init()
    {
        super.init()
        _id = ""
        providerID = ""
        wheree = ""
        type = ""
        budget = ""
        created = ""
        clientID = ""
        category = ""
        displayName = ""
        details = ""
        when = ""
        latitude = 0
        longitude = 0
        status = ""
        profileImageURL = ""
        name = ""
        
        categoryName = ""
        categoryDescription = ""
        categoryID = ""
        categoryImageURL = ""
        clientPhone = ""
        
        images = [String]()
    }
    
    public init(withJSON json: NSDictionary) {
        let obj = JSON(json)
        print(obj)
        self._id = obj["_id"].stringValue
        
        if let client = obj["client"].dictionary
        {
            self.clientID = client["_id"]?.stringValue
            self.displayName = client["displayName"]?.stringValue
            self.profileImageURL = client["profileImageURL"]?.stringValue
            self.clientPhone = client["phone"]?.stringValue
        }
        
//        if let provider = obj["provider"].dictionary {
//            self.providerID = provider["_id"]?.stringValue
//            self.displayName = provider["displayName"]?.stringValue
//            self.profileImageURL = provider["profileImageURL"]?.stringValue
//            
//        }
        
        if let category = obj["category"].dictionary {
            self.categoryID = category["_id"]?.stringValue
            self.categoryName = category["name"]?.stringValue
            self.categoryDescription = category["description"]?.stringValue
            self.categoryImageURL = category["imageURL"]?.stringValue
            
        }
       
        self.name = obj["name"].stringValue
        self.wheree = obj["where"].stringValue
        self.latitude = obj["latitude"].double
        self.longitude = obj["longitude"].double
        self.status = obj["status"].stringValue
        self.type = obj["type"].stringValue
        self.budget = obj["budget"].stringValue
        self.category = obj["category"].stringValue
        self.created = obj["created"].stringValue
        self.details = obj["details"].stringValue
        self.when = obj["when"].stringValue
        self.currency = obj["currency"].stringValue
        self.images.removeAll()
        
        for i in obj["images"] {
            self.images.append(i.1.stringValue)
            
        }
    }
    
    
    
    
}


