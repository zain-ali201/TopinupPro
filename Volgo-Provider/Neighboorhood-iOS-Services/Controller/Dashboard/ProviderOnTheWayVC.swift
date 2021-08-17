//
//  ProviderOnTheWayVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 27/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ProviderOnTheWayVC: UIViewController,  MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblAmountRate: UILabel!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnDirections: UIButton!
    @IBOutlet weak var lblETA: UILabel!
    
    var previousAngle : Float = 100.0
    var pointOfDriver : MyAnnotation!
    var tempPolyline : MKPolyline!
    var mapManager = MapManager()
    var pointOfOrigin = MKPointAnnotation.init()
    var pointOfDestination = MKPointAnnotation.init()
    var jobPoint : JobPointVO!
//    var jobStatus : JobStatus!
    let locationManager = CLLocationManager()
    
    var jobInfo : JobHistoryVO!
    var isRouteDrawn : Bool = false
    var orangeColor = UIColor(red: 245/255, green: 162/255, blue: 25/255, alpha: 1)
    var blueColor = UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
//        //self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        self.locationManager.startUpdatingLocation()

        
        self.addObservers()
        self.viewInitializer()
        
        if self.jobInfo != nil
        {
            self.setMapCentred(aroundLocation: CLLocation.init(latitude: self.jobInfo.latitude!, longitude: self.jobInfo.longitude!))
            
            delayWithSeconds(0, completion: {
                self.drawRouteLine()
            })
        }
        
        self.mapView.reloadInputViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
//        self.callApiRoomLeave()
        
        NotificationCenter.default.removeObserver(self, name: .KLeaveRoom, object: nil)
        NotificationCenter.default.removeObserver(self, name: .KJoinRoom, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .KCurrentLocation, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .kSocketConnected, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .kSocketDisconnected, object: nil)
//        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func viewInitializer() {
        
        let data = setImageWithUrl(url: self.jobInfo.categoryImageURL!)
        
        DispatchQueue.main.async {
            self.imgView.layer.cornerRadius = self.imgView.frame.height/2
           // self.imgView.image = UIImage(data: data!)
        }
       
        self.lblTitle.text = self.jobInfo.displayName
        
        if self.jobInfo.type == JobType.fixed.rawValue
        {
            self.lblAmountRate.text = self.jobInfo.budget + (self.jobInfo.currency)
        }
        else
        {
            self.lblAmountRate.text = self.jobInfo.budget + "\((self.jobInfo.currency))/hr"
        }
        
        self.lblETA.text = self.jobInfo.categoryName.capitalized
    }
    
    func addObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.didReceiveSocketConectionResponse(notification:)), name: .kSocketConnected, object: nil)
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.viewInitializerNotification(_:)), name: NSNotification.Name(rawValue: "providerOnTheWay"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.didReceiveSocketDisconectResponse(notification:)), name: .kSocketDisconnected, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.didReceiveJoinRoomResponse(notification:)), name: NSNotification.Name.KJoinRoom, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.didReceiveLeaveRoomResponse(notification:)), name: NSNotification.Name.KLeaveRoom, object: nil)
    }
    
    
//    @objc func viewInitializerNotification (_ notification : NSNotification) {
//        if let jobInfoo = notification.userInfo?["jobInfo"] as? JobVO {
//            self.jobInfo = jobInfoo
//            self.viewInitializer()
//        }
//    }
    
    
    
//    func callApiRoomJoin() {
//        let params = ["room" : self.jobInfo.providerID] as [String : Any]
//        SocketManager.shared.sendSocketRequest(name: SocketEvent.JoinRoom, params: params)
//    }
//
//    func callApiRoomLeave() {
//        let params = ["room" : self.jobInfo.providerID] as [String : Any]
//        SocketManager.shared.sendSocketRequest(name: SocketEvent.leaveRoom, params: params)
//    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMessageAction(_ sender: Any) {
        
