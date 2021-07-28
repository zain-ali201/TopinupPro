//
//  User.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation

class UserVO : NSObject {
    
    public var _id:String? = nil
    public var address:String? = nil
    public var contactNumber:String? = nil
    public var created:String? = nil
    public var deviceKey:String? = nil
    public var deviceType :String? = nil
    public var displayName:String? = nil
    public var email:String? = nil
    public var job:String? = nil
    public var latitude:String? = nil
    public var longitude:String? = nil
    public var profileImageURL:String? = nil
    public var provider:String? = nil
    public var rating:String? = nil
    public var token:String? = nil
    public var accountStatus = [Any]()
    public var companyDrivers = [Any]()
    public var coords:[Any] = []
    public var roles : [Any] = []
    public var status : [Any] = []
    public var takeMeHome : [Any] = []
    public var city:String? = nil
    public var state:String? = nil
    public var zipCode:Int? = nil
    
    public override init() { }
    
    public init(withJSON json: NSMutableDictionary) {
        let us = JSON(json)
        self._id = us["_id"].stringValue
        self.address = us["address"].stringValue
        self.contactNumber = us["contactNumber"].string
        self.created = us["created"].stringValue
        self.deviceKey = us["deviceKey"].stringValue
        self.deviceType = us["deviceType"].stringValue
        self.displayName = us["displayName"].stringValue
        self.email = us["email"].stringValue
        self.job = us["job"].stringValue
        self.latitude = us["latitude"].stringValue
        self.longitude = us["longitude"].stringValue
        self.profileImageURL = us["profileImageURL"].stringValue
        self.provider = us["provider"].stringValue
        self.rating = us["rating"].stringValue
        self.token = us["token"].stringValue
        self.city = us["city"].stringValue
        self.state = us["state"].stringValue
        self.zipCode = us["zipCode"].int
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
        self._id = aDecoder.decodeObject(forKey: "_id") as? String
        self.address = aDecoder.decodeObject(forKey: "address") as? String
        self.contactNumber = aDecoder.decodeObject(forKey: "contactNumber") as? String
        self.created = aDecoder.decodeObject(forKey: "created") as? String
        self.deviceKey = aDecoder.decodeObject(forKey: "deviceKey") as? String
        self.deviceType = aDecoder.decodeObject(forKey: "deviceType") as? String
        self.displayName = aDecoder.decodeObject(forKey: "displayName") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.job = aDecoder.decodeObject(forKey: "job") as? String
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as? String
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as? String
        self.profileImageURL = aDecoder.decodeObject(forKey: "profileImageURL") as? String
        self.provider = aDecoder.decodeObject(forKey: "provider") as? String
        self.rating = aDecoder.decodeObject(forKey: "rating") as? String
        self.token = aDecoder.decodeObject(forKey: "token") as? String
        self.city = aDecoder.decodeObject(forKey: "city") as? String
        self.state = aDecoder.decodeObject(forKey: "state") as? String
        self.zipCode = aDecoder.decodeObject(forKey: "zipCode") as? Int
        
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(contactNumber, forKey: "contactNumber")
        aCoder.encode(created, forKey: "created")
        aCoder.encode(deviceKey, forKey: "deviceKey")
        aCoder.encode(deviceType, forKey: "deviceType")
        aCoder.encode(displayName, forKey: "displayName")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(job, forKey: "job")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(profileImageURL, forKey: "profileImageURL")
        aCoder.encode(provider, forKey: "provider")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(token, forKey: "token")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(state, forKey: "state")
        aCoder.encode(zipCode, forKey: "zipCode")
        
    }
    
    //    public func getUsername() -> String{
    //        return firstname!+lastname!
    //    }
    
    
    
    
    
}
