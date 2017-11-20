//
//  UserSearchVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 20/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class UserSearchVC: UICollectionViewController {
    
    // Stored properties
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .red
    }
}
