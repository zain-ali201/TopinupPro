//
//  ProposedJobVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import Kingfisher

class ProposedJobVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var messageList = [MessageListVO]()
    let user = AppUser.getUser()
    var selectedJobID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "MessageList", bundle: nil), forCellReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProposedJobVC.didReceiveGetAllDisputesResponse(notification:)), name: NSNotification.Name.kGetMessageThreads, object: nil)
        
        
        self.tableView.reloadData()
        self.setupSideMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDisputesList()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getDisputesList() {
        
        if !Connection.isInternetAvailable()
        {
            Connection.showNetworkErrorView()
            return;
        }
        
        //let params = [:] as [String : Any]
        let params = ["userId": user?._id ?? ""] as [String : Any]
        SocketManager.shared.sendSocketRequest(name: SocketEvent.GetMessageThreads, params: params)
        showProgressHud(viewController: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! MessageListTVC
        cell.selectionStyle = .none
        
        cell.imgPerson.image = UIImage(named: "imagePlaceholder")
        if let newStr = self.messageList[indexPath.row].clientProfileImageURL {
            var uri = newStr
            uri.remove(at: (newStr.startIndex))
            let imageUrl = URLConfiguration.ServerUrl + uri
            if let url = URL(string: imageUrl) {
//                cell.imgPerson.kf.setImage(with: url, placeholder: UIImage(named: "addphoto"), options: nil, progressBlock: nil, completionHandler: nil)
                
                
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
//            cell.imgPerson.sd_setImage(with: URL(string: imageUrl)!)
        }
        
        cell.imgPerson.layer.cornerRadius = cell.imgPerson.frame.height/2
        cell.lblName.text = self.messageList[indexPath.row].clientDisplayName
        cell.lblCategory.text = self.messageList[indexPath.row].categoryName
        cell.lblLastMessage.text = self.messageList[indexPath.row].message
        
        let messageCount: Int = self.messageList[indexPath.row].msgCount
        
        cell.lablTotalMesage.isHidden = (messageCount == 0) ? true: false;
        
        
        cell.lablTotalMesage.text = "\(messageCount)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedJobID = messageList[indexPath.row].jobID
        
//        let chatView = ChatViewController()
//        chatView.messages = makeNormalConversation()
//        chatView.jobID = selectedJobID
//        let chatNavigationController = UINavigationController(rootViewController: chatView)
//        present(chatNavigationController, animated: true, completion: nil)
        
//        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailViewController") as! ChatDetailViewController
//        vc.threadInfo = messageList[indexPath.row]
//        vc.jobID = selectedJobID
//        vc.clientID = messageList[indexPath.row].clientID ?? ""
//        vc.msgThreadID = messageList[indexPath.row]._id
//        self.navigationController?.pushViewController(vc, animated: true)
        
        
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailViewController") as! ChatDetailViewController
        vc.threadInfo = messageList[indexPath.row]
        vc.jobID = messageList[indexPath.row].jobID ?? ""
        vc.providerID = messageList[indexPath.row].providerID ?? ""
        vc.clientName = messageList[indexPath.row].clientDisplayName ?? "Unknown"
        vc.clientID = messageList[indexPath.row].clientID ?? ""
        
        vc.clientImageURL = messageList[indexPath.row].clientProfileImageURL ?? ""
        vc.msgThreadID = messageList[indexPath.row]._id
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            removeJobConversation(self.messageList[indexPath.row]._id)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    @objc func didReceiveGetAllDisputesResponse(notification : Notification)
    {
        let userInfo = notification.userInfo! as NSDictionary
        
        
        let suc = userInfo.value(forKey: "isSuccess") as! Bool
        let msg = userInfo.value(forKey: "message") as! String
        hideProgressHud(viewController: self)
        
        if suc
        {
            if let queryDict = userInfo.object(forKey: "messagethreads") as? NSArray
            {
                self.messageList.removeAll()
                for item in queryDict
                {
                    let diputesDict = MessageListVO(dictionary: item as! NSDictionary)
                    messageList.append(diputesDict)
                }
                self.tableView.reloadData()
            } else {
                print("NOT")
            }
        }
        else
        {
            showInfoAlertWith(title: "Failed", message: msg)
        }
    }
    
    func removeJobConversation(_ id: String){
        
        if !Connection.isInternetAvailable()
        {
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = ["messagethreadId": id] as [String:Any]
        
        
        showProgressHud(viewController: self)
        Api.jobHistoryApi.removeJobCommunication(messageID: id, params: params, completion: { (success : Bool, message : String) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                      switch action.style{
                      case .default:
                        self.getDisputesList()

                      case .cancel:
                            print("cancel")

                      case .destructive:
                            print("destructive")


                }}))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                self.showInfoAlertWith(title: "Alert", message: message)
            }
        })
    }
}
