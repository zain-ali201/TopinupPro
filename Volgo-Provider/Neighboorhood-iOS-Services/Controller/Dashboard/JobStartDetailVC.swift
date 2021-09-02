//
//  JobStartDetailVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import MapKit
import STZPopupView

enum JobType : String {
    case hourly = "hourly"
    case fixed = "fixed"
}

enum TimerState : String {
    case play = "play"
    case pause = "pause"
    case reset = "reset"
    case stop = "stop"
}

class JobStartDetailVC: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var btnBarRight: UIButton!
    @IBOutlet weak var imgClient: UIImageView!
    @IBOutlet weak var lblClientName: UILabel!
    @IBOutlet weak var lblClientAddress: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblScheduled: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewUpdateQuote: UIView!
    @IBOutlet weak var btnUpdateQuote: UIButton!
    @IBOutlet weak var btnWithdraw: UIButton!
    @IBOutlet weak var viewPrimaryStartWork: UIView!
    @IBOutlet weak var btnPrimaryStartWork: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerScrollView: UIView!
    
    @IBOutlet var clientDetailView: UIView!
    @IBOutlet weak var viewRate: UIView!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var viewBackgroundTextView: UIView!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var btnContact: UIButton!
    @IBOutlet weak var lblHourlyFixed: UILabel!
    
    @IBOutlet weak var viewBackgroundMapView: UIView!
    
    @IBOutlet weak var imgMapMarker: UIImageView!
    
    @IBOutlet weak var heightConstraintTimer: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintsMap: NSLayoutConstraint!
    @IBOutlet weak var viewBackgroundTimer: UIView!
    
    @IBOutlet weak var heightConstraintJobDetailScroll: NSLayoutConstraint!
    @IBOutlet weak var lblTimer: UILabel!
    
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    
    @IBOutlet weak var btnEnRoute: UIButton!
    
    var region = MKCoordinateRegion()
    
    var jobType : JobType!
    var timerState : TimerState!
    
    var jobDetail : JobHistoryVO!
    var proposedJobDetail : ProposedJobVO!
    
    var jobID : String!
    var imagesCells = [String]()
    var latitude : Double!
    var longitude : Double!
    
    var isTripStarted = false
    var isFromProposed = false
    
    var timer = Timer()
    var count = 0
    var totalTime = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupReportButton()
        self.viewInitializer()
        count = getJobTime()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func appMovedToBackground()
    {
        if timer.isValid
        {
            UserDefaults.standard.set(Date(), forKey: "lastDate")
        }
        else
        {
            UserDefaults.standard.set(nil, forKey: "lastDate")
        }
    }
    
    @objc func appMovedToForeground()
    {
        if timer.isValid
        {
            let date = UserDefaults.standard.object(forKey: "lastDate") as! Date
            let elapsed = Date().timeIntervalSince(date)
            count += Int(elapsed)
        }
        else
        {
            UserDefaults.standard.set(nil, forKey: "lastDate")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveJobTime()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        saveJobTime()
    }
    
    func setupReportButton(){
        let reportButton = UIButton()
        reportButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        reportButton.setImage(UIImage(named: "report"), for: .normal)
        reportButton.addTarget(self, action: #selector(self.reportThis), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButton)
    }
    
    @objc func reportThis(){
        
        let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReportVC_ID") as! ReportVC
        vc.jobInfo      = self.jobDetail
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func viewInitializer() {
        
        self.btnUpdateQuote.layer.cornerRadius = self.btnUpdateQuote.frame.height/2
        self.btnWithdraw.layer.cornerRadius = self.btnWithdraw.frame.height/2
        self.btnPrimaryStartWork.layer.cornerRadius = self.btnPrimaryStartWork.frame.height/2
        self.btnContact.layer.cornerRadius = self.btnContact.frame.height/2
        self.btnEnRoute.layer.cornerRadius = self.btnEnRoute.frame.height/2
        
        self.btnPrimaryStartWork = addButtonShadow(button: self.btnPrimaryStartWork)
        self.btnContact = addButtonShadow(button: self.btnContact)
        
        if isFromProposed
        {
            self.viewPrimaryStartWork.isHidden = true
            self.viewUpdateQuote.isHidden = false
            self.view.layoutIfNeeded()
            callApijobQuotationDetail()
        }
        else
        {
            
            self.viewPrimaryStartWork.isHidden = false
            self.viewUpdateQuote.isHidden = true
            self.view.layoutIfNeeded()
            callApijobDetail()
        }
        
        self.mapView.isUserInteractionEnabled = false
        
        self.heightConstraintTimer.constant = 0
        self.viewBackgroundTimer.isHidden = true
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
        clientDetailView.addGestureRecognizer(tap)
        
    }
    
    @objc func viewProfile(_ sender: UITapGestureRecognizer? = nil) {
        
        
        
        if let vcs = self.navigationController?.viewControllers {
            
            for previousVC in vcs {
                if previousVC is ProfileViewController {
                    self.navigationController!.popToViewController(previousVC, animated: true)
                    return
                }
            }
            

        }
        
        
        
        // handling code
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.clientID = self.jobDetail.clientID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func reloadViewJobDetails() {
        
        self.lblClientName.text = self.jobDetail.displayName
        self.lblClientAddress.text = self.jobDetail.wheree
        self.latitude = self.jobDetail.latitude
        self.longitude = self.jobDetail.longitude
        
        if self.jobDetail.type == JobType.hourly.rawValue
        {
            self.lblRate.text = (self.jobDetail.currency)+" "+String(describing: self.jobDetail.budget!) + "/hr"
            self.lblHourlyFixed.text = "Job Rate"
            jobType = JobType(rawValue: JobType.hourly.rawValue)
        }
        else if self.jobDetail.type == JobType.fixed.rawValue
        {
            self.lblRate.text = (self.jobDetail.currency)+" "+String(describing: self.jobDetail.budget!)
            self.lblHourlyFixed.text = "Fixed Job Rate"
            jobType = JobType(rawValue: JobType.fixed.rawValue)
        }
        
        self.lblScheduled.text = DateUtil.getSimpleDateAndTime(self.jobDetail.when.dateFromISO8601!)
        
        var height = heightForView(text: self.jobDetail.details, font: UIFont.systemFont(ofSize: 13.0), width: UIScreen.main.bounds.width - 80)
        height = height + 150
        
        self.txtViewDescription.text = self.jobDetail.details
        
        self.heightConstraintJobDetailScroll.constant = height
        self.imagesCells = self.jobDetail.images
        
//        let data = setImageWithUrl(url: self.jobDetail.categoryImageURL)
//
//        DispatchQueue.main.async {
//            self.imgClient.layer.cornerRadius = self.imgClient.frame.height/2
//            //self.imgClient.image = UIImage(data: data!)
//        }
        
        self.imgClient.layer.cornerRadius = self.imgClient.frame.height/2
        
        
        
        var newStr = self.jobDetail.profileImageURL!
        var imageUrl = ""
        if(!newStr.isEmpty){
            newStr.remove(at: (newStr.startIndex))
            imageUrl = URLConfiguration.ServerUrl + newStr
            
            if let url = URL(string: imageUrl) {
                //self.userImageView.kf.setImage(with: url)
                
                self.imgClient.kf.setImage(with: url, placeholder: UIImage(named: "imagePlaceholder"), options: nil, progressBlock: nil) { (image, error, cacheTyle, uurl) in
                    //                    self.userBtn.setImage(image, for: .normal)
                }
                
            }
        }
        
        
        
        
       /* if(!imageURl.isEmpty){
            
            
            self.imgClient.kf.setImage(with: imageURl, placeholder: UIImage(named: "imagePlaceholder"), options: nil, progressBlock: nil) { (image, error, cacheTyle, uurl) in
                //                    self.userBtn.setImage(image, for: .normal)
            }
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
                {
                    DispatchQueue.main.async {
                       // self.imgClient.image = UIImage(data: data)
                        
                        
                        
                    }
                }
            }
        }
        
        */
        
        
        
        self.setPrimaryButtonActionTitle()
        self.setViewTimer()
        
        self.setMapCentred(aroundLocation: self.jobDetail.coordinaate!)
        self.collectionView.reloadData()
        
        self.view.layoutIfNeeded()
    }
    
    func setPrimaryButtonActionTitle() {
        
        if self.jobDetail.status == JobStatus.accepted.rawValue
        {
            self.btnPrimaryStartWork.setTitle("On Way", for: .normal)
            timerState = TimerState(rawValue: TimerState.stop.rawValue)
            self.btnPlayPause.setImage(UIImage(named: "play") , for: .normal)
        }
        else if self.jobDetail.status == JobStatus.onway.rawValue
        {
            self.btnPrimaryStartWork.setTitle("Arrive", for: .normal)
            timerState = TimerState(rawValue: TimerState.stop.rawValue)
            self.btnPlayPause.setImage(UIImage(named: "play") , for: .normal)
        }
        else if self.jobDetail.status == JobStatus.arrived.rawValue
        {
            self.btnPrimaryStartWork.setTitle("Start", for: .normal)
            timerState = TimerState(rawValue: TimerState.stop.rawValue)
            self.btnPlayPause.setImage(UIImage(named: "play") , for: .normal)
        }
        else if self.jobDetail.status == JobStatus.started.rawValue
        {
            self.btnPrimaryStartWork.setTitle("End Job", for: .normal)
            timerState = TimerState(rawValue: TimerState.pause.rawValue)
            self.btnPlayPause.setImage(UIImage(named: "play") , for: .normal)
        }
        else if self.jobDetail.status == JobStatus.completed.rawValue
        {
            self.totalTime = self.lblTimer.text!
            
            timerState = TimerState(rawValue: TimerState.pause.rawValue)
            self.btnPlayPause.setImage(UIImage(named: "play") , for: .normal)
            self.performSegue(withIdentifier: "jobStartReceiptSegue", sender: nil)
        }
        
        self.viewAccordingToJobType()
    }
    
    func viewAccordingToJobType() {
        
        if self.jobDetail.status == JobStatus.started.rawValue || self.jobDetail.status == JobStatus.completed.rawValue
        {
            if jobType.rawValue == JobType.hourly.rawValue
            {
                self.heightConstraintsMap.constant = 0
                self.mapView.isHidden = true
                self.btnEnRoute.isHidden = true
                self.imgMapMarker.isHidden = true
                self.heightConstraintTimer.constant = 44
                self.viewBackgroundTimer.isHidden = false
                playPauseAction()
                
            }
            else if jobType.rawValue == JobType.fixed.rawValue
            {
                self.heightConstraintsMap.constant = 130
                self.mapView.isHidden = false
                self.btnEnRoute.isHidden = false
                self.imgMapMarker.isHidden = false
                self.heightConstraintTimer.constant = 44
                self.viewBackgroundTimer.isHidden = false
                playPauseAction()
                
            }
        }
        else
        {
            self.heightConstraintsMap.constant = 130
            self.mapView.isHidden = false
            self.btnEnRoute.isHidden = false
            self.imgMapMarker.isHidden = false
            self.heightConstraintTimer.constant = 0
            self.viewBackgroundTimer.isHidden = true
        }
        self.view.layoutIfNeeded()
    }
    
    func setViewTimer()
    {
        if timerState.rawValue == TimerState.play.rawValue
        {
            if timer.isValid
            {
            }
            else
            {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(time), userInfo: nil, repeats: true)
            }
            self.btnPlayPause.setImage(UIImage(named: "stop") , for: .normal)
            
        }
        else if timerState.rawValue == TimerState.pause.rawValue
        {
            timer.invalidate()
            self.btnPlayPause.setImage(UIImage(named: "play") , for: .normal)
        }
        else if timerState.rawValue == TimerState.stop.rawValue
        {
            timer.invalidate()
            count = 0
            self.lblTimer.text = "00:00:00"
            self.btnPlayPause.setImage(UIImage(named: "play") , for: .normal)
        }
        else if timerState.rawValue == TimerState.reset.rawValue
        {
            timer.invalidate()
            count = 0
            self.lblTimer.text = "00:00:00"
            self.btnPlayPause.setImage(UIImage(named: "play") , for: .normal)
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBarRightAction(_ sender: Any) {
        
    }
    
    func apiCallJobCancelledUpdate()
    {
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        print(self.jobID)
        var params = [String:Any]()
        
        if let user = AppUser.getUser() {
            params = [
                "status" : "cancelled",
                "provider" : user._id!
                ] as [String: Any]
        }
        
        showProgressHud(viewController: self)
        Api.jobApi.jobStatusUpdate(id: self.jobID, params: params, completion: { (success:Bool, message : String, jobDetail : JobHistoryVO?) in
            hideProgressHud(viewController: self)
            if success {
                
                if jobDetail != nil {
                    let _ = self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.showInfoAlertWith(title: "Error", message: message)
                }
            } else {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    @IBAction func btnWithdrawAction(_ sender: Any) {
        
    }
    
    @IBAction func btnUpdateQuoteAction(_ sender: Any) {
        
    }
    
    @IBAction func btnPlayPauseAction(_ sender: Any) {
        
        playPauseAction()
    }
    
    func playPauseAction(){
        
        if timerState.rawValue == TimerState.play.rawValue
        {
            timerState = TimerState(rawValue: TimerState.pause.rawValue)
        }
        else if timerState.rawValue == TimerState.pause.rawValue
        {
            timerState = TimerState(rawValue: TimerState.play.rawValue)
        }
        else if timerState.rawValue == TimerState.reset.rawValue
        {
            timerState = TimerState(rawValue: TimerState.play.rawValue)
        }
        
        self.setViewTimer()
    }
    
    @IBAction func btnPauseAction(_ sender: Any) {
        
        timerState = TimerState(rawValue: TimerState.pause.rawValue)
        self.setViewTimer()
    }
    
    @IBAction func btnResetAction(_ sender: Any) {
        
        timerState = TimerState(rawValue: TimerState.reset.rawValue)
        self.setViewTimer()
    }
    
    @IBAction func btnPrimaryStartWorkAction(_ sender: Any) {
        
        self.apiCallJobStatusUpdate()
    }
    
    @IBAction func btnContactAction(_ sender: Any) {
        self.apiCallJobCancelledUpdate()
    }
    
    @IBAction func btnEnRouteAction(_ sender: Any) {
        self.performSegue(withIdentifier: "jobStartToEnRouteSegue", sender: nil)
    }
    
    @objc func time()
    {
        count += 1
        saveJobTime()
        self.lblTimer.text = self.formattedTime(totalSeconds: count)
    }
    
    func formattedTime(totalSeconds: Int) -> String {
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600;
        return String(format: "%02d:%02d:%02d", hours,minutes,seconds)
    }
    
    func saveJobTime(){
        let defaults = UserDefaults.standard
        defaults.set(count, forKey: "TIME_JOBID_\(jobID ?? "")")
        defaults.synchronize()
    }
    
    func getJobTime() -> Int {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: "TIME_JOBID_\(jobID ?? "")")
    }
    
    func removeJobTime() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "TIME_JOBID_\(jobID ?? "")")
        defaults.synchronize()
    }
    
    func updateTimeCounter(){
        
    }
    
    func callApijobDetail() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        Api.jobDetailApi.jobDetailWith(jobID: self.jobID, completion: { (success:Bool, message : String, jobDetail : JobHistoryVO?) in
            hideProgressHud(viewController: self)
            if success {
                if jobDetail != nil {
                    
                    self.jobDetail = jobDetail
                    self.reloadViewJobDetails()
                    
                } else {
                    self.showInfoAlertWith(title: "Internal Error", message: "Logged In but user object not returned")
                }
            } else {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func callApijobQuotationDetail() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        print(self.jobID)
        Api.proposedJobApi.proposedJobQuotationDetailWith(jobID: self.jobID, completion: { (success:Bool, message : String, jobDetail : ProposedJobVO?) in
            hideProgressHud(viewController: self)
            if success {
                if jobDetail != nil {
                    
                    self.proposedJobDetail = jobDetail
                    self.reloadViewProposedJobDetails()
                    
                } else {
                    self.showInfoAlertWith(title: "Internal Error", message: "Logged In but user object not returned")
                }
            } else {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func apiCallJobStatusUpdate() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        print(self.jobID)
        
        var params = [String:Any]()
        
        var selectedStatus = String()
        
        if self.jobDetail.status == JobStatus.accepted.rawValue
        {
            selectedStatus = JobStatus.onway.rawValue
        }
        else if self.jobDetail.status == JobStatus.onway.rawValue
        {
            selectedStatus = JobStatus.arrived.rawValue
        }
        else if self.jobDetail.status == JobStatus.arrived.rawValue
        {
            selectedStatus = JobStatus.started.rawValue
        }
        else if self.jobDetail.status == JobStatus.started.rawValue
        {
            selectedStatus = JobStatus.completed.rawValue
        }
        
        if let user = AppUser.getUser()
        {
            params = [
                
                "status" : selectedStatus,
                "provider" : user._id!
                ] as [String: Any]
        }
        
        showProgressHud(viewController: self)
        Api.jobApi.jobStatusUpdate(id: self.jobID, params: params, completion: { (success:Bool, message : String, jobDetail: JobHistoryVO?) in
            hideProgressHud(viewController: self)
            
            if success
            {
                if jobDetail != nil
                {
                    self.jobDetail = jobDetail
                    self.reloadViewJobDetails()
                }
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func reloadViewProposedJobDetails() {
        
        self.lblClientName.text = self.proposedJobDetail.handymanObject.displayName
        self.lblClientAddress.text = self.proposedJobDetail.handymanObject.address
        self.latitude = self.proposedJobDetail.handymanObject.latitude
        self.longitude = self.proposedJobDetail.handymanObject.longitude
        self.lblRate.text = String(describing: self.proposedJobDetail.rate!)
        self.lblScheduled.text = self.proposedJobDetail.handymanObject.scheduleTime
        
        self.txtViewDescription.text = self.proposedJobDetail.proporsal
        
        let data = setImageWithUrl(url: self.proposedJobDetail.handymanObject.profileImageURL)
        
        DispatchQueue.main.async {
            self.imgClient.layer.cornerRadius = self.imgClient.frame.height/2
            self.imgClient.image = UIImage(data: data!)
        }
        
        self.setMapCentred(aroundLocation: self.proposedJobDetail.handymanObject.coordinaate!)
        self.collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! JobDetailCVC
        let data = setImageWithUrl(url: self.jobDetail.images[indexPath.row])

        cell.imgDetails.image = UIImage(named: "addphoto")
        DispatchQueue.main.async {
            cell.imgDetails.layer.cornerRadius = 5
            cell.imgDetails.image = UIImage(data: data!)
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedIndexPath = IndexPath(item: indexPath.row, section: 0)
        let selectedCell = self.collectionView.cellForItem(at: selectedIndexPath) as! JobDetailCVC
        
        let myView = JobDetailImageView.instanceFromNib()
        myView.imgView.image = selectedCell.imgDetails.image!
        let popupConfig = STZPopupViewConfig()
        popupConfig.dismissTouchBackground = true
        popupConfig.cornerRadius = 10
        presentPopupView(myView, config: popupConfig)
    }
    
    func setMapCentred(aroundLocation location : CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? ReceiptVC
        {
            controller.jobType = jobType
            controller.totalTime = self.totalTime
            controller.jobDetail = self.jobDetail
        }
        else if let controller = segue.destination as? ProviderOnTheWayVC
        {
            controller.jobInfo = self.jobDetail
        }
    }

    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
}
