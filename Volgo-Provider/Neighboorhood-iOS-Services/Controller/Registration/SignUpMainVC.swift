//
//  SignUpMainVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SKCountryPicker

let selectProvider = "Select provider type"

enum Accessibility {
    public static let selectCountryPicker = "Select country picker"
    public static let searchCountry = "Search country name here.."
    public static let cross = "Cross button"
}


class SignUpMainVC: UIViewController, UITextFieldDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, ProviderTypeDelegate  {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewFirstName: UIView!
    @IBOutlet weak var viewLastName: UIView!
    @IBOutlet weak var viewEmailAddress: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewConfirmPassword: UIView!
    @IBOutlet weak var viewProviderType: UIView!
    @IBOutlet weak var viewPhone: UIView!
    //@IBOutlet weak var viewCompanyCode: UIView!
    @IBOutlet weak var viewTermsAndCondition: UIView!
    
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var uploadImageView: UIView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var countryCodeButton: UIButton!
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var txtPhone: UITextField!
    
    
    @IBOutlet weak var txtCompanyCode: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var lblProviderType: UILabel!
    
    @IBOutlet weak var btnEyePassword: UIButton!
    
    @IBOutlet weak var btnEyeConfirmPassword: UIButton!
    
    @IBOutlet weak var btnAgree: UIButton!
    @IBOutlet weak var btnTermsOfService: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSignInScreen: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet var scrollContentView: UIView!
    
    var isProfile: Bool = false
    var imageSoure : ImageSource?
    var selectedImagesArray = [UIImage]()
    var profileImageArray = [UIImage]()
    var isPasswordEyeEnable :Bool!
    var isConfirmPasswordEyeEnable : Bool!
    var params : [String : Any]!
    var isTermsEnable = false
    var allSelectedChoreCategories: [JobCategory] = []
    
