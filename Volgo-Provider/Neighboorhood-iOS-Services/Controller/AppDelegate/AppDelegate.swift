//
//  AppDelegate.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 15/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import BRYXBanner
import UserNotifications
import Firebase
import IQKeyboardManagerSwift
import UserNotifications

extension Notification.Name {
    static let gotoProfileNotification = Notification.Name("gotoProfileNotification")
    static let gotoDashboardNotification = Notification.Name("gotoDashboardNotification")
    static let gotoMessagesNotification = Notification.Name("gotoMessagesNotification")
    static let gotoMyJobsNotification = Notification.Name("gotoMyJobsNotification")
    static let gotoPaymentNotification = Notification.Name("gotoPaymentNotification")
    static let gotoContactNotification = Notification.Name("gotoContactNotification")
    static let gotoSettingsNotification = Notification.Name("gotoSettingsNotification")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var isInBackground: Bool = false
    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(URLConfiguration.googleAPIKey)
        GMSPlacesClient.provideAPIKey(URLConfiguration.googleAPIKey)
        IQKeyboardManager.shared.enable = true
        addNotificationObservers()
        Connection.checkInternet()
        
        if AppUser.getUser() == nil
        {
            setLoginStoryBoardAsRoot()
        }
        else
        {
            setMainStoryBoardAsRoot()
        }
        
