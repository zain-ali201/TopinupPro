//
//  MyJobsVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import FSCalendar


class MyJobsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewBarCurrentJob: UIView!
    @IBOutlet weak var viewBarHistory: UIView!
    @IBOutlet weak var btnCurrentJob: UIButton!
    @IBOutlet weak var btnHistory: UIButton!
    @IBOutlet weak var lblEmptyField: UILabel!
    
    @IBOutlet weak var FSCalendar: FSCalendar!
    @IBOutlet weak var heightConstraintCalendar: NSLayoutConstraint!
    
    
    var lightColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    var isCurrentJobActive = true
    
    //var allCurrentJobs = [HandymanNearbyVO]()
    var allHistoryJobs = [JobHistoryVO]()
    
    var completedJobs = [JobHistoryVO]()
    var cancelledJobs = [JobHistoryVO]()
    
    var selectiveJobID : String!
    var params : [String:Any]! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FSCalendar.scope = .week
        self.viewInitializer()
        
        let startOfDay = Calendar.current.startOfDay(for: Date()).iso8601
        self.callingHistoryJobsApi(date: startOfDay)
        FSCalendar.select(Date())
        self.setupSideMenu()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewInitializer() {
        
        if isCurrentJobActive
        {
            self.btnCurrentJob.setTitleColor(UIColor.white, for: .normal)
            self.btnHistory.setTitleColor(lightColor, for: .normal)
            self.viewBarCurrentJob.backgroundColor = UIColor.white
            self.viewBarHistory.backgroundColor = UIColor.clear
        }
        else
        {
            self.btnHistory.setTitleColor(UIColor.white, for: .normal)
            self.btnCurrentJob.setTitleColor(lightColor, for: .normal)
            self.viewBarHistory.backgroundColor = UIColor.white
            self.viewBarCurrentJob.backgroundColor = UIColor.clear
        }
        
        self.tableView.register(UINib(nibName: "JobList", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.reloadData()
    }
    
    func callingHistoryJobsApi(date : String) {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        print("Selected Date is : \(date)")
        self.params = ["created" : date] as [String:Any]
        
        showProgressHud(viewController: self)
        Api.jobDetailApi.jobHistoryWith(params: self.params, completion: { (success:Bool, message : String, jobHistory : [JobHistoryVO]?) in
            hideProgressHud(viewController: self)
            
            if success
            {
                if jobHistory != nil
                {
                    self.allHistoryJobs.removeAll()
                    self.completedJobs.removeAll()
                    self.cancelledJobs.removeAll()
                    
                    self.allHistoryJobs = jobHistory as! [JobHistoryVO]
                    
                    
                    print(self.allHistoryJobs)
                    
                    for i in self.allHistoryJobs {
                        
                        if i.status == JobStatus.completed.rawValue
                        {
                            self.completedJobs.append(i)
                        }
                        else if i.status == JobStatus.cancelled.rawValue
                        {
                            self.cancelledJobs.append(i)
                        }
                    }
                    self.tableView.reloadData()
                }
                else
                {
                    self.showInfoAlertWith(title: "Internal Error", message: "Logged In but user object not returned")
                }
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
 
    }
    
    @IBAction func btnCurrentJobAction(_ sender: Any) {
        isCurrentJobActive = true
        viewInitializer()
    }
    
    @IBAction func btnHistoryAction(_ sender: Any) {
        isCurrentJobActive = false
        viewInitializer()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isCurrentJobActive
        {
            if completedJobs.count == 0
            {
                lblEmptyField.isHidden = false
            }
            else
            {
                lblEmptyField.isHidden = true
            }
           
            return completedJobs.count
        }
        else
        {
            if cancelledJobs.count == 0
            {
                lblEmptyField.isHidden = false
            }
            else
            {
                lblEmptyField.isHidden = true
            }
            
            return cancelledJobs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! JobListTVC
        
        cell.imgClient.layer.cornerRadius = cell.imgClient.frame.height/2
        cell.selectionStyle = .none
        
        var currentIndex = JobHistoryVO()

        if isCurrentJobActive
        {
            currentIndex = completedJobs[indexPath.row]
        }
        else
        {
            currentIndex = cancelledJobs[indexPath.row]
        }
        
        cell.lblName.text = currentIndex.displayName
        cell.lblDateTime.text = DateUtil.getSimpleDateAndTime(currentIndex.when.dateFromISO8601!)
        cell.lblAddress.text = currentIndex.wheree
        cell.lblStatus.text = currentIndex.status.capitalized
        
        var newStr = currentIndex.profileImageURL!
        newStr.remove(at: (newStr.startIndex))
        let imageURl = URLConfiguration.ServerUrl + newStr
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
            {
                DispatchQueue.main.async {
                    cell.imgClient.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isCurrentJobActive
        {
            selectiveJobID = completedJobs[indexPath.row]._id
        }
        else
        {
            selectiveJobID = cancelledJobs[indexPath.row]._id
        }
        self.performSegue(withIdentifier: "JobHistoryToJobDetailSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        
        heightConstraintCalendar.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        self.callingHistoryJobsApi(date: date.iso8601)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? JobDetailVC {
            controller.jobID = selectiveJobID
            controller.isFromHistory = true
        }
    }
}
