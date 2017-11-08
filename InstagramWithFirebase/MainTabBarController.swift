//
//  MainTabBarController.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 07/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
