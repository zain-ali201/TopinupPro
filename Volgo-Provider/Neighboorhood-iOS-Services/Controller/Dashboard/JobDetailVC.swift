//
//  JobDetailVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 19/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import MapKit
import STZPopupView

class JobDetailVC: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    
    @IBOutlet var clientDetailView: UIView!
    @IBOutlet weak var imgClient: UIImageView!
    @IBOutlet weak var lblClientName: UILabel!
    @IBOutlet weak var lblClientAddress: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblBudget: UILabel!
    @IBOutlet weak var lblScheduled: UILabel!
    @IBOutlet weak var lblDescription: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnQuote: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var imageBudget: UIImageView!
    @IBOutlet weak var heightConstraintsImage: NSLayoutConstraint!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet var jobType: UILabel!
    
    @IBOutlet var categoryName: UILabel!
    var region = MKCoordinateRegion()
    var jobID : String!
    var requestID : String!
    var jobDetail : JobHistoryVO!
    var latitude : Double!
    var longitude : Double!
    var imagesCells = [String]()
    var isFromHistory = false
    var tabBarBtn: TabBarButtonActive!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReportButton()
        self.viewInitializer()
        self.callApijobDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewInitializer()
    {   
        if isFromHistory
        {
            self.btnOK.isHidden = false
            
            self.btnChat.isHidden = true
            self.btnAccept.isHidden = true
            self.btnQuote.isHidden = true
            
            self.btnOK.layer.cornerRadius = self.btnOK.frame.height/2
            self.btnOK = addButtonShadow(button: self.btnOK)
        }
        else
        {
//            self.btnAccept.isHidden = false
//            self.btnQuote.isHidden = false
            self.btnChat.isHidden = false
            self.btnChat.layer.cornerRadius = self.btnChat.frame.height/2
            self.btnOK.isHidden = true
            
            if tabBarBtn.rawValue == TabBarButtonActive.jobs.rawValue {
                self.btnQuote.setTitle("Cancel", for: .normal)
                self.btnOK.setTitle("Accept", for: .normal)
                self.btnAccept.isHidden = true
                self.btnQuote.isHidden = true
                self.btnOK.isHidden = false
            }
            else if tabBarBtn.rawValue == TabBarButtonActive.newRequest.rawValue {
                self.btnQuote.setTitle("Quote", for: .normal)
            }
            else if tabBarBtn.rawValue == TabBarButtonActive.postponed.rawValue {
                
            }
            else if tabBarBtn.rawValue == TabBarButtonActive.accepted.rawValue {
                self.btnQuote.setTitle("Cancel", for: .normal)
            }
            self.btnQuote.layer.cornerRadius = self.btnQuote.frame.height/2
            self.btnAccept.layer.cornerRadius = self.btnAccept.frame.height/2
            self.btnOK.layer.cornerRadius = self.btnOK.frame.height/2
            self.btnQuote = addButtonShadow(button: self.btnQuote)
            self.btnAccept = addButtonShadow(button: self.btnAccept)
        }
        
        self.mapView.isUserInteractionEnabled = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
        clientDetailView.addGestureRecognizer(tap)
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
        vc.jobID = self.jobDetail._id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setMapCentred(aroundLocation location : CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chatBtnAction(_ sender: Any)
    {
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailViewController") as! ChatDetailViewController
        vc.jobID          = jobID
        vc.clientID       = jobDetail.clientID
        vc.clientName     = jobDetail.displayName
        vc.clientImageURL = jobDetail.profileImageURL
        vc.providerID     = jobDetail.providerID != nil ? jobDetail.providerID : ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnOKAction(_ sender: Any)
    {
        if(isFromHistory){
            let _ = self.navigationController?.popViewController(animated: true)
        }else{
            if tabBarBtn.rawValue == TabBarButtonActive.jobs.rawValue {
                btnAcceptAction(self.btnAccept)
            }
        }
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
            
            if success
            {
                if jobDetail != nil
                {
                    //print(jobDetail)
                    self.jobDetail = jobDetail
                    self.reloadViewDetails()
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
    
    func apiCallJobAcceptUpdate() {
        
        print(self.jobID)
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        var params = [String:Any]()
        
        if let user = AppUser.getUser() {
            
            params = [
                
                "status" : "accepted",
                "provider" : user._id!
                ] as [String: Any]
        }
        
        showProgressHud(viewController: self)
        Api.jobApi.jobStatusUpdate(id: self.jobID, params: params, completion: { (success:Bool, message : String, jobDetail : JobHistoryVO?) in
            hideProgressHud(viewController: self)
            
            if success {
                
                let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                    let _ = self.navigationController?.popToRootViewController(animated: true)
                })
                
                alertController.addAction(confirmAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func reloadViewDetails() {
        
        self.lblClientName.text = self.jobDetail.displayName
        self.lblClientAddress.text = self.jobDetail.wheree
        self.latitude = self.jobDetail.latitude
        self.longitude = self.jobDetail.longitude
        self.lblScheduled.text = DateUtil.getSimpleDateAndTime(self.jobDetail.when.dateFromISO8601!)
        self.lblDescription.text = self.jobDetail.details
        self.categoryName.text = self.jobDetail.categoryName
        self.jobType.text = self.jobDetail.type.capitalizingFirstLetter()
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if self.jobDetail.type == "hourly"
        {
            //imageBudget.image = UIImage(named: "watch")
            let formattedNumber = numberFormatter.string(from: NSNumber(value:Int(self.jobDetail.budget)!))
            self.lblBudget.text = (self.jobDetail.currency)+" "+String(describing: formattedNumber!) + "/hr"
            
            //self.heightConstraintsImage.constant = 24
        }
        else
        {
             let formattedNumber = numberFormatter.string(from: NSNumber(value:Int(self.jobDetail.budget)!))
            
            //imageBudget.image = UIImage(named: "coin")
            self.lblBudget.text = (self.jobDetail.currency)+" "+String(describing: formattedNumber!) + ""
            self.jobType.text = "Fixed Budget"
            //self.heightConstraintsImage.constant = 18
        }
//        let data = setImageWithUrl(url: self.jobDetail.categoryImageURL!)
//        DispatchQueue.main.async {
//            self.imgClient.layer.cornerRadius = self.imgClient.frame.height/2
//            self.imgClient.image = UIImage(data: data!)
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
        
        
        
        
        
        
        self.imagesCells = self.jobDetail.images
        
        self.setMapCentred(aroundLocation: self.jobDetail.coordinaate!)
        
        delayWithSeconds(0)
        {
            self.collectionView.reloadData()
            self.view.layoutIfNeeded()
        }
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func flagJobAction(_ sender: Any) {
    
    }
    
    @IBAction func btnAcceptAction(_ sender: Any) {
        
        self.apiCallJobAcceptUpdate()
        
    }
    
    
    @IBAction func btnQouteAction(_ sender: Any) {
        
        if tabBarBtn.rawValue == TabBarButtonActive.jobs.rawValue {
            let _ = self.navigationController?.popViewController(animated: true)
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.newRequest.rawValue {
            self.performSegue(withIdentifier: "quoteToCreateQuoteSegue", sender: nil)
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.postponed.rawValue {
            
        }
        else if tabBarBtn.rawValue == TabBarButtonActive.accepted.rawValue {
//            self.apiCallJobCancelledUpdate()
        }
    }
    
    func callApiForCancelled() {
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! JobDetailCVC
        
        print(self.jobDetail.images[indexPath.row])
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        if let controller = segue.destination as? CreateQuotationVC
        {
            if jobDetail != nil
            {
                controller.jobID = self.requestID
                controller.jobType = self.jobDetail.type
            }
        }
    }
    
    func apiCallJobCancelledUpdate() {
        
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
}
