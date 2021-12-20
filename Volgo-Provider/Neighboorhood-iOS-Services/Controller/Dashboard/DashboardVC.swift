 //
//  DashboardVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import FSCalendar
import CoreLocation
import Alamofire
import SwiftyJSON
 
enum TabBarButtonActive : Int {
    case jobs = 0
    case newRequest = 1
    case postponed = 2
    case accepted = 3
}
 
 extension Notification.Name {
    static let reloadDashboardJobs = Notification.Name("reloadDashboardJobs")
 }

class DashboardVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, CLLocationManagerDelegate {
    
    static let KEY_UNREAD_MESSAGES : String = "unreadMessages"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewBackgroundListView: UIView!
    @IBOutlet weak var FSCalendar: FSCalendar!
    @IBOutlet weak var heightConstraintsCalendar: NSLayoutConstraint!
    
    @IBOutlet weak var lblNoJobs: UILabel!
    @IBOutlet weak var btnJobs: UIButton!
    @IBOutlet weak var btnNewRequest: UIButton!
    @IBOutlet weak var btnPostponed: UIButton!
    @IBOutlet weak var btnAccepted: UIButton!
    @IBOutlet weak var viewBarJobs: UIView!
    @IBOutlet weak var viewBarNewRequest: UIView!
    @IBOutlet weak var viewBarPostponed: UIView!
    @IBOutlet weak var viewBarAccepted: UIView!
    
    @IBOutlet weak var viewBackgroundTabBar: UIView!
    
    var lightColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    var greenColor = UIColor(red: 2/255, green: 196/255, blue: 130/255, alpha: 1)
    var normalColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    
    let user = AppUser.getUser()
    
    
    var allJobHistory = [JobHistoryVO]()
    var dataSource = [JobHistoryVO]()
    var params : [String:Any]! = nil
    var jobDotIndicator = false
    static var lastSavedLocation : CLLocation?
    
    var selectedIndex = Int()
    var selectiveJobID : String!
    var selectedRequestID : String!
    var jobStatus : String!
    var jobDate : String!
    
    var tabBarBtn: TabBarButtonActive!
    var tag = Int()
    
    var jobRequestObject = [ProviderJobRequestVO]()
    var jobsObject = [ProviderJobRequestVO]()
    var jobAcceptedObject = [ProviderJobRequestVO]()
    var isLoaded = false
    let locationManager = CLLocationManager()
    var selectedDate = Date()
    let notificationButton = SSBadgeButton()
    
    let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        self.viewBackgroundTabBar = addViewShadow(view : self.viewBackgroundTabBar)
        self.tableView.register(UINib(nibName: "JobList", bundle: nil), forCellReuseIdentifier: "cell")
        
        tabBarBtn = TabBarButtonActive(rawValue: TabBarButtonActive.jobs.rawValue)
        SocketManager.shared.establishConnection()
        
        checkForAboveTab()
        self.setupSideMenu()
        setupRightBarButtonItem()
        
        self.addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if AppDelegate.isFromNotification
        {
            if AppDelegate.subsection == "jobs"
            {
                tabBarBtn = TabBarButtonActive(rawValue: TabBarButtonActive.jobs.rawValue)
                checkForAboveTab()
            }
            else if AppDelegate.subsection == "newrequests"
            {
                tabBarBtn = TabBarButtonActive(rawValue: TabBarButtonActive.newRequest.rawValue)
                checkForAboveTab()
            }
        }
        
        self.locationViewInitializer()
        //self.getUserLocation()
        //SocketManager.shared.sendSocketRequest(name: SocketEvent.Is_Driver_Active, params: ["":""])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let startOfDay = Calendar.current.startOfDay(for: selectedDate).iso8601
        self.handymanNearbyCallingApi(date: startOfDay)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func reloadDashboardJobs(_ botification: Notification){
        
        
        let startOfDay = Calendar.current.startOfDay(for: selectedDate).iso8601
        self.handymanNearbyCallingApi(date: startOfDay)
    }
    
    func setupRightBarButtonItem()
    {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(toggleValueChanged(_:)), for: .valueChanged)
        toggle.onTintColor = UIColor.green
        toggle.tintColor = UIColor.red
        toggle.thumbTintColor = UIColor.white
        toggle.backgroundColor = UIColor.red
        toggle.layer.cornerRadius = 16
    
