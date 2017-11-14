//
//  MainTabBarController.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 07/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                // Show LogInVC if user not signed in
                let logInVC = LogInVC()
                let navController = UINavigationController(rootViewController: logInVC)
                navController.isNavigationBarHidden = true
                self.present(navController, animated: true, completion: nil)
                return
            }
        }
        
        /* Specify the collectionView layout for UserProfileVC
        since it is a UICollectionViewController */
        let layout = UICollectionViewFlowLayout()
        let userProfileVC = UserProfileVC(collectionViewLayout: layout)
        
        let navController = UINavigationController(rootViewController: userProfileVC)
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        self.viewControllers = [navController, UIViewController()]
    }
}
