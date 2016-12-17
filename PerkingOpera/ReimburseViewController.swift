//
//  ReimburseViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/17/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit

class ReimburseViewController: UIViewController, UINavigationControllerDelegate,  UIImagePickerControllerDelegate {
    
    @IBOutlet weak var Pic1ImageView: UIImageView!
    
    @IBOutlet weak var Pic2ImageView: UIImageView!
    
    @IBOutlet weak var Pic3ImageView: UIImageView!
    

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    // MARK: - Actions
    
    
    @IBAction func submit(_ sender: Any) {
        
        if let base64String = UIImagePNGRepresentation(self.Pic1ImageView.image!)?.base64EncodedString() {
            // Upload to server
            let parameters  = [
                "FileName": "test1.png",
                "image_data": base64String
            ]
        }
        
    }
    

    @IBAction func takePicture(_ sender: UIBarButtonItem) {

        let imagePicker = UIImagePickerController()
        
        // If the device has a camera, take a picture, otherwise,
        // just pick from photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        else {
            imagePicker.sourceType = .photoLibrary
        }
        
        imagePicker.delegate = self
        
        // Place image picker on the screen
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String: Any]) {
        
        // Get picked image from info dictionary
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Put that image onto the screen in our image view
        if Pic1ImageView.image == nil {
            Pic1ImageView.image = image
        }
        else if Pic2ImageView.image == nil {
            Pic2ImageView.image = image
        }
        else {
            Pic3ImageView.image = image
        }
        
        // Take image picker off the screen -
        // you must call this dismiss method
        dismiss(animated: true, completion: nil)
    }
    
}
