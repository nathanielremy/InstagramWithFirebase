//
//  CurrentUser.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 09/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import Foundation

struct CurrentUser {
    
    let username: String
    let profileImageURL: String
    
    init(dictionary: [String : Any]) {
        self.username = dictionary["username"] as? String ?? "No Username"
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
    }
}
