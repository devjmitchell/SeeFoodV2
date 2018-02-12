//
//  ViewController.swift
//  SeeFoodV2
//
//  Created by Jason Mitchell on 2/10/18.
//  Copyright © 2018 Jason Mitchell. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let apiKey = "09c2fbbff480bebce6ca9f11877df95237794def"
    let version = "2018-02-11"

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    var classificationResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isHidden = true
        
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].classification)
                }
                
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                }
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "hotdog")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "not-hotdog")
                    }
                }
                
            })
            
        } else {
            print("There was an error picking the image")
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera // or use .savedPhotosAlbum if testing on simulator
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(String(describing: navigationItem.title))")
            vc?.add(#imageLiteral(resourceName: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
        } else {
            self.navigationItem.title = "Please log in to Twitter"
        }
        
    }
}

