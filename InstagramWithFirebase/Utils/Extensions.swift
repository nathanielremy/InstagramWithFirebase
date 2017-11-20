//
//  Extensions.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 05/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import Foundation
import UIKit
import Firebase

//MARK: Firebase Database
extension Database {
    static func fetchUserFromUserID(userID: String, completion: @escaping (User?) -> Void) {
        
        Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let userDictionary = dataSnapshot.value as? [String : Any] else {
                completion(nil)
                print("DataSnapshot dictionary not castable to [String:Any]"); return
            }
            
            let user = User(uid: userID,dictionary: userDictionary)
            completion(user)
            
        }) { (error) in
            print("Failed to fetch dataSnapshot of currentUser", error)
            completion(nil)
        }
    }
}

//MARK: UIColor
extension UIColor {
    
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

//MARK: UIView
extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat?, height: CGFloat?) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
