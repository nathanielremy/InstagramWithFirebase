//
//  HomeVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 16/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: stored properties
    let cellID = "cellID"
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellID)
        
        // Manualy refresh the collectionView
        let refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshController
        
        setUpNavigationItems()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchFollowingPosts()
        fetchOwnPosts()
    }
    
    @objc func handleRefresh() {
        self.posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchOwnPosts() {
        guard let userID = Auth.auth().currentUser?.uid else { print("Firebase could not return current user id"); return }
        
        Database.fetchUserFromUserID(userID: userID) { (user) in
            if let user = user {
                self.fetchPostsWithUser(user: user)
            } else {
                fatalError()
            }
        }
    }
    
    fileprivate func fetchFollowingPosts() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { print("Firebase could not fetch current user id"); return }
        
        let followingRef = Database.database().reference().child("following").child(currentUserID)
        followingRef.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let dictionary = dataSnapshot.value as? [String:Any] else { return }
            
            dictionary.forEach({ (key, value) in
                Database.fetchUserFromUserID(userID: key, completion: { (user) in
                    if let user = user {
                        self.fetchPostsWithUser(user: user)
                    }
                })
            })
        }) { (error) in
            print("Failed to fetch following: ", error )
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        
        let databaseReference = Database.database().reference().child("posts").child(user.uid)
        databaseReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let snapshotDictionaries = dataSnapshot.value as? [String:Any] else {
                print("Unable to construct dataSnapshot dictionary for posts node"); return
            }
            
            snapshotDictionaries.forEach({ (key, value) in
                guard let postDictionary = value as? [String : Any] else { return }
                
                var post = Post(user: user, dictionary: postDictionary)
                post.id = key
                
                guard let currentUserID = Auth.auth().currentUser?.uid else { print("Could not retrieve the currentuserID"); return }
                
                Database.database().reference().child("likes").child(key).child(currentUserID).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    
                    if let value = dataSnapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    
                    self.posts.append(post)
                    // Rearrange the posts array to be from most recent to oldest
                    self.posts.sort(by: { (post1, post2) -> Bool in
                        return post1.creationDate.compare(post2.creationDate) == .orderedDescending
                    })
                    
                    self.collectionView?.reloadData()
                    self.collectionView?.refreshControl?.endRefreshing()
                    
                }, withCancel: { (error) in
                    print("Error retrieving dataSnapshot for likes/\(key)\(currentUserID): ", error)
                })
            })
        }) { (error) in
            print("Unable to return dataSnapshot for posts node: ", error)
        }
    }
    
    func setUpNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
    }
    
    @objc func handleCamera() {
        let cameraVC = CameraVC()
        present(cameraVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // userProfileImageView
        height += view.frame.width // sharedImageView
        height += 50 // Like, comment, share buttons
        height += 60 // caption and creationDate
        
        let width = view.frame.width
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomePostCell
        
        cell.delegate = self
        
        if !posts.isEmpty {
            cell.post = posts[indexPath.item]
        }
        return cell
    }
}

//MARK: HomePostCellDelegate Methods
extension HomeVC: HomePostCellDelegate {
    
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