        statusLabel.font = UIFont.boldSystemFont(ofSize: 16)
        statusLabel.textColor = UIColor.white
        
        if let user = AppUser.getUser()
        {
            statusLabel.text = (user.status == true) ? "Online": "Offline";
            toggle.setOn(user.status!, animated: false)
        }
        
        notificationButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        notificationButton.setImage(UIImage(named: "chatWhite"), for: .normal)
        notificationButton.addTarget(self, action: #selector(self.gotoMessages), for: .touchUpInside)
        notificationButton.badgeEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
//        let unreadCount: Int = UserDefaults.standard.integer(forKey: DashboardVC.KEY_UNREAD_MESSAGES)
//        notificationButton.badge = "\(unreadCount)"
        
        let stackView = UIStackView(arrangedSubviews: [toggle, statusLabel, notificationButton])
        stackView.spacing = 15
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
    }
    
    @objc func toggleValueChanged(_ toggle: UISwitch)
    {
        statusLabel.text = (toggle.isOn) ? "Online": "Offline";
        
        if let user = AppUser.getUser() {
            
            updateUserStaus(id: user._id!)
        }
    }
    
    @objc func gotoMessages()
    {
        NotificationCenter.default.post(name: .gotoMessagesNotification, object: nil)
    }
    
    @objc func didReceiveUnreadMessageResponse(notification : Notification)
    {
        if let userInfo = notification.userInfo as NSDictionary?
        {
            let unreadCount: Int = userInfo["count"] as! Int
            UserDefaults.standard.set(unreadCount , forKey: DashboardVC.KEY_UNREAD_MESSAGES)
            UserDefaults.standard.synchronize()
            UIApplication.shared.applicationIconBadgeNumber = UserDefaults.standard.integer(forKey: DashboardVC.KEY_UNREAD_MESSAGES)
            
            if(unreadCount != 0){
                self.notificationButton.badge =  "\(unreadCount)"
            }
        }
    }
    
    func getUserLocation()
    {
        if let lastSavedLocation = DashboardVC.lastSavedLocation
        {
            
        }
    }
    
    func sendLocationToServer()
    {   
        if let lastSavedLocation = DashboardVC.lastSavedLocation
        {
            print("lat: \(lastSavedLocation.coordinate.latitude.roundedStringValue())")
            print("Long: \(lastSavedLocation.coordinate.longitude.roundedStringValue())")
            
            
            var paramsForLocation = ["latitude": lastSavedLocation.coordinate.latitude.roundedStringValue(),
                                     "longitude": lastSavedLocation.coordinate.longitude.roundedStringValue()
                                     ] as [String : Any]
            SocketManager.shared.sendSocketRequest(name: SocketEvent.CurrentLocation, params: paramsForLocation)
        }
    }
    