        registerForPushNotifications(application: application)
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound,.alert,.badge], categories: nil))
        
        if let remoteNotification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any]
        {
            print("application launched from push notification")
            self.application(application, didReceiveRemoteNotification: remoteNotification)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didReceiveClientNotificationResponse(notification:)), name: NSNotification.Name.KClientNotifications, object: nil)
        //setLoginStoryBoardAsRoot()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        isInBackground = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.applicationIconBadgeNumber = 0
        isInBackground = false
    }
    
    

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
        isInBackground = false
        
    }
    
    var jobBanner = Banner()
    var assignedJobBanner = Banner()
    var jobInfoFromAlert = JobHistoryVO()
    var section = String()
    
    
    static var isFromNotification = false
    static var subsection = String()
    
    @objc func didReceiveClientNotificationResponse(notification : Notification)
    {
        
        
        
        if let userInfo = notification.userInfo as? NSDictionary
        {
            var title = "Alert"
            
            //audio.play()
            print("LL-22\(userInfo)")
            let suc = userInfo.value(forKey: "isSuccess") as! Bool
            let msg = userInfo.value(forKey: "message") as! String
            
            if let sections = userInfo.value(forKey: "section") {
                section = sections as! String
            }
            
            if let titlee = userInfo.value(forKey: "title") {
                title = titlee as! String
            }
            
            if suc
            {
                //audio.play()
                
                if section == "messages" {
                    if let messagesDict = userInfo.value(forKey: "jobmessage") as? NSDictionary
                    {
                        let dic = messagesDict.value(forKey: "sender") as? NSDictionary
                        let message = messagesDict["message"] as? String ?? ""
                        let displayName = dic?.value(forKey: "displayName") as? String ?? ""
                        
                        let banner = Banner(title: msg, subtitle: "\(displayName): \(message)" , image: UIImage(named: "logo"), backgroundColor: UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1))
                        banner.dismissesOnTap = true
                        banner.dismissesOnSwipe = true
                        banner.textColor = UIColor.white
                        banner.didTapBlock = {
                            
                            let chatView = ChatDetailViewController()
                            chatView.messages = []
                            chatView.jobID = (userInfo.value(forKey: "jobId") as? String)!
                            chatView.providerID = (dic?.value(forKey: "_id") as? String)!
                            chatView.msgThreadID = (userInfo.value(forKey: "messagethreadId") as? String)!
                            let chatNavigationController = UINavigationController(rootViewController: chatView)
                            self.visibleViewController?.present(chatNavigationController, animated: true, completion: nil)
                            
                            
                           
                            
                           // NotificationCenter.default.post(name: .kGetUnreadMsgs2, object: nil, userInfo: nil)
                            
                        }
                        if !isInBackground {
                            banner.show(duration: 3.0)
                        } else {
                            self.scheduleNotification(title: msg, notificationType: "\(displayName): \(message)")
                        }
                        
                    }
                } else {
                    let job = userInfo["job"] as? NSDictionary ?? NSDictionary()
                    let user = job["client"] as? NSDictionary ?? NSDictionary()
                    let userName = user["displayName"] as? String ?? "User"
                    let category = job["category"] as? NSDictionary ?? NSDictionary()
                    title = category["name"] as? String ?? "Alert"
                    
                    assignedJobBanner = Banner(title: title, subtitle: msg.replacingOccurrences(of: "User", with: userName),  image: UIImage(named: "logo") , backgroundColor: UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1))
                    assignedJobBanner.dismissesOnTap = true
                    assignedJobBanner.dismissesOnSwipe = true
                    assignedJobBanner.textColor = UIColor.white
                    
                    if let job = userInfo.value(forKey: "job") as? NSDictionary
                    {
                        let jobInfo = JobHistoryVO(withJSON: job)
                        jobInfoFromAlert = jobInfo
                        print(jobInfo)
                    }
//                    if let date = jobInfoFromAlert.when?.dateFromISO8601 {
//                        NotificationCenter.default.post(name: .reloadDashboardJobs, object: nil)
//                    }
                    
                    NotificationCenter.default.post(name: .reloadDashboardJobs, object: nil)
                    if jobInfoFromAlert.status == JobStatus.onway.rawValue || jobInfoFromAlert.status == JobStatus.arrived.rawValue || jobInfoFromAlert.status == JobStatus.started.rawValue {
                        
                        if isAlreadyAttendingACall()
                        {
                            print("already in a call")
                            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ProviderOnTheWayVC_ID") as! ProviderOnTheWayVC
                            
                            let jobDataDict : [String: String] = ["jobInfoID": jobInfoFromAlert._id]
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "providerOnTheWay"), object: nil, userInfo: jobDataDict)
                            return;
                        }
                    }
                    else if jobInfoFromAlert.status == JobStatus.completed.rawValue
                    {
                        //                        if isAlreadyAttendingACall()
                        //                        {
                        //                            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
                        //                            vc.jobID = jobInfoFromAlert._id
                        //
                        //                            if let navController = UIApplication.topViewController()?.navigationController
                        //                            {
                        //                                navController.pushViewController(vc, animated: true)
                        //                            }
                        //                            return;
                        //                        }
                        let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
                        vc.jobDetail = jobInfoFromAlert
                        vc.modalPresentationStyle = .fullScreen
                        if let navController = UIApplication.topViewController()
                        {
                            navController.present(vc, animated: true, completion: nil)
                        }
                        return;
                    }
                    if !isInBackground {
                        assignedJobBanner.show(duration: 3.0)
                    } else {
                        self.scheduleNotification(title: title, notificationType: msg.replacingOccurrences(of: "User", with: userName))
                    }
                    
                    
                    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AppDelegate.addGestureRecognizers))
                    assignedJobBanner.addGestureRecognizer(tap)
                }
            }
            else
            {
                
            }
        }
    }
    
    var visibleViewController: UIViewController? {
        let rootViewController: UIViewController? = window!.rootViewController
        return getVisibleViewController(from: rootViewController)
    }
    
    func getVisibleViewController(from vc: UIViewController?) -> UIViewController? {
        if (vc is UINavigationController) {
            return getVisibleViewController(from: (vc as? UINavigationController)?.visibleViewController)
        } else if (vc is UITabBarController) {
            return getVisibleViewController(from: (vc as? UITabBarController)?.selectedViewController)
        } else {
            if vc?.presentedViewController != nil {
                return getVisibleViewController(from: vc?.presentedViewController)
            } else {
                return vc
            }
        }
    }
    
