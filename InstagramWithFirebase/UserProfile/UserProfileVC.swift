//
//  UserProfileVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 07/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //Stored properties
    var userID: String?
    
    var user: User?
    let cellID = "cellID"
    let homePostCellID = "homePostCellID"
    var posts = [Post]()
    
    var isGridView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        // Register the collectionView cell
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
        collectionView?.register(UserProfileGridCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellID)
        
        setUpLogOutButton()
        fetchUser()
    }
    
    fileprivate func setUpLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                let loginVC = LogInVC()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutError {
                print("Failed to sign out: ", signOutError)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Add section header for collectionView as supplementary kind
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Dequeue reusable collectionViewHeaderCell
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as? UserProfileHeader else {
            print("UserProfileHeader cell is unconstructable"); fatalError()
        }
        
        header.user = self.user
        header.delegate = self
        return header
    }
    
    // How many cells in the collectionView ?
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    // What does each cell look like ?
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserProfileGridCell
            
            if !posts.isEmpty {
                cell.post = posts[indexPath.item]
            }
            
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellID, for: indexPath) as! HomePostCell
            
            if !posts.isEmpty {
                cell.post = posts[indexPath.item]
            }
            
            cell.delegate = self
            
            return cell
        }
    }
    
    // What's the horizontal spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // What's the vertical spacing between each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // What's the size of each cell ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            
            var height: CGFloat = 40 + 8 + 8 // userProfileImageView
            height += view.frame.width // sharedImageView
            height += 50 // Like, comment, share buttons
            height += 60 // caption and creationDate
            
            let width = view.frame.width
            return CGSize(width: width, height: height)
        }
     }
    
    // Need to provide a size or the header will not render out
    // Define the size of the section header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    fileprivate func fetchUser() {
        // Retrieve the correct user's userID
        let userID = self.userID ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.fetchUserFromUserID(userID: userID) { (user) in
            
            if let user = user {
                self.user = user
                self.navigationItem.title = user.username
                
                self.collectionView?.reloadData()
                
                self.fetchOrderedPosts(forUserID: user.uid)
            }
        }
    }
    
    fileprivate func fetchOrderedPosts(forUserID userID: String) {
        
        let databaseReference = Database.database().reference().child("posts").child(userID)
        databaseReference.queryOrdered(byChild: "creationnDate").observe(.childAdded, with: { (dataSnapshot) in
            
            guard let dictionary = dataSnapshot.value as? [String : Any] else { return }
            guard let user = self.user else { return }
            
            var post = Post(user: user, dictionary: dictionary)
            post.id = dataSnapshot.key
            
            self.posts.insert(post, at: 0)
            //self.posts.append(post)
            
            self.collectionView?.reloadData()
            
            
        }) { (error) in
            print("Failed to fetch ordered posts: ", error)
        }
    }
}


//MARK: UserProfileHeaderDelegate methods
extension UserProfileVC: UserProfileHeaderDelegate {
    
    func didChangeToGridView() {
        print("UserProfileVC didChangeToGridView func call")
        self.isGridView = true
        self.collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        print("UserProfileVC didChangeToListView func call")
        self.isGridView = false
        self.collectionView?.reloadData()
    }
}

//MARK: HomePostCellDelegate Methods
extension UserProfileVC: HomePostCellDelegate {
    
    func didTapComment(fromPost post: Post) {
        
        print("Post Caption: ", post.caption)
        
        let commentsVC = CommentsVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentsVC.post = post
        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func didLikePost(for cell: HomePostCell) {
        
        guard let indexPath = collectionView?.indexPath(for: cell) else {
            print("Could not return the indexPath for the liked cell"); return
        }
        
        var post = self.posts[indexPath.item]
        
        guard let postID = post.id else { print("Post item contains no postID"); return }
        guard let currentUserID = Auth.auth().currentUser?.uid else { print("could not retrieve the current user's UID"); return }
        
        let values = [currentUserID : post.hasLiked ? 0 : 1]
        
        let databasereferance = Database.database().reference().child("likes").child(postID)
        databasereferance.updateChildValues(values) { (err, _) in
            
            if let error = err {
                print("Failed to update likes/\(postID)\(currentUserID)", error); return
            }
            print("Successfully liked post: ", post.caption)
            
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
}
