//
//  HomeVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 16/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // stored properties
    let cellID = "cellID"
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellID)
        
        setUpNavigationItems()
        fetchAllPost()
    }
    
    fileprivate func fetchAllPost() {
        fetchFollowingPosts()
        fetchOwnPosts()
    }
    
    fileprivate func fetchOwnPosts() {
        guard let userID = Auth.auth().currentUser?.uid else { print("Firebase could not return current user id"); return }
        
        Database.fetchUserFromUserID(userID: userID) { (user) in
            if let user = user {
                self.fetchPostsWithUser(user: user)
            } else {
                fatalError()
            }
        }
    }
    
    fileprivate func fetchFollowingPosts() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { print("Firebase could not fetch current user id"); return }
        
        let followingRef = Database.database().reference().child("following").child(currentUserID)
        followingRef.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let dictionary = dataSnapshot.value as? [String:Any] else { return }
            
            dictionary.forEach({ (key, value) in
                Database.fetchUserFromUserID(userID: key, completion: { (user) in
                    if let user = user {
                        self.fetchPostsWithUser(user: user)
                    }
                })
            })
        }) { (error) in
            print("Failed to fetch following: ", error )
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        
        let databaseReference = Database.database().reference().child("posts").child(user.uid)
        databaseReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let snapshotDictionaries = dataSnapshot.value as? [String:Any] else {
                print("Unable to construct dataSnapshot dictionary for posts node"); return
            }
            
            snapshotDictionaries.forEach({ (key, value) in
                guard let postDictionary = value as? [String : Any] else { return }
                
                let post = Post(user: user, dictionary: postDictionary)
                self.posts.append(post)
            })
            
            // Rearrange the posts array to be from most recent to oldest
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate.compare(post2.creationDate) == .orderedDescending
            })
            
            self.collectionView?.reloadData()
            
        }) { (error) in
            print("Unable to return dataSnapshot for posts node: ", error)
        }
    }
    
    func setUpNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // userProfileImageView
        height += view.frame.width // sharedImageView
        height += 50 // Like, comment, share buttons
        height += 60 // caption and creationDate
        
        let width = view.frame.width
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomePostCell
        
        if !posts.isEmpty {
            cell.post = posts[indexPath.item]
        }
        return cell
    }
}