//    @objc func didReceiveClientNotificationResponse(notification : Notification)
//    {
//        var title = "New Job Offer"
//
//        if let userInfo = notification.userInfo as? NSDictionary
//        {
//            //audio.play()
//            print("LL-22\(userInfo)")
//            let suc = userInfo.value(forKey: "isSuccess") as! Bool
//            let msg = userInfo.value(forKey: "message") as! String
//
//            if let titlee = userInfo.value(forKey: "title") {
//                title = titlee as! String
//            }
//
//            if let section = userInfo.value(forKey: "section") {
//                self.section = section as! String
//            }
//
//            if let subsection = userInfo.value(forKey: "subsection") {
//                AppDelegate.subsection = subsection as! String
//            }
//
//
//            if suc
//            {
//                jobBanner = Banner(title: title, subtitle: msg,  image: UIImage(named: "assignedjobicon") , backgroundColor: UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1))
//                jobBanner.dismissesOnTap = true
//                jobBanner.dismissesOnSwipe = true
//                jobBanner.textColor = UIColor.white
//                if !isInBackground {
//                    jobBanner.show(duration: 6.0)
//                } else {
//                    self.scheduleNotification(title: title, notificationType: msg)
//                }
//
//                let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AppDelegate.addGestureRecognizers))
//                jobBanner.addGestureRecognizer(tap)
//
//                if let job = userInfo.value(forKey: "job") as? NSDictionary
//                {
//                    let jobInfo = JobVO(withJSON: job)
//                    jobInfoFromAlert = jobInfo
//                    print(jobInfo)
//
//                }
//
//                if let type = userInfo.value(forKey: "type") as? String
//                {
//                    if type == "message"
//                    {
//
//                        let jobID = userInfo.value(forKey: "jobId") as? String
//                        let messagethreadId = userInfo.value(forKey: "messagethreadId") as? String
//                        let section = userInfo.value(forKey: "section") as? String
//                        let subsection = userInfo.value(forKey: "subsection") as? String
//
//                        print(jobID)
//                        print(messagethreadId)
//                        print(section)
//                        print(subsection)
//
//
//
//                        if let message = userInfo.value(forKey: "jobmessage") as? NSDictionary
//                        {
//                            let id = message["_id"] as! String
//                            print(id)
//
//                        }
//
//                    }
//                    else if type == "job" {
//
//                        if section == "" {
//
//                        }
//                        else
//                        {
//                            if AppUser.getUser() == nil
//                            {
//                                setLoginStoryBoardAsRoot()
//                            }
//                            else
//                            {
//                                if section == "providerhome" {
//                                    AppDelegate.isFromNotification = true
//                                    setMainStoryBoardAsRoot()
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            else
//            {
//
//            }
//
//        }
//    }
    
    @objc func addGestureRecognizers() {
        
        print("Banner tapped")
        jobBanner.isHidden = true
        
        if section == "" {
            
        }
        else
        {
            if AppUser.getUser() == nil
            {
                setLoginStoryBoardAsRoot()
            }
            else
            {
                if section == "providerhome" {
                    setMainStoryBoardAsRoot()
                }
            }
        }
        
        
//        if jobInfoFromAlert.jobStatus == JobStatus.onway.rawValue || jobInfoFromAlert.jobStatus == JobStatus.arrived.rawValue || jobInfoFromAlert.jobStatus == JobStatus.started.rawValue {
//
//            if isAlreadyAttendingACall()
//            {
//                print("already in a call")
//                let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ProviderOnTheWayVC_ID") as! ProviderOnTheWayVC
//                //                            vc.jobInfo = JobVO()
//                //                            vc.jobInfo = jobInfo
//
//                let jobDataDict : [String: JobVO] = ["jobInfo": jobInfoFromAlert]
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "providerOnTheWay"), object: nil, userInfo: jobDataDict)
//                return;
//            }
//
//            //                        let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ProviderOnTheWayVC_ID") as! ProviderOnTheWayVC
//            //                        vc.jobInfo = jobInfo
//            //
//            //                        if let navController = UIApplication.topViewController()?.navigationController
//            //                        {
//            //                            navController.pushViewController(vc, animated: true)
//            //                        }
//
//        }
//
//
//        else if jobInfoFromAlert.jobStatus == JobStatus.completed.rawValue {
//
////            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
//////            vc.jobDetail = jobInfoFromAlert
////
////            if let navController = UIApplication.topViewController()?.navigationController
////            {
////                navController.pushViewController(vc, animated: true)
////            }
//        }
    }
    

    func isAlreadyAttendingACall() -> Bool
    {
        let topController = UIApplication.topViewController()
        
        if let _ = topController as? ProviderOnTheWayVC
        {
            return true
        }
        
        return false
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("terminate")
        
    }
    
    func setLoginStoryBoardAsRoot ()
    {
        loadViewControllerWith(identifier: "MainLogin_ID", inStoryBoard: "Login")
    }
    
    func setMainStoryBoardAsRoot ()
    {
        loadViewControllerWith(identifier: "Dashboard_ID", inStoryBoard: "Main")
    }
    
    func loadViewControllerWith( identifier : String,  inStoryBoard : String)
    {
        let storyboard = UIStoryboard(name: inStoryBoard, bundle: nil)
        let initViewController = storyboard.instantiateViewController(withIdentifier: identifier)
        self.window?.rootViewController = initViewController
        self.window?.makeKeyAndVisible()
    }
    
    func registerForPushNotifications( application : UIApplication)
    {
//        // iOS 10 support
//        if #available(iOS 10, *) {
//            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
//            application.registerForRemoteNotifications()
//        }
//            // iOS 9 support
//        else if #available(iOS 9, *) {
//            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
//            UIApplication.shared.registerForRemoteNotifications()
//        }
//            // iOS 8 support
//        else if #available(iOS 8, *) {
//            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
//            UIApplication.shared.registerForRemoteNotifications()
//        }
//            // iOS 7 support
//        else {
//            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
//        }
        
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        //FirebaseApp.configure()
        
    }
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        DataModel.shared.deviceToken = deviceTokenString
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // Persist it so it can be sent to server later on socket connection
        AppUser.setToken(token: deviceTokenString)
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        // print(userInfo)
        print("push notification payload \(userInfo)")
        
        if AppUser.getUser() == nil
        {
            return
        }
        
        if (application.applicationState == .active)
        {
            if let infoDict = userInfo["data"] as? NSDictionary
            {
                // First, only driver notifications were being sent via push
                // Now, other types are also being sent from server so handling here
            }
        }
        else
        {
            if let pendingAction = userInfo["data"] as? NSDictionary
            {
                let type = pendingAction.value(forKey: "type") as! String
            }
        }
    }


}

