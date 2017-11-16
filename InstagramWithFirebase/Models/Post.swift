//
//  Posts.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 16/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import Foundation

struct Post {
    
    let imageURLString: String
    
    init(dictionary: [String:Any]) {
        
        self.imageURLString = dictionary["imageURL"] as? String ?? ""
        
    }
}
