//
//  ProfileVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import UserNotifications
import SKCountryPicker

class ProfileVC: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SetLocationViewControllerDelegate {
    
    @IBOutlet weak var viewBackgroundCredentials: UIView!
    @IBOutlet weak var viewBackgroundAddress: UIView!
    @IBOutlet weak var viewBackgroundChangePassword: UIView!
    @IBOutlet weak var viewBackgroundImageProfile: UIView!
    @IBOutlet weak var viewBackgroundFirstLastName: UIView!
    @IBOutlet weak var viewBackgroundDisplayName: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet var categoryBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var imageGrayView: UIView!
    @IBOutlet var cameraIcon: UIImageView!
    @IBOutlet weak var countryCodeButton: UIButton!
    @IBOutlet weak var countryImageView: UIImageView!
    
    var selectedCategories : [String] = []
    var allCategories = [CategoriesListVO]()
    
    
    var isEditMode = false
    var userInfo : UserVO!
    var params = [String:Any]()
    
    
    var selectedLocation : LocationVO!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.btnEdit.isHidden = true
        
        self.viewBackgroundCredentials = self.shadowViewForBorder(backgroundView: self.viewBackgroundCredentials)
        self.viewBackgroundAddress = self.shadowViewForBorder(backgroundView: self.viewBackgroundAddress)
        self.viewBackgroundChangePassword = self.shadowViewForBorder(backgroundView: self.viewBackgroundChangePassword)
        
