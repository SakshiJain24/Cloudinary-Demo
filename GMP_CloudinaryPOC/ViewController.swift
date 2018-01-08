//
//  ViewController.swift
//  GMP_CloudinaryPOC
//
//  Created by Sakshi Jain on 11/11/17.
//  Copyright © 2017 Sakshi. All rights reserved.
//

import UIKit

//MARK: - Enums
enum eMediaLibraryMode: String {
    case eSavedPhotos = "Saved Photos"
    case eCamera = "Camera"
}

class ViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var selectSizeButton: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var sizePickerView: UIPickerView!
    
    
    let sizeArray = ["40*50","200*300","1200*1000"]
    let imagePicker = UIImagePickerController()
    
    var imageArray = NSMutableArray()
    var selectedSize : CGSize = CGSize()
    var imageDownLoadURL : String = String()
    var chosenImage : UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        self.setUpUI();
    }
    
    func setUpUI()  {
        uploadButton.layer.cornerRadius = 50.0
        uploadButton.layer.masksToBounds = true
        
        selectSizeButton.layer.cornerRadius = 3.0
        selectSizeButton.layer.masksToBounds = true
        selectSizeButton.layer.borderColor = UIColor.black.cgColor
        selectSizeButton.layer.borderWidth = 1.0
        selectSizeButton.setTitle(sizeArray[0], for: .normal)
        
        selectedSize = CGSize(width: 40, height: 50)
    }
    
    func initializeMediaLibrary(mode : eMediaLibraryMode){
        switch mode {
        case .eSavedPhotos:
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case .eCamera:
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
        }
        
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker,animated: true,completion: nil)
    }
    
    //MARK:- IBAction Methods
    @IBAction func uploadButtonClicked(_ sender: UIButton){
        let alertBox = UIAlertController (title: "Choose Option", message: "", preferredStyle: .actionSheet)
        
        alertBox.addAction(UIAlertAction(title: "Saved Photos", style: UIAlertActionStyle.default, handler: { (actionSheetController) -> Void in
            self.initializeMediaLibrary(mode: eMediaLibraryMode.eSavedPhotos)
        }))
        
        alertBox.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (actionSheetController) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.initializeMediaLibrary(mode: eMediaLibraryMode.eCamera)
            }
            else
            {
                let infoAlertBox = UIAlertController (title: "", message: "Your Device doesn't support camera", preferredStyle: .alert)
                infoAlertBox.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(infoAlertBox, animated: true, completion: nil)
            }
        }))
        
        alertBox.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertBox, animated: true, completion: nil)
    }
    
    @IBAction func selectSizeButtonClick(_ sender: UIButton){
        if sizePickerView.isHidden
        {
            sizePickerView.isHidden = false
        }
        else
        {
            sizePickerView.isHidden = true
        }
    }
    
    //MARK:- UIPicker Delegate & DataSource Methods
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sizeArray.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sizeArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        switch row {
            
        case 0:
            selectSizeButton.setTitle(sizeArray[row], for: .normal)
            selectedSize = CGSize(width: 40, height: 50)
        case 1:
            selectSizeButton.setTitle(sizeArray[row], for: .normal)
            selectedSize = CGSize(width: 200, height: 300)
        case 2:
            selectSizeButton.setTitle(sizeArray[row], for: .normal)
            selectedSize = CGSize(width: 1200, height: 1000)
        default:
            selectSizeButton.setTitle(sizeArray[0], for: .normal)
            selectedSize = CGSize(width: 40, height: 50)
        }
        
        sizePickerView.isHidden = true
        self.imageArray.removeAllObjects()
        
        DispatchQueue.main.async {
            self.imageCollectionView.reloadData()
        }
        
        self.callUploadMediaCloudinary(image: chosenImage)
    }
    
    //MARK: - UIImagePickerController Delegates
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
       
        dismiss(animated:true, completion: nil)
        
        self.callUploadMediaCloudinary(image: chosenImage)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Call Network class cloudinary upload method
    func callUploadMediaCloudinary(image: UIImage) {
        
        if let data = UIImagePNGRepresentation(image)
        {
            NetworkCall.sharedNetworkManager.uploadImage(imageData: data, size : selectedSize, completion: { (success, result) in
                if success{
                    let responseDict : NSDictionary = result.value(forKey: "response") as! NSDictionary
                    self.imageDownLoadURL = responseDict.value(forKey: "secure_url") as! String
                    self.callDownloadMediaCloudinary(downloadURL: responseDict.value(forKey: "secure_url") as! String)
                }
                else
                {
                }
            })
        }
    }
    
    //MARK:- Call Network class cloudinary download method
    func callDownloadMediaCloudinary(downloadURL : String) {
        NetworkCall.sharedNetworkManager.downloadImages(downloadURL: downloadURL, completion:{ (success, result) in
                if success{
                    let responseImage : UIImage = result.value(forKey: "response") as! UIImage
                    self.imageArray.add(responseImage)
                    
                    DispatchQueue.main.async {
                        self.imageCollectionView.reloadData()
                    }
                }
                else
                {
                }
        } )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UICollectionView Delegate & DataSource Methods
extension ViewController {
    // The number of items of data
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.imageArray.count
    }
    
    // Content Of an item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell    {
        let cell : ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCellIdentifier", for: indexPath) as! ImageCollectionViewCell
        
        cell.downloadedImage.image = imageArray[indexPath.item] as? UIImage
        return cell
    }
    
    // Size of Cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  selectedSize
    }
}
