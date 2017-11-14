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
    var currentUser: CurrentUser?
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        // Register the collectionView cell
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
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
        
        header.currentUser = self.currentUser
        return header
    }
    
    // How many cells in the collectionView ?
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    // What does each cell look like ?
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        
        cell.backgroundColor = .purple
        
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
    
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    fileprivate func fetchUser() {
        // Retrieve the currently authorized user's userID
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error getting currentUserID"); return
        }
        
        // Attempt at retrieving a snapshot of the user's
       Database.database().reference().child("users").child(currentUserID).observeSingleEvent(of: .value, with: { (dataSnapshot) in
        
        // Cast the DataSnapshot as a swift type and find the value you are looking for
            if let snapshotDictionary = dataSnapshot.value as? [String:Any] {
                
                self.currentUser = CurrentUser(dictionary: snapshotDictionary)
                self.navigationItem.title = self.currentUser?.username
                // MAKE SURE TO RELOAD COLLECTIONVIEW
                self.collectionView?.reloadData()
                
            } else {
                print("Unable to construct dataSnapshot dictionary")
            }
        }) { (error) in
            print("Error fetching user:", error)
        }
    }
}