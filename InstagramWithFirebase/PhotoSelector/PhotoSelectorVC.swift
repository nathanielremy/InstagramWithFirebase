//
//  PhotoSelectorVC.swift
//  InstagramWithFirebase
//
//  Created by Nathaniel Remy on 15/11/2017.
//  Copyright © 2017 Nathaniel Remy. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let headerID = "headerID"
    let cellID = "cellID"
    var images = [UIImage]()
    var selectedImage: UIImage?
    var assets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        setUpNavButtons()
        
        // Register the cells
        collectionView?.register(PhotoselectorCell.self, forCellWithReuseIdentifier: cellID)
        // Register the header
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        
        fetchPhotos()
    }
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 10
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                let imageManager = PHImageManager.default()
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                })
            }
        }
     }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    // Spacing between header and cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    // Need to provide a size or the header will not render out
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = view.frame.width
        
        return CGSize(width: width, height: width)
    }
    
    var header: PhotoSelectorHeader?
    
    // Render out the head
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! PhotoSelectorHeader
        
        self.header = header
        
       header.photoImageView.image = selectedImage
       
        if let selectedImage = selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let selectedAsset = self.assets[index]
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil, resultHandler: { (image, info) in
                    
                    header.photoImageView.image = image
                })
            }
        }
       return header
    }
    
    //Whats the horizontal spacing between cells ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // Whats the vertical spacing between cells ?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // What's the size of each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    // How many cells to render
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    // What cells to render
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoselectorCell
        
        cell.photoImageView.image = self.images[indexPath.item]
        
        return cell
    }
    
    // What happens when user selects a cell ?
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedImage = self.images[indexPath.item]
        self.collectionView?.reloadData()
        
        let index = IndexPath(item: 0, section: 0)
        self.collectionView?.scrollToItem(at: index, at: .bottom, animated: true)
    }
    
    fileprivate func setUpNavButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    @objc func handleNext() {
        let sharePhotoVC = SharePhotoVC()
        sharePhotoVC.selectedImage = self.header?.photoImageView.image
        
        navigationController?.pushViewController(sharePhotoVC, animated: true)
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