extension AppDelegate {
    func addNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoProfileNotification(_:)), name: .gotoProfileNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoDashboardNotification(_:)), name: .gotoDashboardNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoMyJobsNotification(_:)), name: .gotoMyJobsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoMessagesNotification(_:)), name: .gotoMessagesNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoPaymentNotification(_:)), name: .gotoPaymentNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoContactNotification(_:)), name: .gotoContactNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoSettingsNotification(_:)), name: .gotoSettingsNotification, object: nil)
    }
    
    @objc func gotoProfileNotification(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Profile_ID")
        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoDashboardNotification(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Dashboard_ID")
        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoMyJobsNotification(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyJobs_ID")
        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoMessagesNotification(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MessageList_ID")
        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoPaymentNotification(_ notification: Notification) {
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "MyJobs_ID")
        //        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoContactNotification(_ notification: Notification) {
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "Dashboard_ID")
        //        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoSettingsNotification(_ notification: Notification) {
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "MyJobs_ID")
        //        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    func switchRootViewController(rootViewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let win = window else {
            return
        }
        if animated {
            UIView.transition(with: win, duration: 0.25, options: .transitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                win.rootViewController = rootViewController
                UIView.setAnimationsEnabled(oldState)
            }, completion: { (finished: Bool) -> () in
                if (completion != nil) {
                    completion!()
                }
            })
        } else {
            win.rootViewController = rootViewController
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let _userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        
        if let badgeString = _userInfo["badge"] as? String, let badge = Int(badgeString) {
            UIApplication.shared.applicationIconBadgeNumber = badge
        }
        else if let badge = _userInfo["badge"] as? Int {
            UIApplication.shared.applicationIconBadgeNumber = badge
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        //        if let aps = userInfo["aps"] as? NSDictionary , let alert = aps["alert"] as? NSDictionary, let title = alert["title"] as? String {
        //
        //            let body = alert["body"] as? String
        //
        //            if title == "New message received" {
        //                //                print("New Message received")
        //                MessageManager.shared.didReceivedMessageNotification(userInfo: userInfo, messageTitle: body, openMessage: false)
        //            } else {
        //                NotificationManager.shared.didReceivedNotification(userInfo: userInfo, messageTitle: body, openNotification: false)
        //            }
        //        }
        
        // Print full message.
        //print(userInfo)
        
        
        
        if let userInfo = _userInfo as? NSDictionary
                {
                    var title = "Alert"
                    
                    //audio.play()
                    print("LL-22\(userInfo)")
                    let suc = userInfo.value(forKey: "isSuccess") as! Bool
                    let msg = userInfo.value(forKey: "message") as! String
                    
                    if let sections = userInfo.value(forKey: "section") {
                        section = sections as! String
                    }
                    
                    if let titlee = userInfo.value(forKey: "title") {
                        title = titlee as! String
                    }
                    
                    if suc
                    {
                        //audio.play()
                        
                        if section == "messages" {
                            if let messagesDict = userInfo.value(forKey: "jobmessage") as? NSDictionary
                            {
                                let dic = messagesDict.value(forKey: "sender") as? NSDictionary
                                let message = messagesDict["message"] as? String ?? ""
                                let displayName = dic?.value(forKey: "displayName") as? String ?? ""
                                
                                let banner = Banner(title: msg, subtitle: "\(displayName): \(message)" , image: UIImage(named: "logo"), backgroundColor: UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1))
                                banner.dismissesOnTap = true
                                banner.dismissesOnSwipe = true
                                banner.textColor = UIColor.white
                                banner.didTapBlock = {
                                    
                                    let chatView = ChatDetailViewController()
                                    chatView.messages = []
                                    chatView.jobID = (userInfo.value(forKey: "jobId") as? String)!
                                    chatView.providerID = (dic?.value(forKey: "_id") as? String)!
                                    chatView.msgThreadID = (userInfo.value(forKey: "messagethreadId") as? String)!
                                    let chatNavigationController = UINavigationController(rootViewController: chatView)
                                    self.visibleViewController?.present(chatNavigationController, animated: true, completion: nil)
                                    
                                    
                                   
                                    
                                   // NotificationCenter.default.post(name: .kGetUnreadMsgs2, object: nil, userInfo: nil)
                                    
                                }
                                if !isInBackground {
                                    banner.show(duration: 3.0)
                                } else {
                                    self.scheduleNotification(title: msg, notificationType: "\(displayName): \(message)")
                                }
                                
                            }
                        } else {
                            let job = userInfo["job"] as? NSDictionary ?? NSDictionary()
                            let user = job["client"] as? NSDictionary ?? NSDictionary()
                            let userName = user["displayName"] as? String ?? "User"
                            let category = job["category"] as? NSDictionary ?? NSDictionary()
                            title = category["name"] as? String ?? "Alert"
                            
                            assignedJobBanner = Banner(title: title, subtitle: msg.replacingOccurrences(of: "User", with: userName),  image: UIImage(named: "logo") , backgroundColor: UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1))
                            assignedJobBanner.dismissesOnTap = true
                            assignedJobBanner.dismissesOnSwipe = true
                            assignedJobBanner.textColor = UIColor.white
                            
                            if let job = userInfo.value(forKey: "job") as? NSDictionary
                            {
                                let jobInfo = JobHistoryVO(withJSON: job)
                                jobInfoFromAlert = jobInfo
                                print(jobInfo)
                            }
        //                    if let date = jobInfoFromAlert.when?.dateFromISO8601 {
        //                        NotificationCenter.default.post(name: .reloadDashboardJobs, object: nil)
        //                    }
                            
                            NotificationCenter.default.post(name: .reloadDashboardJobs, object: nil)
                            if jobInfoFromAlert.status == JobStatus.onway.rawValue || jobInfoFromAlert.status == JobStatus.arrived.rawValue || jobInfoFromAlert.status == JobStatus.started.rawValue {
                                
                                if isAlreadyAttendingACall()
                                {
                                    print("already in a call")
                                    let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ProviderOnTheWayVC_ID") as! ProviderOnTheWayVC
                                    
                                    let jobDataDict : [String: String] = ["jobInfoID": jobInfoFromAlert._id]
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "providerOnTheWay"), object: nil, userInfo: jobDataDict)
                                    return;
                                }
                            }
                            else if jobInfoFromAlert.status == JobStatus.completed.rawValue
                            {
                                //                        if isAlreadyAttendingACall()
                                //                        {
                                //                            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
                                //                            vc.jobID = jobInfoFromAlert._id
                                //
                                //                            if let navController = UIApplication.topViewController()?.navigationController
                                //                            {
                                //                                navController.pushViewController(vc, animated: true)
                                //                            }
                                //                            return;
                                //                        }
                                let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
                                vc.jobDetail = jobInfoFromAlert
                                vc.modalPresentationStyle = .fullScreen
                                if let navController = UIApplication.topViewController()
                                {
                                    navController.present(vc, animated: true, completion: nil)
                                }
                                return;
                            }
                            if !isInBackground {
                                assignedJobBanner.show(duration: 3.0)
                            } else {
                                self.scheduleNotification(title: title, notificationType: msg.replacingOccurrences(of: "User", with: userName))
                            }
                            
                            
                            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AppDelegate.addGestureRecognizers))
                            assignedJobBanner.addGestureRecognizer(tap)
                        }
                    }
                    else
                    {
                        
                    }
                }
        
        
        
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let _userInfo = response.notification.request.content.userInfo
        
        if let badge = _userInfo["badge"] as? String {
            UIApplication.shared.applicationIconBadgeNumber = Int(badge)!
        }
        else if let badge = _userInfo["badge"] as? Int {
            UIApplication.shared.applicationIconBadgeNumber = badge
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        //        if let aps = userInfo["aps"] as? NSDictionary , let alert = aps["alert"] as? NSDictionary, let title = alert["title"] as? String {
        //
        //            let body = alert["body"] as? String
        //
        //            if title == "New message received" {
        //                MessageManager.shared.didReceivedMessageNotification(userInfo: userInfo, messageTitle: body, openMessage: true)
        //            } else {
        //                NotificationManager.shared.didReceivedNotification(userInfo: userInfo, messageTitle: body, openNotification: true)
        //            }
        //
        //        }
        
        // Print full message.
         if let userInfo = _userInfo as? NSDictionary
                       {
                           var title = "Alert"
                           
                           //audio.play()
                           print("LL-22\(userInfo)")
                           let suc = userInfo.value(forKey: "isSuccess") as! Bool
                           let msg = userInfo.value(forKey: "message") as! String
                           
                           if let sections = userInfo.value(forKey: "section") {
                               section = sections as! String
                           }
                           
                           if let titlee = userInfo.value(forKey: "title") {
                               title = titlee as! String
                           }
                           
                           if suc
                           {
                               //audio.play()
                               
                               if section == "messages" {
                                   if let messagesDict = userInfo.value(forKey: "jobmessage") as? NSDictionary
                                   {
                                       let dic = messagesDict.value(forKey: "sender") as? NSDictionary
                                       let message = messagesDict["message"] as? String ?? ""
                                       let displayName = dic?.value(forKey: "displayName") as? String ?? ""
                                       
                                       let banner = Banner(title: msg, subtitle: "\(displayName): \(message)" , image: UIImage(named: "logo"), backgroundColor: UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1))
                                       banner.dismissesOnTap = true
                                       banner.dismissesOnSwipe = true
                                       banner.textColor = UIColor.white
                                       banner.didTapBlock = {
                                           
                                           let chatView = ChatDetailViewController()
                                           chatView.messages = []
                                           chatView.jobID = (userInfo.value(forKey: "jobId") as? String)!
                                           chatView.providerID = (dic?.value(forKey: "_id") as? String)!
                                           chatView.msgThreadID = (userInfo.value(forKey: "messagethreadId") as? String)!
                                           let chatNavigationController = UINavigationController(rootViewController: chatView)
                                           self.visibleViewController?.present(chatNavigationController, animated: true, completion: nil)
                                           
                                           
                                          
                                           
                                          // NotificationCenter.default.post(name: .kGetUnreadMsgs2, object: nil, userInfo: nil)
                                           
                                       }
                                       if !isInBackground {
                                           banner.show(duration: 3.0)
                                       } else {
                                           self.scheduleNotification(title: msg, notificationType: "\(displayName): \(message)")
                                       }
                                       
                                   }
                               } else {
                                   let job = userInfo["job"] as? NSDictionary ?? NSDictionary()
                                   let user = job["client"] as? NSDictionary ?? NSDictionary()
                                   let userName = user["displayName"] as? String ?? "User"
                                   let category = job["category"] as? NSDictionary ?? NSDictionary()
                                   title = category["name"] as? String ?? "Alert"
                                   
                                   assignedJobBanner = Banner(title: title, subtitle: msg.replacingOccurrences(of: "User", with: userName),  image: UIImage(named: "logo") , backgroundColor: UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1))
                                   assignedJobBanner.dismissesOnTap = true
                                   assignedJobBanner.dismissesOnSwipe = true
                                   assignedJobBanner.textColor = UIColor.white
                                   
                                   if let job = userInfo.value(forKey: "job") as? NSDictionary
                                   {
                                       let jobInfo = JobHistoryVO(withJSON: job)
                                       jobInfoFromAlert = jobInfo
                                       print(jobInfo)
                                   }
               //                    if let date = jobInfoFromAlert.when?.dateFromISO8601 {
               //                        NotificationCenter.default.post(name: .reloadDashboardJobs, object: nil)
               //                    }
                                   
                                   NotificationCenter.default.post(name: .reloadDashboardJobs, object: nil)
                                   if jobInfoFromAlert.status == JobStatus.onway.rawValue || jobInfoFromAlert.status == JobStatus.arrived.rawValue || jobInfoFromAlert.status == JobStatus.started.rawValue {
                                       
                                       if isAlreadyAttendingACall()
                                       {
                                           print("already in a call")
                                           let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ProviderOnTheWayVC_ID") as! ProviderOnTheWayVC
                                           
                                           let jobDataDict : [String: String] = ["jobInfoID": jobInfoFromAlert._id]
                                           NotificationCenter.default.post(name: Notification.Name(rawValue: "providerOnTheWay"), object: nil, userInfo: jobDataDict)
                                           return;
                                       }
                                   }
                                   else if jobInfoFromAlert.status == JobStatus.completed.rawValue
                                   {
                                       //                        if isAlreadyAttendingACall()
                                       //                        {
                                       //                            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
                                       //                            vc.jobID = jobInfoFromAlert._id
                                       //
                                       //                            if let navController = UIApplication.topViewController()?.navigationController
                                       //                            {
                                       //                                navController.pushViewController(vc, animated: true)
                                       //                            }
                                       //                            return;
                                       //                        }
                                       let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
                                       vc.jobDetail = jobInfoFromAlert
                                       vc.modalPresentationStyle = .fullScreen
                                       if let navController = UIApplication.topViewController()
                                       {
                                           navController.present(vc, animated: true, completion: nil)
                                       }
                                       return;
                                   }
                                   if !isInBackground {
                                       assignedJobBanner.show(duration: 3.0)
                                   } else {
                                       self.scheduleNotification(title: title, notificationType: msg.replacingOccurrences(of: "User", with: userName))
                                   }
                                   
                                   
                                   let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AppDelegate.addGestureRecognizers))
                                   assignedJobBanner.addGestureRecognizer(tap)
                               }
                           }
                           else
                           {
                               
                           }
                       }
        
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

