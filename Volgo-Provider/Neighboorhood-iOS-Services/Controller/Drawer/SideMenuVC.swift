//
//  SideMenuTVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import Kingfisher

class MenuItem
{
    var title : String
    var icon : String
    var storyboardId : String
    var storyBoardName : String
    
    init()
    {
        self.title = ""
        self.icon = ""
        self.storyboardId = ""
        self.storyBoardName = ""
    }
    
    init(title : String, icon : String, storyboardId : String, storyBoardName : String = "Main") {
        
        self.title = title
        self.icon = icon
        self.storyboardId = storyboardId
        self.storyBoardName = storyBoardName
    }
}

class SideMenuVC: UITableViewController {

    var menuItems : [MenuItem]!
//    var userInfo : UserVO!
    var unreadCount = UserDefaults.standard.integer(forKey: DashboardVC.KEY_UNREAD_MESSAGES)
    let helpDesk = HelpdeskVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillMenuItems()
        userInfoGathering()
        SocketManager.shared.sendSocketRequest(name: SocketEvent.getUnreadMsgs, params: [:])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SideMenuVC.didReceiveUpdateProfileResponse), name: NSNotification.Name.KUpdateProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SideMenuVC.didReceiveUnreadMessageResponse), name: NSNotification.Name.kGetUnreadMsgs, object: nil)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fillMenuItems() {
        
        menuItems = [MenuItem]()
        menuItems.append(MenuItem(title: "Dashboard", icon: "home", storyboardId: "Dashboard_ID"))
        menuItems.append(MenuItem(title: "Messages", icon: "messages", storyboardId: "MessageList_ID"))
//        menuItems.append(MenuItem(title: "Job History", icon: "myjobs", storyboardId: "MyJobs_ID"))
        //menuItems.append(MenuItem(title: "Payments", icon: "payments", storyboardId: ""))
        menuItems.append(MenuItem(title: "Support", icon: "help", storyboardId: ""))
//        menuItems.append(MenuItem(title: "Invite Friends", icon: "invite", storyboardId: ""))
        menuItems.append(MenuItem(title: "Profile", icon: "Settings", storyboardId: "Profile_ID"))
        menuItems.append(MenuItem(title: "Logout", icon: "logout", storyboardId: ""))
    }
    
    func userInfoGathering() {
//        if AppUser.getUser() != nil {
//            userInfo = AppUser.getUser()
//        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            userInfoGathering()
            return 1
        }
        else
        {
            return menuItems.count
        }
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserNames") as! SideMenuTVC
            cell.selectionStyle = .none;
            
            if let user = AppUser.getUser() {
                
                cell.lblName.text = user.displayName
                cell.cosmosView.settings.fillMode = .precise
                cell.cosmosView.rating = user.rating!
                cell.cosmosView.text = String(describing: user.rating!.roundTo(places: 2))
                
                delayWithSeconds(0) {
                    
                    var newStr = user.profileImageURL!
                    newStr.remove(at: (newStr.startIndex))
                    cell.imgPerson.layer.borderWidth = 2.0
                    cell.imgPerson.layer.borderColor = UIColor.white.cgColor
                    cell.imgPerson.layer.cornerRadius = cell.imgPerson.frame.height/2
                    let imageURl = URLConfiguration.ServerUrl + newStr
                    if let url = URL(string: imageURl) {
//                        cell.imgPerson.kf.setImage(with: url, placeholder: UIImage(named: "addphoto"), options: nil, progressBlock: nil, completionHandler: nil)
                        
                        
                        cell.imgPerson.kf.setImage(
                                           with: url,
                                           placeholder: UIImage(named: "addphoto"),
                                           options: nil)
                                       {
                                           result in
                                           switch result {
                                           case .success(let value):
                                               print("Task done for: \(value.source.url?.absoluteString ?? "")")
                                           case .failure(let error):
                                               print("Job failed: \(error.localizedDescription)")
                                           }
                                       }
                        
                        
                    }
//                    DispatchQueue.global().async {
//                        if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
//                        {
//                            DispatchQueue.main.async {
//
//                                cell.imgPerson.image = UIImage(data: data)
//                            }
//                        }
//                    }
                }
                
            }
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SideMenuTVC
//            let view = UIView()
//            view.backgroundColor = UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1)
//            cell.selectedBackgroundView = view
            if indexPath.row == 1 && unreadCount != 0 {
                cell.countLbl.text = "\(unreadCount)"
                cell.countLbl.isHidden = false
            } else {
                cell.countLbl.isHidden = true
            }
            cell.lblMenuItems.text! = menuItems[indexPath.row].title
            cell.imgMenuItems.image = UIImage(named:  menuItems[indexPath.row].icon)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0
        {
            return 150
        }
        else
        {
            return 55
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.section == 0 && indexPath.row == 0)
        {
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: .gotoProfileNotification, object: nil)
            }
        }
        else
        {
            switch indexPath.row {
            case 0:
                
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: .gotoDashboardNotification, object: nil)
                }
            case 1:
                
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: .gotoMessagesNotification, object: nil)
                }
//            case 2:
//
//                self.dismiss(animated: true) {
//                    NotificationCenter.default.post(name: .gotoMyJobsNotification, object: nil)
//                }
//            case 3:
//
//                self.dismiss(animated: true) {
//                    NotificationCenter.default.post(name: .gotoPaymentNotification, object: nil)
//                }
            
            case 2:
                self.dismiss(animated: true) {
                        self.helpDesk.show()
                    }
//            case 4:
//                showProgressHud(viewController: self)
//                let shareText = "Download Topinup App: https://www.topinup.com"
//                let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
//                present(vc, animated: true)
//                hideProgressHud(viewController: self)
                
            case 3:
                
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: .gotoProfileNotification, object: nil)
                }
            case 4:
                let alertController = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to logout?", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Yes, Logout", style: .destructive, handler: { (action:UIAlertAction) in
                    
                    //SocketIOManager.sharedInstance.sendLogoutMessage()
                    self.dismiss(animated: true) {
                        SocketManager.shared.closeConnection()
                        SocketManager.shared.socket = nil
                        DataModel.shared.socketConnection = false
                        AppUser.clearAllUserData()
                        
                        let myAppDelegate = UIApplication.shared.delegate as? AppDelegate
                        myAppDelegate?.setLoginStoryBoardAsRoot()
                    }
                    
                    
                    
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action : UIAlertAction) in
                    
                    // Do Nothing
                    
                })
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            default:
                print("")
            }
        }
    }
 
    @objc func didReceiveUpdateProfileResponse(notification : Notification)
    {
        if let userInfo = notification.userInfo as? NSDictionary
        {
            
        }
    }
    
    @objc func didReceiveUnreadMessageResponse(notification : Notification)
    {
        if let userInfo = notification.userInfo as? NSDictionary
        {
            unreadCount = userInfo["count"] as? Int ?? 0
            UserDefaults.standard.set(userInfo["count"] as? Int ?? 0, forKey: DashboardVC.KEY_UNREAD_MESSAGES)
            UserDefaults.standard.synchronize()
            UIApplication.shared.applicationIconBadgeNumber = UserDefaults.standard.integer(forKey: DashboardVC.KEY_UNREAD_MESSAGES)
        }
    }

}
