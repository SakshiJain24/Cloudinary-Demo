//
//  NetworkCall.swift
//  GMP_CloudinaryPOC
//
//  Created by Sakshi Jain on 11/11/17.
//  Copyright © 2017 Sakshi. All rights reserved.
//

import UIKit
import Cloudinary

enum eHTTPMethod
{
    case eHTTPMethodGET
    case eHTTPMethodPOST
}

class NetworkCall: NSObject
{
    static let sharedNetworkManager = NetworkCall()
    
    //MARK:- Upload Image
    func uploadImage(imageData: Data , size : CGSize , completion: @escaping (_ status: Bool , _ result: NSDictionary) -> Void) {
        let config = CLDConfiguration(cloudName: "dkcdsb4ex", apiKey: "261832787566148",apiSecret: "2EHVh1_h-QGGdwagw9hB8gIzR7k")
        let cloudinary = CLDCloudinary(configuration: config)
        
        let params = CLDUploadRequestParams()
        //params.setUploadPreset("nk6nv2gv")
        let customWidth = Int(size.width)
        let customHeight = Int(size.height)
        params.setTransformation(CLDTransformation().setWidth(customWidth).setHeight(customHeight))
        params.setPublicId("my_public_id")
        let _ = cloudinary.createUploader().signedUpload(data: imageData, params: params, progress:
            { progress in
                print(progress.fractionCompleted) })
            { (response, error) in
                
                print(response?.resultJson as Any )
                
                print(error.debugDescription as Any )
                
                if (error != nil)
                {
                    completion(false, ["error": error.debugDescription])
                }
                else
                {                    
                    completion(true, ["response": response?.resultJson as Any])
                }
            }
    }
    
    //MARK:- Download Image
    func downloadImages(downloadURL : String , completion: @escaping (_ status: Bool , _ result: NSDictionary) -> Void)  {

        let config = CLDConfiguration(cloudName: "dkcdsb4ex", apiKey: "261832787566148",apiSecret: "2EHVh1_h-QGGdwagw9hB8gIzR7k")
        let cloudinary = CLDCloudinary(configuration: config)
        
        let _ = cloudinary.createDownloader().fetchImage(downloadURL, { progress in
            print(progress.fractionCompleted)
        }) { (responseImage, error) in
            print(responseImage as Any )
            print(error.debugDescription as Any )

            if (error != nil)
            {
                completion(false, ["error": error.debugDescription])
            }
            else
            {
                completion(true, ["response": responseImage as Any])
            }
        }
    }
}


class cloudinaryManager
{
    init() {
        let config = CLDConfiguration(cloudName: "dkcdsb4ex", apiKey: "261832787566148",apiSecret: "2EHVh1_h-QGGdwagw9hB8gIzR7k")
        let _ = CLDCloudinary(configuration: config)
    }
}
