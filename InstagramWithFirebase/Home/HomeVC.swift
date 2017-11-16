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
        fetchPosts()
    }
    
    fileprivate func fetchPosts() {
        guard let userID = Auth.auth().currentUser?.uid else { print("Firebase could not return uid"); return }
        
        let databaseReference = Database.database().reference().child("posts").child(userID)
        databaseReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let snapshotDictionaries = dataSnapshot.value as? [String:Any] else {
                print("Unable to construct dataSnapshot dictionary for posts node"); return
            }
            
            snapshotDictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String : Any] else { return }
                
                let post = Post(dictionary: dictionary)
                self.posts.append(post)
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
        let width = view.frame.width
        
        return CGSize(width: width, height: 200)
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
