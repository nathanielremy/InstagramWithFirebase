//
//  UserProfileVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 07/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //Stored properties
    var userID: String?
    
    var user: User?
    let cellID = "cellID"
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        // Register the collectionView cell
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
        collectionView?.register(UserProfileGridCell.self, forCellWithReuseIdentifier: cellID)
        
        setUpLogOutButton()
        fetchUser()
    }
    
    fileprivate func setUpLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                let loginVC = LogInVC()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutError {
                print("Failed to sign out: ", signOutError)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Add section header for collectionView as supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Dequeue reusable collectionViewHeaderCell
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as? UserProfileHeader else {
            print("UserProfileHeader cell is unconstructable"); fatalError()
        }
        
        header.user = self.user
        return header
    }
    
    // How many cells in the collectionView ?
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    // What does each cell look like ?
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserProfileGridCell
        
        if !posts.isEmpty {
            cell.post = posts[indexPath.item]
        }
        
        return cell
    }
    
    // What's the horizontal spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // What's the size of each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    fileprivate func fetchUser() {
        // Retrieve the correct user's userID
        let userID = self.userID ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.fetchUserFromUserID(userID: userID) { (user) in
            
            if let user = user {
                self.user = user
                self.navigationItem.title = user.username
                
                self.collectionView?.reloadData()
                
                self.fetchOrderedPosts(forUserID: user.uid)
            }
        }
    }
    
    fileprivate func fetchOrderedPosts(forUserID userID: String) {
        
        let databaseReference = Database.database().reference().child("posts").child(userID)
        databaseReference.queryOrdered(byChild: "creationnDate").observe(.childAdded, with: { (dataSnapshot) in
            
            guard let dictionary = dataSnapshot.value as? [String : Any] else { return }
            guard let user = self.user else { return }
            
            let post = Post(user: user, dictionary: dictionary)
            
            self.posts.insert(post, at: 0)
            //self.posts.append(post)
            
            self.collectionView?.reloadData()
            
            
        }) { (error) in
            print("Failed to fetch ordered posts: ", error)
        }
    }
}
