//
//  CommentsVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 24/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: UICollectionViewController {
    
    // Stored properties
    var post: Post?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView?.backgroundColor = .red
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
}
