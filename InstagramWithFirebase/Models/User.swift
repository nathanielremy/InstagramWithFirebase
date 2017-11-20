//
//  CurrentUser.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 09/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let username: String
    let profileImageURLString: String
    
    init(uid: String, dictionary: [String : Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? "No Username"
        self.profileImageURLString = dictionary["profileImageURL"] as? String ?? ""
    }
}
