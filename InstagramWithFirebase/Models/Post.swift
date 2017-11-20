//
//  Posts.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 16/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    
    let user: User
    let imageURLString: String
    let caption: String
    
    init(user: User, dictionary: [String : Any]) {
        
        self.user = user
        self.imageURLString = dictionary["imageURL"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
    }
}
