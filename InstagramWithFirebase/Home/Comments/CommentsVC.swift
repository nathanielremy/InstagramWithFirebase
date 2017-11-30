//
//  CommentsVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 24/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // Stored properties
    var comments = [Comment]()
    var post: Post?
    let cellID = "cellID"
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment"
        
        return tf
    }()
    
    
    // Must be lazy var
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -12, width: 50, height: nil)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        let lineSepratorView = UIView()
        lineSepratorView.backgroundColor = UIColor.rgb(230, 230, 230)
        
        containerView.addSubview(lineSepratorView)
        lineSepratorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        
        return containerView
    }()
    
    @objc func handleSend() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Could not get currentUserId"); return
        }
        guard let postID = self.post?.id else {
            print("Post does not contain an ID"); return
        }
        guard let comment = commentTextField.text, comment != "" else {
            print("CommentTextField is empty"); return
        }
        
        let values = ["text" : comment, "creationDate" : Date().timeIntervalSince1970, "uid" : uid] as [String : Any]
        Database.database().reference().child("comments").child(postID).childByAutoId().updateChildValues(values) { (err, databaseReference) in
            
            if let error = err {
                print("Error uploading comment: ", error)
            }
            print("Succesfully uploaded comment: ", comment)
            self.commentTextField.text = ""
        }
    }
    
    // Don't have to handle the position of the view
    // UIKit will do all of the work for you
    override var inputAccessoryView: UIView? {
        get {
            return self.containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    fileprivate func fetchComments() {
        guard let postID = self.post?.id else {
            print("cannot fetch comments without post.id"); return
        }
        
        let dataBasereference = Database.database().reference().child("comments").child(postID)
        dataBasereference.observe(.childAdded, with: { (dataSnapshot) in
            
            guard let dictionary = dataSnapshot.value as? [String : Any] else {
                print("DataSnapshot for commentsVC not castable as [String : Any]"); return
            }
            
            guard let uid = dictionary["uid"] as? String else { print("No uid returned from comments dictionary"); return }
            
            Database.fetchUserFromUserID(userID: uid, completion: { (user) in
                
                if let user = user {
                    
                    let comment = Comment(user: user, dictionary: dictionary)
                    self.comments.append(comment)
                    self.collectionView?.reloadData()
                    
                }
           })
        }) { (error) in
            print("Error fetching comments for \(postID)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        collectionView?.register(CommentsCell.self, forCellWithReuseIdentifier: cellID)
        fetchComments()
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the tabBar when the viewController will appear
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reshow the tabBar when the viewController gets dismissed
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: CollectionView delegate methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CommentsCell
        
        cell.comment = self.comments[indexPath.item]
        
        return cell
    }
    
    //MARK: UICollectionViewDelegateFlowLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // AutoSize the cells
        
        // MUST BE IN THIS ORDER !!!
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentsCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }    
}
