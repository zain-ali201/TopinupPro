
//
//  JobApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 12/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class JobApi : NSObject {
    
    func resize(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
        let destImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage!
    }
    
    
    func createQuotationWith(with params : NSMutableDictionary,detailImages : [UIImage], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        
        Alamofire.upload(multipartFormData: { MultipartFormData in
            
            print(params)
            
            for (key, value) in params {
                print(key)
                print(value)
                MultipartFormData.append(((value) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String)
            }
            
            for i in detailImages {
                
                let image = self.resize(image: i, toSize: CGSize(width: 200.0, height: 200.0))
                let timestamp = NSDate().timeIntervalSince1970
                MultipartFormData.append(image.pngData()!, withName: "images", fileName: "\(timestamp).png", mimeType: "image/png")
                
            }
            print(MultipartFormData)
            
        }, to: URLConfiguration.createJobURL, method: .post , headers: URLConfiguration.headersAuth())  { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    print(response.result.value as Any)
                    
                    
                    
                    let swiftyJsonVar = JSON(response.result.value!)
                    print(swiftyJsonVar)
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!)
                    }
                    else
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(true, msg!)
                    }
                }
                
                break
                
            case .failure(let encodingError):
                print(encodingError)
                completion(false, encodingError as! String)
                break
                
            }
        }
     }
    
    func jobStatusUpdate(id : String , params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String, _ jobDetail: JobHistoryVO?) -> Void))
    {
        
        let urlString = URLConfiguration.providerjobStatusURL + id
        
        
        print(urlString)
        print(params)
        Alamofire.request(urlString, method: .post,parameters: params, encoding: URLEncoding.httpBody, headers: URLConfiguration.headers())
            .responseJSON { response in
                print(response.result.value)
                print(response.debugDescription)
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    print(swiftyJsonVar)
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!,nil)
                    }
                    else
                    {
                        if let job = swiftyJsonVar["job"].dictionaryObject as NSDictionary?
                        {
                            var jobDetail = JobHistoryVO()
                            jobDetail = JobHistoryVO(withJSON: job)
                            let msg = swiftyJsonVar["message"].string
                            completion(true, msg!, jobDetail)
                        }
                        
                    }
                }
                else
                {
                    completion(false, "Could not obtain response from server",nil)
                }
        }
    }
    
    
}
