//
//  CommentsCell.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 27/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit

class CommentsCell: UICollectionViewCell {
    
    //MARK: Stored properties
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            
            profileImageView.loadImage(from: comment.user.profileImageURLString)
            
            let attributedText = NSMutableAttributedString(string: comment.user.username + " ", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.black])
            attributedText.append(NSAttributedString(string: comment.text, attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.black]))
            
            commentTextView.attributedText = attributedText
        }
    }
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        
        return tv
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: -8, paddingRight: -8, width: nil, height: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
