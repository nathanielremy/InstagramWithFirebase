//
//  PhotoSelectorHeader.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 15/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit

class PhotoSelectorHeader: UICollectionViewCell {
    
    // Stored properties
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