//extension AppDelegate : MessagingDelegate {
//    // [START refresh_token]
//    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//
//        //        let preferences = UserDefaults.standard
//        //        preferences.set(fcmToken, forKey: TalUtility.shared.fcmTokenKey)
//        //        preferences.synchronize()
//        //
//        //        NetworkManager.updateFirebaseToken()
//
//    }
//    // [END refresh_token]
//    // [START ios_10_data_message]
//    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
//    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print("Received data message: \(remoteMessage.appData)")
//    }
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//
//        //        let preferences = UserDefaults.standard
//        //        preferences.set(fcmToken, forKey: TalUtility.shared.fcmTokenKey)
//        //        preferences.synchronize()
//        //
//        //        NetworkManager.updateFirebaseToken()
//    }
//    // [END ios_10_data_message]
//}

extension AppDelegate {
    //MARK: Local Notification Methods Starts here
    
    //Prepare New Notificaion with deatils and trigger
    
    func scheduleNotification(title: String, notificationType: String) {
        if !self.isRegisteredForRemoteNotifications() {
            return
        }
        //Compose New Notificaion
        let content = UNMutableNotificationContent()
        let categoryIdentifire = "Delete Notification Type"
        content.title = title
        content.sound = UNNotificationSound.default
        content.body = notificationType
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        //Add attachment for Notification with more content
        if (notificationType == "Local Notification with Content")
        {
            let imageName = "Apple"
            guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
            let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        //Add Action button the Notification
        if (notificationType == "Local Notification with Action")
        {
            let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
            let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
            let category = UNNotificationCategory(identifier: categoryIdentifire,
                                                  actions: [snoozeAction, deleteAction],
                                                  intentIdentifiers: [],
                                                  options: [])
            notificationCenter.setNotificationCategories([category])
        }
    }
    
    func isRegisteredForRemoteNotifications() -> Bool {
        if #available(iOS 10.0, *) {
            var isRegistered = false
            let semaphore = DispatchSemaphore(value: 0)
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus != .authorized {
                    isRegistered = false
                } else {
                    isRegistered = true
                }
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: .now() + 5)
            return isRegistered
        } else {
            return UIApplication.shared.isRegisteredForRemoteNotifications
        }
    }
}
