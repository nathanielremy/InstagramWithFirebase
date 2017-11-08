//
//  UserProfileHeader.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 08/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    //MARK: Stored properties
    let profileImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .red
        
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blue
        
        setUpProfileImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set the profileImage for 
    fileprivate func setUpProfileImage() {
        // Add imageView to screen
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        // Retrieve current userID
        guard let currentUserID = Auth.auth().currentUser?.uid else { print("Error retrieving userID"); return }
        
        // Retrieve DataSnapshot of current user
        Database.database().reference().child("users").child(currentUserID).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            // Cast the DataSnapshot as a swift type and find the value you are looking for
            if let snapShotDictionary = dataSnapshot.value as? [String:Any], let profileImageURLString = snapShotDictionary["profileImageURL"] as? String, let profileImageURL = URL(string: profileImageURLString) {
                
                URLSession.shared.dataTask(with: profileImageURL, completionHandler: { (data, response, error) in
                    
                    if let error = error { print("Error downloading profileImage: ", error); return }
                    guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode, (httpStatusCode >= 200) && (httpStatusCode <= 299) else {
                        print("HTTP status code other than 2xx"); return
                    }
                    guard let data = data else { print("No data return from profileImageURL"); return }
                    
                    guard let profileImage = UIImage(data: data) else { print("Unable to create UIImage from data"); return }
                    
                    DispatchQueue.main.async {
                        self.profileImageView.image = profileImage
                    }
                }).resume()
                
            } else {
                print("Unable to retrive profileImageURL from dataSnapshot dictionary")
            }
        }) { (error) in
            print("Error fetching user:", error)
        }
    }
}
