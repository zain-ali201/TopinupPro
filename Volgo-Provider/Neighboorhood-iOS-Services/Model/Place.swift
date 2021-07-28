//
//  Place.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 27/08/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import Foundation

class Place: NSObject {
    private var place_id: String = ""
    private var address_1: String = ""
    private var address_2: String = ""
    private var _type: String = ""
    private var place_coordinates: CLLocationCoordinate2D?
    
    init(place_id: String = "", address_1: String = "", address_2: String = "", type: String = "", place_coordinates: CLLocationCoordinate2D? = nil){
        self.place_id = place_id
        self.address_1 = address_1
        self.address_2 = address_2
        self._type = type
        self.place_coordinates = place_coordinates
    }
    
    init(address1: String, address2: String){
        self.address_1 = address1
        self.address_2 = address2
    }
    
    var address1: String {
        get {
            return address_1
        }
        set(value){
            self.address_1 = value
        }
    }
    
    var address2: String {
        get {
            return address_2
        }
        set(value){
            self.address_2 = value
        }
    }
    
    var type: String{
        get{
            return _type
        }
        set(value){
            _type = value
        }
    }
    
    var placeID: String{
        get{
            return place_id
        }
        set(value){
            self.place_id = value
        }
    }
    
    var coordinates: CLLocationCoordinate2D? {
        get {
            return place_coordinates
        }
        set(value){
            self.place_coordinates = value
        }
    }
}
