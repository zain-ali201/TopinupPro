//
//  RequestJobDetailVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 23/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON

class RequestJobDetailVO : NSObject {
    
    var _id : String!
    var status : String!
    var requestCreated : String!
    
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
    
    var requestType : String!
    var requestRate : Int!
    var requestProposal : String!
    var requestStatus : String!
    
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
    
    
    override init()
    {
        super.init()
        
        _id = ""
        status = ""
        requestCreated = ""
        
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
        
        requestType = ""
        requestRate = 0
        requestProposal = ""
        requestStatus = ""
        
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
        
        
    }
    
    public init(withJSON json: NSDictionary) {
        let obj = JSON(json)
        
        self._id = obj["_id"].stringValue
        self.status = obj["status"].stringValue
        self.requestCreated = obj["created"].stringValue
        self.requestType = obj["type"].stringValue
        self.requestRate = obj["rate"].intValue
        self.requestProposal = obj["proposal"].stringValue
        
        if let job = obj["job"].dictionary {
           
            self.budget = job["budget"]?.stringValue
            self.details = job["details"]?.stringValue
            self.type = job["type"]?.stringValue
            self.category = job["category"]?.stringValue
            
            self.wheree = job["where"]?.stringValue
            self.latitude = job["latitude"]?.doubleValue
            self.longitude = job["longitude"]?.doubleValue
            self.jobStatus = job["status"]?.stringValue
            
            self.jobID = job["_id"]?.stringValue
            self.jobCreated = job["created"]?.stringValue
            self.when = job["when"]?.stringValue
            
            self.wheree = job["where"]?.stringValue
            self.latitude = job["latitude"]?.doubleValue
            self.longitude = job["longitude"]?.doubleValue
            self.jobStatus = job["status"]?.stringValue
            
            self.images.removeAll()
            
            
            if let client = job["client"]?.dictionary {
                self.clientID = client["_id"]?.stringValue
                self.profileImageURL = client["profileImageURL"]?.stringValue
                self.displayName = client["displayName"]?.stringValue
            }
            
            if let imagess = job["images"]?.arrayObject {
                for i in imagess {
                    let image = String(describing: i)
                    self.images.append(image)
                }
            }
            
            if let order = job["order"]?.dictionary {
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
        }
    }
}
