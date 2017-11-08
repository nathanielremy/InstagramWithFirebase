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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        // Register the collectionView cell
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
        fetchUser()
    }
    
    // Add section header for collectionView as supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Dequeue reusable collectionViewHeaderCell
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath)
        return header
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
            if let snapShotDictionary = dataSnapshot.value as? [String:Any], let username = snapShotDictionary["username"] as? String {
                
                self.navigationItem.title = username
                
            } else {
                print("Unable to retrive username from dataSnapshot dictionary")
            }
        }) { (error) in
            print("Error fetching user:", error)
        }
    }
}