    var selectedProviderTypes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = true
        self.relaodChoreCategoryView(choresCategories: self.allSelectedChoreCategories)
        self.viewInitializer()
        countryCodeInitializer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewInitializer() {
        

        
        
        
        
        let upload = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.updateImage))
        self.uploadImageView.addGestureRecognizer(upload)
        self.uploadImageView.layer.cornerRadius = self.uploadImageView.frame.size.height/2
        self.uploadImageView.clipsToBounds = true
        
        self.viewFirstName.layer.cornerRadius = self.viewFirstName.frame.height/2
        self.viewLastName.layer.cornerRadius = self.viewLastName.frame.height/2
        self.viewEmailAddress.layer.cornerRadius = self.viewEmailAddress.frame.height/2
        self.viewConfirmPassword.layer.cornerRadius = self.viewConfirmPassword.frame.height/2
        self.viewPassword.layer.cornerRadius = self.viewPassword.frame.height/2
        self.viewPhone.layer.cornerRadius = self.viewPhone.frame.height/2
        self.btnSignUp.layer.cornerRadius = self.btnSignUp.frame.height/2
        self.viewProviderType.layer.cornerRadius = self.viewProviderType.frame.height/2
        //self.viewCompanyCode.layer.cornerRadius = self.viewCompanyCode.frame.height/2
        
        
        
        
        
        isPasswordEyeEnable = false
        isConfirmPasswordEyeEnable = false
        txtPassword.isSecureTextEntry = true
        txtConfirmPassword.isSecureTextEntry = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpMainVC.selectProviderType))
        self.viewProviderType.addGestureRecognizer(tap)
        
    }
    
    func countryCodeInitializer(){
        guard let country = CountryManager.shared.currentCountry else {
            self.countryCodeButton.setTitle("N/A", for: .normal)
            self.countryImageView.isHidden = true
            return
        }
        
        countryCodeButton.setTitle(country.dialingCode, for: .normal)
        countryImageView.image = country.flag
        countryCodeButton.clipsToBounds = true
        countryCodeButton.accessibilityLabel = Accessibility.selectCountryPicker
        CountryManager.shared.addFilter(.countryCode)
        CountryManager.shared.addFilter(.countryDialCode)
    }
    
    @objc func updateImage() {
            
            isProfile = true
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
    
    @objc func selectProviderType() {
        self.performSegue(withIdentifier: "SelectProviderTypeSegue", sender: nil)
    }
    
    func setAllProviderType(allProviderTypes: [JobCategory])
    {
        self.allSelectedChoreCategories = allProviderTypes
        self.relaodChoreCategoryView(choresCategories: self.allSelectedChoreCategories)
    }
    
    func relaodChoreCategoryView(choresCategories : [JobCategory]) {
        
        if choresCategories.isEmpty
        {
            self.lblProviderType.text = "Select Provider Type"
        }
        else
        {
            var catNames: [String] = []
            for cat in allSelectedChoreCategories {
                catNames.append(cat.name)
            }
            self.lblProviderType.text = catNames.joined(separator: ", ")
        }
        self.view.reloadInputViews()
    }
    
    @IBAction func btnSignInScreenAction(_ sender: Any) {
        
        if let vcs = self.navigationController?.viewControllers {
            
            for previousVC in vcs {
                if previousVC is LoginVC {
                    self.navigationController!.popToViewController(previousVC, animated: true)
                    return
                }
            }
            

        }
        
        self.performSegue(withIdentifier: "signupToLoginSegue", sender: nil)
    }
    
    @IBAction func btnSignUpAction(_ sender: Any) {
        
        //callApiForSignUp()
        
        self.view.endEditing(true)
        //self.scrollView.setContentOffset(.zero, animated: true)
        let validationResult = validateFields()
        if (validationResult == kResultIsValid)
        {
            
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            
            print("All data is valid")

            showProgressHud(viewController: self)

            Api.userApi.isEmailAlreadyUsed(userEmail: txtEmailAddress.text!, completion: { (emailAvailable, message) in

                hideProgressHud(viewController: self)

                if (emailAvailable)
                {
                    self.callApiForSignUp()
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
    
    func callApiForSignUp() {
        
        self.view.endEditing(true)
        //self.scrollView.setContentOffset(.zero, animated: true)
        
        if !isTermsEnable {
            self.showInfoAlertWith(title: "Alert", message: "Please agree to terms and conditions.")
            return
        }
        
        
        let validationResult = validateFields()
        if (validationResult == kResultIsValid)
        {
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            
            showProgressHud(viewController: self)
            Api.userApi.signUpUser(with: (self.params)!, profileImage: self.profileImageArray, completion: { (successful, msg , user) in
                //hideProgressHud(viewController: self)
                
                if successful
                {
                    print(user!)
                    AppUser.setUser(user: user!)
                    
                    self.callApiForDocuments(providerId: (user?._id)!)
                    
                    
                    
                }
                else
                {
                    self.showInfoAlertWith(title: "Oooppppsss", message: msg)
                }
            })
        }
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
    }
    
    func callApiForDocuments(providerId: String){
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        self.params = [
            "providerId" : providerId
        ]
        
        
        
        Api.userApi.documentsWith(with: self.params , detailImages: self.selectedImagesArray, completion: { (successful, msg) in
            hideProgressHud(viewController: self)
            
            if successful
            {
                
                
                let storyboardId = "Dashboard_ID"
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initViewController = storyboard.instantiateViewController(withIdentifier: storyboardId)
                UIApplication.shared.keyWindow?.rootViewController = initViewController
                
                
            }
            else
            {
                self.showInfoAlertWith(title: "Oooppppsss", message: msg)
            }
        })
    }
    
    @IBAction func btnAgreeAction(_ sender: Any) {
        
        if isTermsEnable
        {
            isTermsEnable = false
            btnAgree.setImage(UIImage(named: "iconcheckboxunselected"), for: .normal)
        }
        else
        {
            isTermsEnable = true
            btnAgree.setImage(UIImage(named: "iconcheckboxselected"), for: .normal)
        }
    }
    
    @IBAction func btnTermsOfServiceAction(_ sender: Any) {
        
    }
    
    @IBAction func btnEyePasswordAction(_ sender: Any) {
        
        if isPasswordEyeEnable == true
        {
            isPasswordEyeEnable = false
            txtPassword.isSecureTextEntry = true
            btnEyePassword.setImage(UIImage(named:"eyeDisable"), for: .normal)
        }
        else
        {
            isPasswordEyeEnable = true
            txtPassword.isSecureTextEntry = false
            btnEyePassword.setImage(UIImage(named:"eyeEnable"), for: .normal)
        }
    }
    
    @IBAction func btnEyeConfirmPasswordAction(_ sender: Any) {
        
        if isConfirmPasswordEyeEnable == true
        {
            isConfirmPasswordEyeEnable = false
            txtConfirmPassword.isSecureTextEntry = true
            btnEyeConfirmPassword.setImage(UIImage(named:"eyeDisable"), for: .normal)
        }
        else
        {
            isConfirmPasswordEyeEnable = true
            txtConfirmPassword.isSecureTextEntry = false
            btnEyeConfirmPassword.setImage(UIImage(named:"eyeEnable"), for: .normal)
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
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
        let firstName = txtFirstName.text?.trimmed()
        let lastName = txtLastName.text?.trimmed()
        let email = txtEmailAddress.text?.trimmed()
        let password = txtPassword.text?.trimmed()
        let confirmPassword = txtConfirmPassword.text?.trimmed()
        let phone = txtPhone.text?.trimmed()
        let countryCode = countryCodeButton.currentTitle?.trimmed()
       // let validatePhone = validatePhoneNumber(value: phone!)
        
        if (firstName?.length())! < 1
        {
            result = "Please enter your first name"
            return result
        }
        else if firstName?.rangeOfCharacter(from: characterset.inverted) != nil {
            result = "Please enter a valid firstname"
            return result
        }
        else if (lastName?.length())! < 1 {
            result = "Please enter your last name"
            return result
        }
        else if lastName?.rangeOfCharacter(from: characterset.inverted) != nil {
            result = "Please enter a valid lastname"
            return result
        }
        else if email?.isValidEmail() == false
        {
            result = "Please enter a valid email address"
            return result
        }
        else if (password?.length())! < 6 || (password?.length())! > 20
        {
            result = "Please enter a password between 6 to 20 characters"
            return result
        }
        else if password != confirmPassword || (confirmPassword?.length())! < 6 {
            result = "Password mismatched"
            return result
        }
        else if self.allSelectedChoreCategories.isEmpty {
            result = "Please select provider type"
            return result
        }
        else if (phone?.length())! < 3 {
            result = "Please enter a phone number"
            return result
        }else if profileImageArray.isEmpty
        {
            result = "Please choose profile picture"
            return result
        }else if selectedImagesArray.isEmpty
        {
            result = "Please choose documents"
            return result
        }
//        else if (companyCode?.length())! < 1 {
//            result = "Please enter the company code"
//            return result
//        }
        
//        else if validatePhone == false
//        {
//            result = "please enter valid phone number"
//            return result
//        }
        var catIDs: [String] = []
        for cat in allSelectedChoreCategories {
            catIDs.append(cat.id)
        }
        self.params = [
            "firstName" : firstName!,
            "lastName" : lastName!,
            "email" : email!,
            "password" : password!,
            "phone": phone!,
            "categories" : catIDs,
            "code" : countryCode! as String
        ]
        
        return result
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ChooseProviderTypeVC {
            controller.delegate = self
            controller.selectedCategory = self.allSelectedChoreCategories
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 25
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @objc func imageFirstTapped() {
        showImagePickerDialogFor(imgSource: .first)
    }
    
    @objc func imageSecondTapped() {
        showImagePickerDialogFor(imgSource: .second)
    }
    
    @objc func imageThirdTapped() {
        showImagePickerDialogFor(imgSource: .third)
    }
    
    func showImagePickerDialogFor(imgSource : ImageSource)
        {
            isProfile = false
            
            self.imageSoure = imgSource
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            
            
            
            if (UIImagePickerController.isSourceTypeAvailable(.camera))
            {
                let actionSheetController: UIAlertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
                
                let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                    print("Cancel")
                }
                actionSheetController.addAction(cancelActionButton)
                
                let cameraActionButton: UIAlertAction = UIAlertAction(title: "Use Camera", style: .default)
                { action -> Void in
                    
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
                }
                actionSheetController.addAction(cameraActionButton)
                
                let galleryActionButton: UIAlertAction = UIAlertAction(title: "Choose From Gallery", style: .default)
                { action -> Void in
                    
                    imagePickerController.sourceType = .photoLibrary
                    
                    self.present(imagePickerController, animated: true, completion: nil)
                }
                actionSheetController.addAction(galleryActionButton)
                
                self.present(actionSheetController, animated: true, completion: nil)
            }
            else
            {
                // If on Simulator, open the gallery straight away
                
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            var selectedImage: UIImage?
            if let editedImage = info[.editedImage] as? UIImage {
                selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                selectedImage = originalImage
            }
            
            
            
            if let image = selectedImage {
                
                if(isProfile){
                    profileImageArray.removeAll()
                    self.imgProfile.image = image
                    profileImageArray.append(image)
                }else{
                    selectedImagesArray.append(image)
                    imageCollectionView.reloadData()
                }
                
            }
   
            
            picker.dismiss(animated: true, completion: nil)
        }

    @IBAction func pickCountryAction(_ sender: UIButton) {
        presentCountryPickerScene(withSelectionControlEnabled: true)
    }
    
}

extension SignUpMainVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImagesArray.count == 10 ? 10:(selectedImagesArray.count + 1)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCell", for: indexPath) as! AddImageCell
        cell.imageView.image = UIImage(named: "addphoto")
        if indexPath.row < selectedImagesArray.count {
            cell.imageView.image = selectedImagesArray[indexPath.row]
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if indexPath.row == selectedImagesArray.count && selectedImagesArray.count < 10 {
            showImagePickerDialogFor(imgSource: .first)
        }
    }
}

private extension SignUpMainVC {
    
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

