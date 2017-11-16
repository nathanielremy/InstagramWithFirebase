//
//  SharePhotoVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 15/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoVC: UIViewController {
    
    // Stored properties
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(240, 240, 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setUpImageAndTextViews()
    }
    
    fileprivate func setUpImageAndTextViews() {
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 100)
        
        view.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: -8, paddingRight: 0, width: 84, height: nil)
        
        view.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
  }
    
    @objc func handleShare() {
        
        guard let image = selectedImage, let uploadData = UIImageJPEGRepresentation(image, 0.5) else { print("Selected image not convertible to JPEG representation"); return }
        
        // Disable Share Button
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let randomFileName = NSUUID().uuidString
        
        Storage.storage().reference().child("posts").child(randomFileName).putData(uploadData, metadata: nil) { (metaData, error) in
            
            if let error = error { self.navigationItem.rightBarButtonItem?.isEnabled = true; print("Error uploading post image to Firebase Storage: ", error); return }
            
            guard let imageURLString = metaData?.downloadURL()?.absoluteString else {
                print("No metaData returned for post image"); return
            }
            
            self.savePostImageURLToDatabase(imageUrlString: imageURLString)
        }
    }
    
    fileprivate func savePostImageURLToDatabase(imageUrlString: String) {
        
        guard let postImage = selectedImage else { print("No selected image"); return }
        guard let userID = Auth.auth().currentUser?.uid else { print("No currentUserID"); return }
        
        let userPostRef = Database.database().reference().child("posts").child(userID)
        let autoRef = userPostRef.childByAutoId()
        
        let values = ["imageURL" : imageUrlString, "caption" : textView.text ?? "", "imageWidth" : postImage.size.width, "imageHeight" : postImage.size.height, "creationDate" : Date().timeIntervalSince1970] as [String : Any]
        
        autoRef.updateChildValues(values) { (error, databaseRefernce) in
            
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post image to Firebase Database: ", error)
            }
            
            print("Successfully saved post image to Firebase Database")
            self.dismiss(animated: true, completion: nil)
        }
    }
}
