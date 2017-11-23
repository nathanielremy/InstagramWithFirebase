//
//  PreviewPhotoContainerView.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 23/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    // Stored properties
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleSave() {
        
        guard let previewImage = previewImageView.image else { return }
        
        // Hold a reference to the user's photo library
        let photoLibraryReference = PHPhotoLibrary.shared()
        photoLibraryReference.performChanges({
            
            // Add the image to the user's photo library
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
            
            
        }) { (success, error) in
            
            if let err = error { print("Failed to save image to photo library; ", err); return }
            
            if success {
                print("Successfuly saved image to photo library")
                
                // Get back on main thread to update UI
                DispatchQueue.main.async {
                    let savedLabel = UILabel()
                    savedLabel.text = "Saved Successfuly"
                    savedLabel.textAlignment = .center
                    savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                    savedLabel.numberOfLines = 0
                    savedLabel.textColor = .white
                    savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                    savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                    savedLabel.center = self.center
                    savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                    
                    self.addSubview(savedLabel)
                    
                    // Animate the saved label once image has been saved to photo library
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                        
                    }, completion: { (completed) in
                        
                        UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                            
                            savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                            savedLabel.alpha = 0
                            
                        }, completion: { (_) in
                          savedLabel.removeFromSuperview()
                        })
                    })
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(previewImageView)
        previewImageView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        addSubview(cancelButton)
        cancelButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        addSubview(saveButton)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: -12, paddingRight: 0, width: nil, height: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



























