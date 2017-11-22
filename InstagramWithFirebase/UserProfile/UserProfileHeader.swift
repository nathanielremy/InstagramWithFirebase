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
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.backgroundColor = .lightGray
        
        return image
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return button
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 16)])
        attributedText.append(NSMutableAttributedString(string: "posts", attributes: [.foregroundColor : UIColor.lightGray, .font : UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 16)])
        attributedText.append(NSMutableAttributedString(string: "followers", attributes: [.foregroundColor : UIColor.lightGray, .font : UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [.font : UIFont.boldSystemFont(ofSize: 16)])
        attributedText.append(NSMutableAttributedString(string: "following", attributes: [.foregroundColor : UIColor.lightGray, .font : UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    // Must be "lazy var" for some reason I can't explain ...
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        
        return button
    }()
    
    var user: User? {
        didSet {
           guard let profileImageURLString = user?.profileImageURLString else {
                print("Current user has no profileImageURL"); return
            }
            
            print("User has profile image")
            self.usernameLabel.text = user?.username ?? "username"
            profileImageView.loadImage(from: profileImageURLString)
            setUpEditProfileFollowButton()
        }
    }
    
    fileprivate func setUpEditProfileFollowButton() {
        
        guard let currentlyLoggedInUserID = Auth.auth().currentUser?.uid, let userID = self.user?.uid else { return }
        
        if currentlyLoggedInUserID != userID {
            
            // Check if already following
            let followingRef = Database.database().reference().child("following").child(currentlyLoggedInUserID).child(userID)
            followingRef.observeSingleEvent(of: .value, with: { (dataSnapshot) in
                
                if let isFollowing = dataSnapshot.value as? Int, isFollowing == 1 {
                    
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    self.editProfileFollowButton.setTitleColor(.black, for: .normal)
                    self.editProfileFollowButton.backgroundColor = .white
                    
                } else {
                    
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                    self.editProfileFollowButton.setTitleColor(.white, for: .normal)
                    self.editProfileFollowButton.backgroundColor = UIColor.rgb(17, 154, 237)
                    
                }
            }, withCancel: { (error) in
                print("Error retrieving following")
            })
        } else {
            
            self.editProfileFollowButton.setTitle("Edit Profile", for: .normal)
            self.editProfileFollowButton.setTitleColor(.black, for: .normal)
            self.editProfileFollowButton.backgroundColor = .white
            
        }
    }
    
    @objc func handleEditProfileOrFollow() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid, let userID = self.user?.uid else { return }
        
        if editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            
            print("Edit profile button")
            
        } else if editProfileFollowButton.titleLabel?.text == "Follow" {
            // Follow
            
            let followingRef =  Database.database().reference().child("following").child(currentUserID)
            let values = [userID : 1]
            followingRef.updateChildValues(values) { (error, databaseReference) in
                
                if let error = error {
                    print("Error following user: ", error); return
                }
                
                self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
                self.editProfileFollowButton.backgroundColor = .white
                
                print("Successfully followed user: ", self.user?.username ?? "some username")
            }
            
        } else if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            //Unfollow
            
            let unfollowingRef =  Database.database().reference().child("following").child(currentUserID).child(userID)
            
            // This call removes Data at specified location and all children
            unfollowingRef.removeValue(completionBlock: { (error, databaseRef) in
                
                if let error = error {
                    print("Failed to unfollow user: ", error); return
                }
                
                self.editProfileFollowButton.setTitle("Follow", for: .normal)
                self.editProfileFollowButton.setTitleColor(.white, for: .normal)
                self.editProfileFollowButton.backgroundColor = UIColor.rgb(17, 154, 237)
                
                print("Successfully unfollowed user", self.user?.username ?? "Some username that got unfollowed")
                
            })
        }
     }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Add imageView to screen
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        setUpBottomToolBar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: gridButton.topAnchor, right: self.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: nil, height: nil)
        
        setUpUserStatsView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 3, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 34)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set up the user statistics view
    fileprivate func setUpUserStatsView() {
        
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: -12, width: nil, height: 50)
    }
    
    // Set up the toolBar
    fileprivate func setUpBottomToolBar() {
        
        let topDivider = UIView()
        topDivider.backgroundColor = UIColor.lightGray
        
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDivider)
        addSubview(bottomDivider)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 50)
        
        topDivider.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        
        bottomDivider.anchor(top: nil, left: leftAnchor, bottom: stackView.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
