//
//  JobVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 28/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON


class JobVO : NSObject {
    
    var budget : String!
    var details : String!
    var type : String!
    var category : String!
    var wheree : String!
    var profileImageURL : String!
    var displayName : String!
    var clientID : String!
    var jobStatus : String!
    var jobCreated : String!
    var jobID : String!
    var images = [String]()
    var when : String!
    var latitude : Double!
    var longitude : Double!
    
    var providerName : String!
    var providerID : String!
    var rating : Double!
    
    
    var hourlyRate : Int!
    
    var orderService : Int!
    var orderID : String!
    var orderCreated : String!
    var orderJobID : String!
    var orderAcceptedTime : String!
    var orderArrivedTime : String!
    var orderTotalTime : String!
    var orderFee : Int!
    var orderCompany : Int!
    var orderEndedTime : String!
    var orderStartedTime : String!
    var orderOnwayedTime : String!
    
    var providerLatitude : Double!
    var providerLongitude : Double!
    
    
    override init()
    {
        super.init()
        
     
        
        budget = ""
        details = ""
        type = ""
        category = ""
        wheree = ""
        profileImageURL = ""
        displayName = ""
        clientID = ""
        jobStatus = ""
        jobCreated = ""
        jobID = ""
        images = [String]()
        when = ""
        latitude = 0.0
        longitude = 0.0
        
        providerName = ""
        providerID = ""
        rating = 0.0
        
   
        hourlyRate = 0
        
        orderService = 0
        orderID = ""
        orderCreated = ""
        orderJobID = ""
        orderAcceptedTime = ""
        orderArrivedTime = ""
        orderTotalTime = ""
        orderFee = 0
        orderCompany = 0
        orderEndedTime = ""
        orderStartedTime = ""
        orderOnwayedTime = ""
        
        providerLatitude = 0.0
        providerLongitude = 0.0
        
        
    }
    
    public init(withJSON json: NSDictionary) {
        let job = JSON(json)
        
        self.budget = job["budget"].stringValue
        self.details = job["details"].stringValue
        self.type = job["type"].stringValue
        self.category = job["category"].stringValue
        
        self.wheree = job["where"].stringValue
        self.latitude = job["latitude"].doubleValue
        self.longitude = job["longitude"].doubleValue
        self.jobStatus = job["status"].stringValue
        
        self.jobID = job["_id"].stringValue
        self.jobCreated = job["created"].stringValue
        self.when = job["when"].stringValue
        
        self.wheree = job["where"].stringValue
        self.latitude = job["latitude"].doubleValue
        self.longitude = job["longitude"].doubleValue
        self.jobStatus = job["status"].stringValue
        
        self.images.removeAll()
        
        
        if let client = job["client"].dictionary {
            self.clientID = client["_id"]?.stringValue
            self.profileImageURL = client["profileImageURL"]?.stringValue
            self.displayName = client["displayName"]?.stringValue
        }
        
        if let imagess = job["images"].arrayObject {
            for i in imagess {
                let image = String(describing: i)
                self.images.append(image)
            }
        }
        
        if let order = job["order"].dictionary {
            self.orderService = order["service"]?.intValue
            self.orderID = order["_id"]?.stringValue
            self.orderCreated = order["created"]?.stringValue
            self.orderJobID = order["job"]?.stringValue
            self.orderAcceptedTime = order["acceptedTime"]?.stringValue
            self.orderArrivedTime = order["arrivedTime"]?.stringValue
            self.orderTotalTime = order["totalTime"]?.stringValue
            self.orderFee = order["fee"]?.intValue
            self.orderCompany = order["company"]?.intValue
            self.orderEndedTime = order["endedTime"]?.stringValue
            self.orderStartedTime = order["startedTime"]?.stringValue
            self.orderOnwayedTime = order["onwayedTime"]?.stringValue
            
        }
        
        if let provider = job["provider"].dictionary {
            self.providerLatitude = provider["latitude"]?.doubleValue
            self.providerLongitude = provider["longitude"]?.doubleValue
            self.providerID = provider["_id"]?.stringValue
        }
        
        
    }
    
    
    
    
}
