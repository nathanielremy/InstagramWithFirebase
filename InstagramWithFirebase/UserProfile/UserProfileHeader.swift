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
    
    var currentUser: CurrentUser? {
        didSet {
           guard let profileImageURLString = currentUser?.profileImageURL, let profileImageURL = URL(string: profileImageURLString) else {
                print("Current user has no profileImageURL"); return
            }
            
            print("Current user now has a profileImageURL")
            setUpProfileImage(fromURL: profileImageURL)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set the profileImage
    fileprivate func setUpProfileImage(fromURL url: URL) {
        // Add imageView to screen
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let error = error { print("Error downloading profileImage: ", error); return }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode, (httpStatusCode >= 200) && (httpStatusCode <= 299) else {
                print("HTTP status code other than 2xx"); return
            }
            
            guard let data = data else { print("No data return from profileImageURL"); return }
            
            guard let profileImage = UIImage(data: data) else { print("Unable to create UIImage from data"); return }
            
            // Get back on main thread to update UI
            DispatchQueue.main.async {
                self.profileImageView.image = profileImage
            }
            
        }).resume()
    }
}
