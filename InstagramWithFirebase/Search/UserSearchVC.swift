//
//  UserSearchVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 20/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class UserSearchVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    // Stored properties
    var users = [User]()
    var filteredUsers = [User]()
    let cellID = "cellID"
    
    // Needs to be lazy var to access "self"
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.delegate = self
        sb.placeholder = "Enter username"
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(230, 230, 230)
        
        return sb
    }()
    
    // UISearchBarDelegate methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.filteredUsers = self.users
        } else {
            self.filteredUsers = self.users.filter({ (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            })
        }
        self.collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellID)
        
        navigationController?.navigationBar.addSubview(searchBar)
        searchBar.anchor(top: navigationController?.navigationBar.topAnchor, left: navigationController?.navigationBar.leftAnchor, bottom: navigationController?.navigationBar.bottomAnchor, right: navigationController?.navigationBar.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: -8, paddingRight: -8, width: nil, height: nil)
        
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchBar.isHidden = false
    }
    
    fileprivate func fetchUsers() {
        
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let dictionaries = dataSnapshot.value as? [String:Any] else {
                print("dataSnapShot not castable to [String : Any"); return
            }
            
            // Retrieve all users from database and store them in array
            dictionaries.forEach({ (key, value) in
                
                if key == Auth.auth().currentUser?.uid {
                    print("Found myself!! "); return
                }
                
                guard let userDictionary = value as? [String : Any] else { return }
                
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            })
            self.filteredUsers = self.users
            self.collectionView?.reloadData()
            
        }) { (error) in
            print("Error fetching users for search", error)
        }
    }
    
//    UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: 66)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.searchBar.isHidden = true
        self.searchBar.resignFirstResponder()
        
        let user = filteredUsers[indexPath.item]
        print(user.username)
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.userID = user.uid
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserSearchCell
        
        cell.user = filteredUsers[indexPath.item]
        
        return cell
    }
}