        let tapChangePassword = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.gotoChangePassword))
        viewBackgroundChangePassword.addGestureRecognizer(tapChangePassword)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.updateImage))
        self.viewBackgroundImageProfile.addGestureRecognizer(tap)
        self.viewBackgroundImageProfile.layer.cornerRadius = self.viewBackgroundImageProfile.frame.size.height/2
        self.viewBackgroundImageProfile.clipsToBounds = true
        
        let tapLocation = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.gotoSetLocation))
        self.viewBackgroundAddress.addGestureRecognizer(tapLocation)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        countryCodeInitializer()
        self.editModeChanges()
        self.setupSideMenu()
        
        callingCategoriesListApi()
        notificationBtn.setTitle("Turn \(self.isRegisteredForRemoteNotifications() ? "Off":"On") Notifications", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notificationBtn.setTitle("Turn \(self.isRegisteredForRemoteNotifications() ? "Off":"On") Notifications", for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func countryCodeInitializer(){
        
        countryCodeButton.clipsToBounds = true
        countryCodeButton.accessibilityLabel = Accessibility.selectCountryPicker
        CountryManager.shared.addFilter(.countryCode)
        CountryManager.shared.addFilter(.countryDialCode)
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
    
    
    @IBAction func updateCategoryBtn(_ sender: UIButton) {
        

        
        
        var pickerData : [[String:String]] = []
        var valueArray = [String:String]()
        
        for item in self.allCategories {
            
            let name: String? = item.name
            let _id: String? = item._id
           
            valueArray["display"]   = name
            valueArray["value"]     = _id
            pickerData.append(valueArray)
            
            
            
            
        }
        
        
        MultiPickerDialog().show(title: "Categories",doneButtonTitle:"Done", cancelButtonTitle:"Cancel" ,options: pickerData, selected:  selectedCategories) {
            values -> Void in
            print("callBack \(values)")
            self.selectedCategories = values.compactMap {return $0["value"]}
            
            let displayValues = values.compactMap {return $0["display"]}
            
            self.categoryBtn.setTitle(displayValues.joined(separator:","), for: UIControl.State.normal)
            self.categoryBtn.setTitle(displayValues.joined(separator:","), for: UIControl.State.selected)
            
            
            showProgressHud(viewController: self)
            self.updateCategories()
            
            
        }
        
        
    }
    
    @IBAction func pickCountryAction(_ sender: UIButton) {
        presentCountryPickerScene(withSelectionControlEnabled: true)
    }
    
    @IBAction func changeNotificationSetting(_ sender: UIButton) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
            })
        }
    }
    
    func editModeChanges() {
        
        
        
        
        if AppUser.getUser() != nil {
            
            userInfo = AppUser.getUser()
            
            
            
            
            
            var namerArray = [String]()
           // var _idrArray = [String]()
            for item in userInfo.categories {
                
                
                
                let dict = item as! NSDictionary
                
                
                
                let name: String? = dict.object(forKey: "name") as? String
                let _id: String? = dict.object(forKey: "_id") as? String
                namerArray.append(name!)
                selectedCategories.append(_id!)
                
            }
            
            
            
            
            self.lblEmail.text = userInfo?.email!
            self.txtName.text = userInfo?.displayName!
            self.txtPhoneNumber.text = userInfo?.phone!
            
            self.lblAddress.text = userInfo?.address!
            self.txtFirstName.text = userInfo?.firstname!
            self.txtLastName.text = userInfo?.lastname!
            
            
            guard let country = CountryManager.shared.country(withDigitCode: (userInfo?.code)!) else {
                self.countryCodeButton.setTitle("N/A", for: .normal)
                self.countryImageView.isHidden = true
                return
            }

            countryCodeButton.setTitle(country.dialingCode, for: .normal)
            countryImageView.image = country.flag
            
            
            
            
            self.categoryBtn.setTitle(namerArray.joined(separator:","), for: UIControl.State.normal)
            self.categoryBtn.setTitle(namerArray.joined(separator:","), for: UIControl.State.selected)
            
            if userInfo?.latitude != nil && userInfo?.longitude != nil && userInfo?.address != nil
            {
                selectedLocation = LocationVO(lat: (userInfo?.latitude)!, long: (userInfo?.longitude)!, addr: (userInfo?.address)!)
                
                if selectedLocation?.address == "" && selectedLocation?.latitude == 0.0 && selectedLocation?.longitude == 0.0
                {
                    self.lblAddress.text = "Please choose location"
                }
                else
                {
                    self.lblAddress.text = selectedLocation.address!
                }
            }
            else
            {
                self.lblAddress.text = "Please choose location"
            }
        }
        
        var newStr = self.userInfo.profileImageURL!
        newStr.remove(at: (newStr.startIndex))
        let imageURl = URLConfiguration.ServerUrl + newStr
        
        self.imgProfile.layer.borderWidth = 2.0
        self.imgProfile.layer.borderColor = UIColor.white.cgColor
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.height/2
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
            {
                DispatchQueue.main.async {
                    
                    self.imgProfile.image = UIImage(data: data)
                }
            }
        }
        
        if isEditMode
        {
            
            
            
            
            self.btnEdit.setTitle("Done", for: .normal)
            self.txtName.isEnabled = true
            self.txtPhoneNumber.isEnabled = true
            self.countryCodeButton.isEnabled = true
            self.viewBackgroundFirstLastName.isHidden = false
            self.viewBackgroundDisplayName.isHidden = true
            
            self.txtFirstName.text = userInfo?.firstname
            self.txtLastName.text = userInfo?.lastname
            
            self.lblEmail.textColor = UIColor.lightGray
            self.lblAddress.textColor = UIColor.lightGray
            self.viewBackgroundAddress.isUserInteractionEnabled = false
            self.viewBackgroundImageProfile.isUserInteractionEnabled = true
            
            self.imageGrayView.isHidden = false
            self.cameraIcon.isHidden = false
        }
        else
        {
            
            self.btnEdit.setTitle("Edit", for: .normal)
            self.txtName.isEnabled = false
            self.txtPhoneNumber.isEnabled = false
            self.countryCodeButton.isEnabled = false
            self.viewBackgroundFirstLastName.isHidden = true
            self.viewBackgroundDisplayName.isHidden = false
            
            self.lblEmail.textColor = UIColor.black
            self.lblAddress.textColor = UIColor.black
            self.viewBackgroundAddress.isUserInteractionEnabled = true
            self.viewBackgroundImageProfile.isUserInteractionEnabled = false
            
            self.imageGrayView.isHidden = true
            self.cameraIcon.isHidden = true
        }
    }
    
    @objc func gotoChangePassword()
    {
        self.performSegue(withIdentifier: "ChangePasswordSegue", sender: nil)
    }
    
    @objc func gotoSetLocation()
    {
        self.performSegue(withIdentifier: "profileToSetLocationSegue", sender: nil)
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        
        if isEditMode
        {
            self.callApiChangeProfile()
            isEditMode = false
            self.editModeChanges()
        }
        else
        {
            isEditMode = true
            self.editModeChanges()
        }
    }
    
    func locationSelected(location: LocationVO) {
        
        self.selectedLocation = location
        
        if isEditMode == false
        {
            showProgressHud(viewController: self)
            self.updateLocation()
        }
    }
    
    func callingCategoriesListApi() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        Api.categoryApi.getCategories(completion: { (success:Bool, message : String, category : [CategoriesListVO]?) in
            hideProgressHud(viewController: self)
            
            if success {
                if category != nil {
                    self.allCategories.removeAll()
                    self.allCategories = category as! [CategoriesListVO]
                    
                    
                } else {
                    self.showInfoAlertWith(title: "Internal Error", message: "Logged In but user object not returned")
                }
            } else {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func callApiChangeProfile() {
        
        let validationResult = validateFields()
        if (validationResult == kResultIsValid)
        {
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            print(self.params)
            
            Api.userApi.updateProfile(params: self.params, completion: { (success:Bool, message : String, user : UserVO?) in
                
                hideProgressHud(viewController: self)
                
                if success
                {
                    if user != nil
                    {
                        AppUser.setUser(user: user!)
                        self.isEditMode = false
                        self.editModeChanges()
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
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
        
    }
    
    func updateCategories() {
        
        let validationResult = validateFieldsForCategoies()
        if (validationResult == kResultIsValid)
        {
            
            print(self.params)
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            
            
            
            Api.userApi.updateProfile(params: self.params, completion: { (success:Bool, message : String, user : UserVO?) in
                
                hideProgressHud(viewController: self)
                
                if success
                {
                    if user != nil
                    {
                        
                        
                        AppUser.setUser(user: user!)
                        self.editModeChanges()
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
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
        
    }
    
    
    func updateLocation() {
        
        let validationResult = validateFieldsForAddress()
        if (validationResult == kResultIsValid)
        {
            
            print(self.params)
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            Api.userApi.updateProfile(params: self.params, completion: { (success:Bool, message : String, user : UserVO?) in
                
                hideProgressHud(viewController: self)
                
                if success
                {
                    if user != nil
                    {
                        AppUser.setUser(user: user!)
                        self.editModeChanges()
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
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
        
    }
    
    @objc func keyboardWasShown(notification:NSNotification)
    {
        let info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.scrollView.convert(keyboardFrame, to: nil)
        var contentInset1:UIEdgeInsets = self.scrollView.contentInset
        contentInset1.bottom = (keyboardFrame.size.height)
        self.scrollView.contentInset = contentInset1
    }
    
    @objc func keyboardWillBeHidden()
    {
        let contentInset1:UIEdgeInsets = .zero
        self.scrollView.contentInset = contentInset1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }
    
    func validateFields() -> String
    {
        var result = kResultIsValid
        
        let firstName = txtFirstName.text?.trimmed()
        let lastName = txtLastName.text?.trimmed()
        let phone = txtPhoneNumber.text?.trimmed()
        let countryCode = countryCodeButton.currentTitle?.trimmed()
        //let validatePhone = validatePhoneNumber(value: phone!)
        
        if (firstName?.length())! < 1
        {
            result = "Please enter your first name"
            return result
        }
        else if (lastName?.length())! < 1 {
            result = "Please enter your last name"
            return result
        }
        else if (phone?.length())! < 3 {
            result = "Please enter a phone number"
            return result
        }
//        else if validatePhone == false
//        {
//            result = "Please enter valid phone number"
//            return result
//        }
        else if selectedCategories.count == 0
        {
            result = "Please choose category"
            return result
        }
        
        self.params = [
            "firstName" : firstName!,
            "lastName" : lastName!,
            "email" : self.lblEmail.text!,
            "phone" : phone!,
            "categories" : self.selectedCategories,
            "code" : countryCode! as String
        ]
        
        return result
    }
    
    func validateFieldsForAddress() -> String
    {
        var result = kResultIsValid
        
        if selectedLocation == nil
        {
            result = "Please choose address"
            return result
        }
        
        self.params = [
            
            "address": selectedLocation.address!,
            "latitude" : selectedLocation.latitude!,
            "longitude" : selectedLocation.longitude!
        ]
        
        return result
    }
    
    func validateFieldsForCategoies() -> String
    {
        var result = kResultIsValid
        
        if selectedCategories.count == 0
        {
            result = "Please choose category"
            return result
        }
        
        self.params = [
            
            "categories": selectedCategories
        ]
        
        return result
    }
    
    @objc func updateImage() {
        
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let galleryActionButton = UIAlertAction(title: "Gallery", style: .default)
        { _ in
            print("gallery")
            self.openGallary()
        }
        actionSheet.addAction(galleryActionButton)
        
        let cameraActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            print("camera")
            self.openCamera()
        }
        actionSheet.addAction(cameraActionButton)
        
       
        
//        actionSheet.popoverPresentationController?.sourceView = sender
//        actionSheet.popoverPresentationController?.sourceRect = sender.bounds
        self.present(actionSheet, animated: true, completion: nil)
        
        
        
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.allowsEditing = true
//
//        if (UIImagePickerController.isSourceTypeAvailable(.camera))
//        {
//            let actionSheetController: UIAlertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
//
//            let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
//                print("Cancel")
//            }
//            actionSheetController.addAction(cancelActionButton)
//
//
//
//            let cameraActionButton: UIAlertAction = UIAlertAction(title: "Use Camera", style: .default)
//            { action -> Void in
//
//                imagePickerController.sourceType = .camera
//                self.present(imagePickerController, animated: true, completion: nil)
//            }
//            actionSheetController.addAction(cameraActionButton)
//
//            let galleryActionButton: UIAlertAction = UIAlertAction(title: "Choose From Gallery", style: .default)
//            { action -> Void in
//
//                imagePickerController.sourceType = .photoLibrary
//
//
//                self.present(imagePickerController, animated: true, completion: nil)
//            }
//            actionSheetController.addAction(galleryActionButton)
//
//            self.present(actionSheetController, animated: true, completion: nil)
//        }
//        else
//        {
//            // If on Simulator, open the gallery straight away
//
//            imagePickerController.sourceType = .photoLibrary
//            self.present(imagePickerController, animated: true, completion: nil)
//        }
    }
    
    func openGallary()
    {
        //self.presentedViewController?.dismiss(animated: false, completion: nil)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.mediaTypes = ["public.image"]
        present(picker, animated: true, completion: nil)
        
    }
    
    func openCamera()
        {
            if(UIImagePickerController.isSourceTypeAvailable(.camera))
            {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerController.SourceType.camera
    //            picker.cameraCaptureMode = .photo
                picker.mediaTypes = ["public.image"]
                present(picker, animated: true, completion: nil)
            }
            else
            {
                openGallary()
            }
        }
    
    //Image Picker Controller Delgates
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        Api.userApi.changeProfileImage(image: selectedImage ?? UIImage()) { (suc, msg, url) in
            
            if suc
            {
                hideProgressHud(viewController: self)
                self.showInfoAlertWith(title: "Alert", message: msg)
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: URL(string: url)!) //make sure your image in this url does exist, otherwise
                    {
                        DispatchQueue.main.async {
                            
                            self.imgProfile.image = UIImage(data: data)
                        }
                    }
                }
            }
            else
            {
                hideProgressHud(viewController: self)
                self.showInfoAlertWith(title: "Alert", message: msg)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SetLocationVC
        {
            controller.delegate = self
        }
    }
    
    func shadowViewForBorder(backgroundView: UIView) -> UIView {
        
        var backView = UIView()
        backView = backgroundView
        
        backView.layer.shadowColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        backView.layer.shadowOpacity = 1
        backView.layer.shadowOffset = CGSize.zero
        backView.layer.shadowRadius = 4
        return backView
    }

}

private extension ProfileVC {
    
    /// Dynamically presents country picker scene with an option of including `Selection Control`.
    ///
    /// By default, invoking this function without defining `selectionControlEnabled` parameter. Its set to `True`
    /// unless otherwise and the `Selection Control` will be included into the list view.
    ///
    /// - Parameter selectionControlEnabled: Section Control State. By default its set to `True` unless otherwise.
    
    func presentCountryPickerScene(withSelectionControlEnabled selectionControlEnabled: Bool = true) {
        switch selectionControlEnabled {
        case true:
            // Present country picker with `Section Control` enabled
            let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
                
                guard let self = self else { return }
                
                self.countryImageView.isHidden = false
                self.countryImageView.image = country.flag
                self.countryCodeButton.setTitle(country.dialingCode, for: .normal)
            }
            
            countryController.flagStyle = .circular
            countryController.isCountryFlagHidden = false
            countryController.isCountryDialHidden = false
        case false:
            // Present country picker without `Section Control` enabled
            let countryController = CountryPickerController.presentController(on: self) { [weak self] (country: Country) in
                
                guard let self = self else { return }
                
                self.countryImageView.isHidden = false
                self.countryImageView.image = country.flag
                self.countryCodeButton.setTitle(country.dialingCode, for: .normal)
            }
            
            countryController.flagStyle = .corner
            countryController.isCountryFlagHidden = false
            countryController.isCountryDialHidden = false
        }
    }
}