    func addObservers()
    {
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardVC.providerLocationUpdated(notification:)), name: .KCurrentLocation, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardVC.didReceiveSocketConectionResponse(notification:)), name: .kSocketConnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardVC.didReceiveSocketDisconectResponse(notification:)), name: .kSocketDisconnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDashboardJobs(_:)), name: .reloadDashboardJobs, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUnreadMessageResponse), name: NSNotification.Name.kGetUnreadMsgs, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: Selector(("appWillEnterForegroundNotification")), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        
    }
    
  
    
    override func viewWillDisappear(_ animated: Bool) {
        
//        NotificationCenter.default.removeObserver(self, name: .kSocketConnected, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .kSocketDisconnected, object: nil)
//        NotificationCenter.default.removeObserver(self)
    }
    
    func handymanNearbyCallingApi(date : String) {
        
        print("Selected Date is : \(date)")
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
//        self.params = ["created" : date, "latitude": (DashboardVC.lastSavedLocation?.coordinate.latitude ?? 0).roundedStringValue(),
//                       "longitude": (DashboardVC.lastSavedLocation?.coordinate.longitude ?? 0).roundedStringValue()] as! [String:Any]
        
        
        self.params = ["created" : "","latitude": (DashboardVC.lastSavedLocation?.coordinate.latitude ?? 0).roundedStringValue(),
                       "longitude": (DashboardVC.lastSavedLocation?.coordinate.longitude ?? 0).roundedStringValue()] as! [String:Any]
        
        
        
        showProgressHud(viewController: self)
        
        Api.jobHistoryApi.providerHome(params: self.params, completion: { (success:Bool, message : String, jobRequestObject : [ProviderJobRequestVO?], jobsObject : [ProviderJobRequestVO?], jobAcceptedObject : [ProviderJobRequestVO?]) in
            hideProgressHud(viewController: self)
            
            self.jobRequestObject.removeAll()
            self.jobsObject.removeAll()
            
            if success
            {
                
                
                if jobsObject != nil
                {
                    self.jobsObject.removeAll()
                    self.jobsObject = jobsObject as! [ProviderJobRequestVO]
                }
                
                if jobRequestObject != nil
                {
                    self.jobRequestObject.removeAll()
                    self.jobRequestObject = jobRequestObject as! [ProviderJobRequestVO]
                    
                }
                
                if jobAcceptedObject != nil
                {
                    self.jobAcceptedObject.removeAll()
                    self.jobAcceptedObject = jobAcceptedObject as! [ProviderJobRequestVO]
                    
                    self.jobStatus = ""
                    for item in self.jobAcceptedObject {
                        
                        let status: String? = item.status
                        let when: String? = item.when
                        
                        if(status == "started"){
                            self.jobStatus = status
                            self.jobDate = when
                            break;
                        }
                    }
                    
                }
                
                
                print(self.jobsObject)
                print(self.jobRequestObject)
                self.tableView.reloadData()
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
//    func appWillEnterForegroundNotification(){
//
//        let startOfDay = Calendar.current.startOfDay(for: selectedDate).iso8601
//        self.handymanNearbyCallingApi(date: startOfDay)
//    }
    
    @IBAction func btnJobsAction(_ sender: Any) {
        tabBarBtn = TabBarButtonActive(rawValue: TabBarButtonActive.jobs.rawValue)
        checkForAboveTab()
        
//        self.performSegue(withIdentifier: "jobDetailsSegue", sender: nil)
    }
    
    @IBAction func btnNewRequestAction(_ sender: Any) {
        tabBarBtn = TabBarButtonActive(rawValue: TabBarButtonActive.newRequest.rawValue)
        checkForAboveTab()
    }
    
    @IBAction func btnPostponedAction(_ sender: Any) {
        tabBarBtn = TabBarButtonActive(rawValue: TabBarButtonActive.postponed.rawValue)
        checkForAboveTab()
    }
    
    @IBAction func btnAcceptedAction(_ sender: Any) {
        tabBarBtn = TabBarButtonActive(rawValue: TabBarButtonActive.accepted.rawValue)
        checkForAboveTab()
    }
    
    func checkForAboveTab() {
        
        if tabBarBtn.rawValue == TabBarButtonActive.jobs.rawValue {
            
            self.viewBarJobs.isHidden = false
            self.viewBarNewRequest.isHidden = true
            self.viewBarPostponed.isHidden = true
            self.viewBarAccepted.isHidden = true
            
            self.btnJobs.setTitleColor(greenColor, for: .normal)
            self.btnNewRequest.setTitleColor(normalColor, for: .normal)
            //self.btnPostponed.setTitleColor(normalColor, for: .normal)
            self.btnAccepted.setTitleColor(normalColor, for: .normal)
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.newRequest.rawValue {
            
            self.viewBarJobs.isHidden = true
            self.viewBarNewRequest.isHidden = false
            self.viewBarPostponed.isHidden = true
            self.viewBarAccepted.isHidden = true
            
            self.btnJobs.setTitleColor(normalColor, for: .normal)
            self.btnNewRequest.setTitleColor(greenColor, for: .normal)
            self.btnPostponed.setTitleColor(normalColor, for: .normal)
            self.btnAccepted.setTitleColor(normalColor, for: .normal)
            
            
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.postponed.rawValue {
            
            self.viewBarJobs.isHidden = true
            self.viewBarNewRequest.isHidden = true
            self.viewBarPostponed.isHidden = false
            self.viewBarAccepted.isHidden = true
            
            self.btnJobs.setTitleColor(normalColor, for: .normal)
            self.btnNewRequest.setTitleColor(normalColor, for: .normal)
            self.btnPostponed.setTitleColor(greenColor, for: .normal)
            self.btnAccepted.setTitleColor(normalColor, for: .normal)
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.accepted.rawValue {
            
            self.viewBarJobs.isHidden = true
            self.viewBarNewRequest.isHidden = true
            self.viewBarPostponed.isHidden = true
            self.viewBarAccepted.isHidden = false
            
            self.btnJobs.setTitleColor(normalColor, for: .normal)
            self.btnNewRequest.setTitleColor(normalColor, for: .normal)
            self.btnPostponed.setTitleColor(normalColor, for: .normal)
            self.btnAccepted.setTitleColor(greenColor, for: .normal)
        }
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tabBarBtn.rawValue == TabBarButtonActive.jobs.rawValue
        {
            return self.jobsObject.count
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.newRequest.rawValue
        {
            return self.jobRequestObject.count
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.postponed.rawValue
        {
            return 0
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.accepted.rawValue
        {
            return self.jobAcceptedObject.count
        }
        else
        {
            return 0
        }
//        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! JobListTVC
        cell.selectionStyle = .none
        
        var currentIndex : ProviderJobRequestVO!
        
        if tabBarBtn.rawValue == TabBarButtonActive.jobs.rawValue
        {
            currentIndex = self.jobsObject[indexPath.row]
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.newRequest.rawValue
        {
            currentIndex = self.jobRequestObject[indexPath.row]
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.postponed.rawValue
        {
            currentIndex = self.jobsObject[indexPath.row]
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.accepted.rawValue
        {
            currentIndex = self.jobAcceptedObject[indexPath.row]
        }
        
        if currentIndex != nil
        {
            cell.lblName.text = currentIndex.displayName + " (\(currentIndex.categoryName))"
            cell.selectionStyle = .none
            cell.imgClient.layer.cornerRadius = cell.imgClient.frame.height/2
            cell.lblAddress.text = currentIndex.wheree
            cell.lblStatus.text = currentIndex.status.capitalized
            //print("Job ID is : \(currentIndex._id)")
            cell.lblDateTime.text = DateUtil.getSimpleDateAndTime(currentIndex.when.dateFromISO8601!)
            
            var newStr = currentIndex.profileImageURL!
            var imageUrl = ""
            if(!newStr.isEmpty){
                newStr.remove(at: (newStr.startIndex))
                imageUrl = URLConfiguration.ServerUrl + newStr
                /*
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
                    {
                        DispatchQueue.main.async {
                            cell.imgClient.image = UIImage(data: data)
                        }
                    }
                }
                */
                if let url = URL(string: imageUrl) {
                    //self.userImageView.kf.setImage(with: url)
                    
                    cell.imgClient.kf.setImage(with: url, placeholder: UIImage(named: "imagePlaceholder"), options: nil, progressBlock: nil) { (image, error, cacheTyle, uurl) in
                        //                    self.userBtn.setImage(image, for: .normal)
                    }
                    
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tabBarBtn.rawValue == TabBarButtonActive.jobs.rawValue {
            if self.jobAcceptedObject.count != 0 && self.jobDate != nil{
                let startedJobDate = DateUtil.getsimpleDate(self.jobDate.dateFromISO8601!)
                let aceptedJobDate = DateUtil.getsimpleDate(self.jobsObject[indexPath.row].when.dateFromISO8601!)
                
                if(startedJobDate == aceptedJobDate){
                    self.showInfoAlertWith(title: "Alert", message: "You have already accepted a job for this date.")
                    return
                }
                
            }
            selectedIndex = indexPath.row
            selectiveJobID = self.jobsObject[indexPath.row]._id
            self.performSegue(withIdentifier: "jobDetailsSegue", sender: nil)
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.newRequest.rawValue {
            if self.jobAcceptedObject.count != 0  && self.jobDate != nil{
                let startedJobDate = DateUtil.getsimpleDate(self.jobDate.dateFromISO8601!)
                let aceptedJobDate = DateUtil.getsimpleDate(self.jobRequestObject[indexPath.row].when.dateFromISO8601!)
                
                if(startedJobDate == aceptedJobDate){
                    self.showInfoAlertWith(title: "Alert", message: "You have already accepted a job for this date.")
                    return
                }
                
            }
            selectedIndex = indexPath.row
            selectiveJobID = self.jobRequestObject[indexPath.row]._id
            selectedRequestID = self.jobRequestObject[indexPath.row].requestID
            self.performSegue(withIdentifier: "jobDetailsSegue", sender: nil)
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.postponed.rawValue {
            
//            if self.jobAcceptedObject.count != 0 {
//                self.showInfoAlertWith(title: "Alert", message: "You have already accepted a job for this date.")
//                return
//            }
            
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.accepted.rawValue {
            
            let whenStated = self.jobAcceptedObject[indexPath.row].when.dateFromISO8601
            let currentdate = Date()
            
            print(whenStated!)
            print(currentdate)
            
            
            if self.jobAcceptedObject.count != 0  && self.jobDate != nil{
                let startedJobDate = DateUtil.getsimpleDate(self.jobDate.dateFromISO8601!)
                let aceptedJobDate = DateUtil.getsimpleDate(self.jobAcceptedObject[indexPath.row].when.dateFromISO8601!)
                
               
                if(self.jobAcceptedObject[indexPath.row].status != "started"){
                
                    if(self.jobStatus == "started" || startedJobDate == aceptedJobDate){
                        self.showInfoAlertWith(title: "Alert", message: "Finish your started job first")
                        return
                    }
                }
                
            }
            
            if(whenStated! > currentdate){
                
               self.showInfoAlertWith(title: "Alert", message: "You Can't start job before time")
               return
            }
            
            
            selectedIndex = indexPath.row
            selectiveJobID = self.jobAcceptedObject[indexPath.row]._id
            self.performSegue(withIdentifier: "jobAcceptedSegue", sender: nil)
            
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        
        heightConstraintsCalendar.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
       selectedDate = date
        self.handymanNearbyCallingApi(date: date.iso8601)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? JobDetailVC {
            
            controller.jobID = selectiveJobID
            controller.requestID = selectedRequestID
            controller.tabBarBtn = tabBarBtn
            
        }
        else if let controller = segue.destination as? JobStartDetailVC
        {
            controller.jobID = selectiveJobID
        }
    }
    
    func locationViewInitializer() {
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 5.0;
        self.locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first
        {
            DashboardVC.lastSavedLocation = location
            self.sendLocationToServer()
            if !isLoaded {
                isLoaded = true
                let startOfDay = Calendar.current.startOfDay(for: selectedDate).iso8601
                self.handymanNearbyCallingApi(date: startOfDay)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured \(error.localizedDescription)")
    }
    
    @objc func providerLocationUpdated(notification : Notification)
    {
        if let userInfo = notification.userInfo as? NSDictionary
        {
            print("\(#function) : \(userInfo)")
        }
    }
    
    @objc func didReceiveSocketDisconectResponse(notification : Notification)
    {
        
    }
    
    @objc func didReceiveSocketConectionResponse(notification : Notification)
    {
        sendLocationToServer()
        
        self.getUnreadMessageCount()
    }
    
    func getUnreadMessageCount()
    {
        let params = ["userId": user?._id ?? ""] as [String : Any]
        SocketManager.shared.sendSocketRequest(name: SocketEvent.getUnreadMsgs, params: params)
    }
    
    func updateUserStaus(id : String)
    {
        let urlString = URLConfiguration.providerUserStatusURL + id
        self.params = nil
        Alamofire.request(urlString, method: .post,parameters: params, encoding: URLEncoding.httpBody, headers: URLConfiguration.headers())
            .responseJSON { response in
                print(response.result.value as Any)
                print(response.debugDescription)
                
                
                if let user = AppUser.getUser() {
                    
                    user.status = (user.status == true) ? false: true;
                    AppUser.setUser(user: user)
                }
                let startOfDay = Calendar.current.startOfDay(for: self.selectedDate).iso8601
                self.handymanNearbyCallingApi(date: startOfDay)
        }
    }
}