//        let chatView = ChatViewController()
//        chatView.messages = makeNormalConversation()
//        chatView.jobID = self.jobInfo._id
//        let chatNavigationController = UINavigationController(rootViewController: chatView)
//        present(chatNavigationController, animated: true, completion: nil)
        
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailViewController") as! ChatDetailViewController
        vc.messages = []
        vc.jobID = self.jobInfo._id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCallAction(_ sender: Any) {
        
        // please add client phone number
        if let phone = self.jobInfo.clientPhone
        {
            if phone != ""
            {
                let number = URL(string: "tel://" + phone)
                let alertController = UIAlertController(title: "Alert", message: "Are you Sure want to Call? Call Charges will be applied", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                    UIApplication.shared.openURL(number!)
                }
                let NoAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                alertController.addAction(NoAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    var navigationLatitude : Double?
    var navigationLongitude : Double?
    
    @IBAction func btnDirectionsAction(_ sender: Any) {
        
        let sourceLatitude = DashboardVC.lastSavedLocation!.coordinate.latitude
        let sourceLongitude = DashboardVC.lastSavedLocation!.coordinate.longitude
        
        navigationLatitude = self.jobInfo.latitude
        navigationLongitude = self.jobInfo.longitude
        
        guard  let destinationLatitude = navigationLatitude,
            let destinationLongitue = navigationLongitude
            else {
                
                self.showInfoAlertWith(title: "Sorry", message: "Unable to launch external navigation at the moment.")
                return;
        }
        
//        let sourceCoordinate = CLLocationCoordinate2DMake(sourceLatitude, sourceLongitude)
//        let destinationCoordinate = CLLocationCoordinate2DMake(destinationLatitude, destinationLongitue)
        
        let urlString = "https://maps.google.com/?saddr=\(sourceLatitude),\(sourceLongitude)&daddr=\(destinationLatitude),\(destinationLongitue)&directionsmode=driving"
        UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
//        showNavigationOptions(from: sourceCoordinate, to: destinationCoordinate)
    }
    
    // This gets called periodically
    @objc func userLocationUpdated(notification : Notification)
    {
        let userInfo = notification.userInfo
        if let location = (userInfo as NSDictionary?)?.value(forKey: "location") as? CLLocation
        {
            moveDriverOnMap(driverLocation: location)
            
            self.jobPoint = JobPointVO(lat: location.coordinate.latitude, long: location.coordinate.longitude, time: Date().iso8601)
        
        }
    }
    
    func moveDriverOnMap(driverLocation : CLLocation)
    {
        //  Code here to show driver position on map
        
        if(pointOfDriver == nil)
        {
            pointOfDriver  = MyAnnotation.init()
            
            let location = CLLocation(latitude: driverLocation.coordinate.latitude, longitude: driverLocation.coordinate.longitude)
            
            pointOfDriver.setCoordinate(location.coordinate)
            
            pointOfDriver.previousCoordinate = CLLocationCoordinate2D.init(latitude: driverLocation.coordinate.latitude, longitude: driverLocation.coordinate.longitude)
            
            
            if let user = AppUser.getUser() {
                pointOfDriver.idVal = user._id
            }
            
            
            
            
            //            pointOfDriver.bearing = driverLocation.bearing;
            
            pointOfDriver.carType = ""
            
            DispatchQueue.main.async {
                
                self.mapView.addAnnotation(self.pointOfDriver)
                self.setMapCentred(aroundLocation: driverLocation)
            }
            
        }
        
        
        let thisPoint : MyAnnotation = pointOfDriver
        
        thisPoint.previousCoordinate = thisPoint.coordinate
        
        UIView.animate(withDuration: 1.2, animations: {
            
            thisPoint.setCoordinate(CLLocationCoordinate2D.init(latitude: driverLocation.coordinate.latitude, longitude: driverLocation.coordinate.longitude))
            
        }, completion: { (success:Bool) in
            
            //            let location = CLLocation(latitude: driverLocation.coordinate.latitude, longitude: driverLocation.coordinate.longitude)
            
            self.setMapCentred(aroundLocation: driverLocation)
            
        })
        
        //Because vehicle is hidden and default location icon is shown now during the job
        
        if (self.mapView.view(for: thisPoint) != nil)
        {
            let annotationView: MKAnnotationView = self.mapView.view(for: thisPoint)!
            
            let getAngle = Float(self.getBearingBetweenTwoPoints1(point1: thisPoint.previousCoordinate, point2: thisPoint.coordinate))
            
            let willTransform = isSufficientDifferenceBetween(current: getAngle, previous: previousAngle)
            //                        print("Angle Between 2 Points \(getAngle) : \(willTransform)")
            
            if(willTransform == true)
            {
                print("Transformed Angle --------------------------")
                annotationView.transform = CGAffineTransform(rotationAngle: CGFloat(getAngle))
                previousAngle = getAngle
            }
        }
    }
    
    func isSufficientDifferenceBetween(current : Float, previous : Float) -> Bool
    {
        var result = false
        var difference = current - previous
        if (difference < 0)
        {
            difference = difference * -1
        }
        
        if difference > 0.25
        {
            result = true
        }
        else
        {
            result = false
        }
        
        return result
        
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    func getBearingBetweenTwoPoints1(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            print("location:: (\(location))")
            print(location.coordinate)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured \(error.localizedDescription)")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let coordinate = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude)
        print(center)
        print(coordinate)
        
    }
    
    func setMapCentred(aroundLocation location : CLLocation)
    {
        let latDelta:CLLocationDegrees = 0.005
        let longDelta:CLLocationDegrees = 0.005
        
        let coordinate = CLLocationCoordinate2D(latitude:location.coordinate.latitude, longitude: location.coordinate.longitude )
        
        let theSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: theSpan)
        let destination = MKPointAnnotation()
        destination.title = "London"
        destination.coordinate = coordinate
        self.mapView.addAnnotation(destination)
        self.mapView.setRegion(region, animated: true)
    }
    
    func drawRouteLine()
    {
        var origin : NSString!
        var destination : NSString!
        
        
        if (self.tempPolyline != nil)
        {
            mapView.removeOverlay(self.tempPolyline)
        }
        
        if let lastSavedLocation = DashboardVC.lastSavedLocation
        {
//            if (self.jobInfo.jobStatus == JobStatus.onway.rawValue) || (self.jobInfo.jobStatus == JobStatus.arrived.rawValue)
//            {
                origin = String(format:"%f,%f",(DashboardVC.lastSavedLocation?.coordinate.latitude)!,(DashboardVC.lastSavedLocation?.coordinate.longitude)!)  as NSString!
                destination = String(format:"%f,%f",self.jobInfo.latitude,self.jobInfo.longitude)  as NSString!
            
            
//            }
//            else
//            {
//                origin = String(format:"%f,%f",(DashboardVC.lastSavedLocation?.coordinate.latitude)!,(DashboardVC.lastSavedLocation?.coordinate.longitude)!)  as NSString!
//                destination = String(format:"%f,%f",self.jobInfo.jobOriginLatitude,self.jobInfo.jobOriginLongitude)  as NSString!
//
//            }
            
            
            
            
            mapManager.directionsUsingGoogle(from: origin!, to: destination!) { (route,directionInformation, boundingRegion, error) -> () in
                
                if(error != nil)
                {
                    print(error)
                }
                else
                {
                    if (self.pointOfDriver != nil)
                    {
                        self.mapView.removeAnnotation(self.pointOfDriver)
                        self.pointOfDriver = nil
                    }
                    
                    self.pointOfOrigin = MKPointAnnotation()
                    self.pointOfOrigin.accessibilityHint = "Source"
                    self.pointOfOrigin.coordinate = route!.coordinate
                    self.pointOfOrigin.title = directionInformation?.object(forKey: "start_address") as! NSString as String
                    self.pointOfOrigin.subtitle = directionInformation?.object(forKey: "duration") as! NSString as String
                    
                    self.pointOfDestination = MKPointAnnotation()
                    self.pointOfDestination.accessibilityHint = "Destination"
                    self.pointOfDestination.coordinate = route!.coordinate
                    self.pointOfDestination.title = directionInformation?.object(forKey: "end_address") as! NSString as String
                    self.pointOfDestination.subtitle = directionInformation?.object(forKey: "distance") as! NSString as String
                    
                    let start_location = directionInformation?.object(forKey: "start_location") as! NSDictionary
                    let originLat = start_location.object(forKey: "lat") as! Double
                    let originLng = start_location.object(forKey: "lng") as! Double
                    
                    let end_location = directionInformation?.object(forKey: "end_location") as! NSDictionary
                    let destLat = end_location.object(forKey: "lat") as! Double
                    let destLng = end_location.object(forKey: "lng") as! Double
                    
                    let coordOrigin = CLLocationCoordinate2D(latitude: originLat, longitude: originLng)
                    let coordDesitination = CLLocationCoordinate2D(latitude: destLat, longitude: destLng)
                    
                    self.pointOfOrigin.coordinate = coordOrigin
                    
                    self.pointOfDestination.coordinate = coordDesitination
                    
                    if let map = self.mapView
                    {
                        DispatchQueue.main.async {
                            
                            self.removeAllPlacemarkFromMap(shouldRemoveUserLocation: true)
                            self.tempPolyline = route
                            map.addOverlay(route!)
                            map.addAnnotation(self.pointOfOrigin)
                            map.addAnnotation(self.pointOfDestination)
                            map.setVisibleMapRect(boundingRegion!, edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30), animated: true)
                            
                            
                        }
                    }
                }
            }
            
            
            
        }
        
        
    }
    
    func removeAllPlacemarkFromMap(shouldRemoveUserLocation:Bool){
        if let mapView = self.mapView {
            for annotation in mapView.annotations{
                if shouldRemoveUserLocation {
                    if annotation as? MKUserLocation !=  mapView.userLocation {
                        mapView.removeAnnotation(annotation as MKAnnotation)
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if (annotation is MKUserLocation)
        {
            //            return nil
        }
        else
        {
            if let annot : MyAnnotation = annotation as? MyAnnotation
            {
                let annView : MKAnnotationView = annot.annotaionView()
                annView.image = nil;
                annView.image = UIImage(named: "markersmall")
                return annView;
            }
            else if let pointAnnotation = annotation as? MKPointAnnotation
            {
                let identifier = "locationPoint"
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                if(pointAnnotation.accessibilityHint == "Source")
                {
                    annotationView.image = UIImage(named:"markersmall")
                }
                else if (pointAnnotation.accessibilityHint == "Destination")
                {
                    annotationView.image = UIImage(named:"markersmall")
                } else {
                    annotationView.image = UIImage(named:"markersmall")
                }
                
                return annotationView;
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let renderer = YMPolyLineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    @objc func didReceiveSocketDisconectResponse(notification : Notification)
    {
        //showProgressHud(viewController: self)
    }
    
    @objc func didReceiveSocketConectionResponse(notification : Notification)
    {
        hideProgressHud(viewController: self)
    }
    
    @objc func didReceiveJoinRoomResponse(notification : Notification)
    {
        if let userInfo = notification.userInfo as? NSDictionary
        {
            let suc = userInfo.value(forKey: "success") as! Bool
            let msg = userInfo.value(forKey: "message") as! String
            if suc
            {
                
            }
            else
            {
                
            }
        }
    }
    
    @objc func didReceiveLeaveRoomResponse(notification : Notification)
    {
        if let userInfo = notification.userInfo as? NSDictionary
        {
            let suc = userInfo.value(forKey: "success") as! Bool
            let msg = userInfo.value(forKey: "message") as! String
            if suc
            {
                
            }
            else
            {
                
            }
        }
    }
    
//    @objc func didReceiveClientNotificationResponse(notification : Notification)
//    {
//        
//        hideProgressHud(viewController: self)
//        
//        let userInfo = notification.userInfo as! NSDictionary
//        print(#function , userInfo)
//        
//        let suc = userInfo.value(forKey: "success") as! Bool
//        //let msg = userInfo.value(forKey: "message") as! String
//        
//        if suc
//        {
//            
//            print("Response occured")
//            
////            if let assignedJobs = userInfo.object(forKey: "assigns") as? NSArray
////            {
////
////
////
////
////            } else {
////                print("NOT")
////            }
//        }
//        else
//        {
//            showInfoAlertWith(title: "Failed", message: "")
//        }
//    }
    
    

}

extension UIViewController
{
    
    func showNavigationOptions(from source : CLLocationCoordinate2D, to destination : CLLocationCoordinate2D)
    {
        let sourceLatitude = source.latitude
        let sourceLongitude = source.longitude
        
        let destinationLatitude = destination.latitude
        let destinationLongitude = destination.longitude
        
        
        var isOtherSchemePresent = false
        
        let alertController = UIAlertController(title: "Selection Required", message: "Which application would you like to see directions in?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        //        "http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f"
        if(schemeAvailable(scheme: "comgooglemaps://"))
        {
            isOtherSchemePresent = true
            print("google maps installed")
            //            UIApplication.shared.openURL(URL(string:"https://www.google.com/maps/@42.585444,13.007813,6z")!)
            
            let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default, handler: { (alertAction) in
                
                let googleMapUrl = "comgooglemaps://?saddr=\(sourceLatitude),\(sourceLongitude)&daddr=\(destinationLatitude),\(destinationLongitude)&directionsmode=driving"
                UIApplication.shared.openURL(URL(string: googleMapUrl)!)
            })
            
            alertController.addAction(googleMapsAction)
            
        }
        
        if(schemeAvailable(scheme: "waze://"))
        {
            isOtherSchemePresent = true
            print("waze maps installed")
            
            let wazeAction = UIAlertAction(title: "Waze", style: .default, handler: { (alertAction) in
                
                let wazeUrl = "waze://?ll=\(destinationLatitude),\(destinationLongitude)&navigate=yes"
                UIApplication.shared.openURL(URL(string: wazeUrl)!)
                
            })
            
            alertController.addAction(wazeAction)
            
        }
        
        // Apple Maps would be present always.
        let appleMapsUrl = "http://maps.apple.com/?saddr=\(sourceLatitude),\(sourceLongitude)&daddr=\(destinationLatitude),\(destinationLongitude)"
        
        // If other options available, show apple maps as an option too
        if (isOtherSchemePresent)
        {
            
            let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default, handler: { (alertAction) in
                
                UIApplication.shared.openURL(URL(string: appleMapsUrl)!)
            })
            alertController.addAction(appleMapsAction)
            
            present(alertController, animated: true, completion: nil)
        }
            // Otherwise, simply open the apple maps
        else
        {
            UIApplication.shared.openURL(URL(string: appleMapsUrl)!)
        }
        
        /*
         if(schemeAvailable(scheme: "com.sygic.aura://"))
         {
         print("Sygic maps installed")
         }
         */
        
    }
    
    // Helper Methods
    func schemeAvailable(scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
}
}
