//
//  ReportVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Rizwan Shah on 04/09/2020.
//  Copyright © 2020 yamsol. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

enum ImageSource
{
    case first
    case second
    case third
}

//var textViewProposalPlaceholder = "Write your proposal here..."
var textViewReportPlaceholder = "Write your report here..."

protocol SetJobDetailProtocol {
    func setNewJobDetail(detail : String, images : [UIImage])
}

class ReportVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var viewBackgroundDescriptionView: UIView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var imgFirst: UIImageView!
    @IBOutlet weak var imgSecond: UIImageView!
    @IBOutlet weak var imgThird: UIImageView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    
    var jobInfo : JobHistoryVO!
    let user = AppUser.getUser()
    
    
    
    var params = NSMutableDictionary()
    var imageSoure : ImageSource?
    var selectedImagesArray = [UIImage]()
    var selectedJobDetail = String()
    var delegate : SetJobDetailProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitializer()
        self.viewInitializerForSavedParams()
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func viewInitializer()
    {
        IQKeyboardManager.shared.enable = true
        
        self.imgFirst.layer.cornerRadius = 15
        self.imgSecond.layer.cornerRadius = 15
        self.imgThird.layer.cornerRadius = 15
        
        self.btnSave.layer.cornerRadius = self.btnSave.frame.height/2
        
        let tapFirst = UITapGestureRecognizer(target: self, action: #selector(self.imageFirstTapped))
        imgFirst.addGestureRecognizer(tapFirst)
        
        let tapSecond = UITapGestureRecognizer(target: self, action: #selector(self.imageSecondTapped))
        imgSecond.addGestureRecognizer(tapSecond)
        
        let tapThird = UITapGestureRecognizer(target: self, action: #selector(self.imageThirdTapped))
        imgThird.addGestureRecognizer(tapThird)
        
        if self.txtView.text.isEmpty {
            self.txtView.text = textViewReportPlaceholder
            self.txtView.textColor = UIColor.lightGray
        }
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
    
    func viewInitializerForSavedParams()
    {
        if selectedJobDetail != ""
        {
            self.txtView.text = selectedJobDetail
            self.txtView.textColor = UIColor.black
            
            for (index,image) in selectedImagesArray.enumerated()
            {
                if index == 0
                {
                    imgFirst.image = image
                }
                else if index == 1
                {
                    imgSecond.image = image
                }
                else if index == 2
                {
                    imgThird.image =  image
                }
            }
        }
    }
    
    @IBAction func btnSavedAction(_ sender: Any) {
        
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
            Api.reportApi.reportWith(with: self.params , detailImages: self.selectedImagesArray, completion: { (successful, msg) in
                hideProgressHud(viewController: self)
                
                if successful
                {
                    let alertController = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                        let _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
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
    
    
    
    func validateFields() -> String {
        
//        selectedImagesArray.removeAll()
        
        var result = kResultIsValid
        
        let proposall = self.txtView.text.trimmed()
        
        let defaultImage = UIImage(named: "addphoto")
        
//        if !(self.imgFirst.image?.isEqualToImage(image: defaultImage!))!
//        {
//            selectedImagesArray.append(self.imgFirst.image!)
//        }
//
//        if !(self.imgSecond.image?.isEqualToImage(image: defaultImage!))!
//        {
//            selectedImagesArray.append(self.imgSecond.image!)
//        }
//
//        if !(self.imgThird.image?.isEqualToImage(image: defaultImage!))!
//        {
//            selectedImagesArray.append(self.imgThird.image!)
//        }
        
        if proposall == textViewReportPlaceholder
        {
            result = "Please enter your report"
            return result
        }
        else if (proposall.length()) < 3
        {
            result = "Please enter your report"
            return result
        }
        else if selectedImagesArray.isEmpty
        {
            result = "Please add images"
            return result
        }
        
        self.params = [
            "userId" : (user?._id)! as String,
            "jobId" : self.jobInfo._id,
            "details" : proposall,
            "role": "provider",
            "reporterId": self.jobInfo.clientID
        ] as NSMutableDictionary
        
        
        print(self.params)
        return result
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if self.txtView.textColor == UIColor.lightGray {
            self.txtView.text = nil
            self.txtView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if self.txtView.text.isEmpty {
            self.txtView.text = textViewReportPlaceholder
            self.txtView.textColor = UIColor.lightGray
        }
    }

    func showImagePickerDialogFor(imgSource : ImageSource)
    {
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
        
        // Save image
//        switch(self.imageSoure!) {
//        case .first:
//            imgFirst.image = selectedImage
//            break
//
//        case .second:
//            imgSecond.image = selectedImage
//            break
//
//        case .third:
//            imgThird.image = selectedImage
//            break
//        }
        if let image = selectedImage {
            selectedImagesArray.append(image)
            print(selectedImagesArray.count)
            imageCollectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }


}

extension ReportVC: UICollectionViewDelegate, UICollectionViewDataSource {
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

class AddImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
}


