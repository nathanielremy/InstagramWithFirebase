//
//  MainTabBarController.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 07/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.index(of: viewController)
        
        if index == 2 {
            
            let layout = UICollectionViewFlowLayout()
            let photoSelectorVC = PhotoSelectorVC(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: photoSelectorVC)
            
            present(navController, animated: true, completion: nil)
            
            return false
        } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                // Show LogInVC if user not signed in
                let logInVC = LogInVC()
                let navController = UINavigationController(rootViewController: logInVC)
                navController.isNavigationBarHidden = true
                self.present(navController, animated: true, completion: nil)
                return
            }
        } else {
            setUpViewControllers()
        }
    }
    
    func setUpViewControllers() {
        // Home
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // Search
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: UserSearchVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // Plus
        let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        // Like
        let likeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"))
        
        // User Profile
        /* Specify the collectionView layout for UserProfileVC
         since it is a UICollectionViewController */
        let layout = UICollectionViewFlowLayout()
        let userProfileVC = UserProfileVC(collectionViewLayout: layout)
        
        let userProfileNavController = UINavigationController(rootViewController: userProfileVC)
        userProfileNavController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfileNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        self.viewControllers = [
        homeNavController,
        searchNavController,
        plusNavController,
        likeNavController,
        userProfileNavController
        ]
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let vC = rootViewController
        let navVC = UINavigationController(rootViewController: vC)
        navVC.tabBarItem.image = unselectedImage
        navVC.tabBarItem.selectedImage = selectedImage
        
        return navVC
    }
}
