//
//  Comment.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 28/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    let text: String
    let uid: String
    
    init(user: User, dictionary: [String : Any]) {
        
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
