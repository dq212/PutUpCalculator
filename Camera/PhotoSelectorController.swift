//
//  PhotoSelectorController.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 5/21/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import Photos
import Firebase

//protocol PhotosViewControllerDelegate: class {
//    func photosViewControllerDidSave(_ controller: PhotoSelectorController, project: FB_ProjectItem, bike: FB_Bike)
//}

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    var delegate = UICollectionViewController.self
    var pv_delegate = PhotosViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        setupNavigationButtons()
        
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        fetchPhotos()
    }
    
    var images = [UIImage]()
    var selectedImage:UIImage?
    var assets = [PHAsset]()
    var projectName:String!
    var project:FB_ProjectItem!
    var bike:FB_Bike!
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions{
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 20
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
       
        return fetchOptions
    }
    
    func fetchPhotos() {
         let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects({ (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                })
                
                if count == allPhotos.count - 1 {
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        

        
        let width = view.frame.width
        return CGSize(width: width, height: 50)
    }
    
    var header: PhotoSelectorHeader?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        header.backgroundColor = .green
        
        header.photoImageView.image = selectedImage
        
        if let selectedImage = selectedImage {
            if let index = self.images.firstIndex(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                    imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { (image, info) in
                       header.photoImageView.image = image
                })
            }
        }
        return header
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        self.collectionView?.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
         navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    fileprivate func setupNavigationButtons(){
        navigationController?.navigationBar.tintColor = UIColor.mainRed()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSave() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        
//        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
//            return
//        }
//        guard let projectName = project.text else {
//            return
//        }
//        guard let image = selectedImage  else {return}
//        //guard let uploadData = UIImagePNGRepresentation(image) else { return }
//        guard let uploadData = UIImageJPEGRepresentation(image, 0.6) else {return}
//        
//        let filename = NSUUID().uuidString
//        
//      let ref = FIRStorage.storage().reference().child("users").child(uid).child("userBikes").child(bike.uniqueID!).child("projects").child(project.uniqueID!).child("images").child(filename)
//        ref.put(uploadData, metadata: nil) { (metadata, err) in
//            
//        if let err = err {
//            print("Failed to upload saved image", err)
//            return
//            }
//            
//        guard let imageUrl = metadata?.downloadURL()?.absoluteString else {return}
//            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
//        }
        
//        let uploadPhotoController = UploadPhotoController()
//        uploadPhotoController.selectedImage = header?.photoImageView.image
//        navigationController?.pushViewController(uploadPhotoController, animated: true)
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userRef = Database.database().reference().child("users").child(uid).child("userBikes").child(self.bike.uniqueID!).child("projects").child(self.project.uniqueID!).child("images")
        
        let ref = userRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl, "creationDate": NSTimeIntervalSince1970 ] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            
            if let err = err {
                print("Failed to save image to DB", err)
                return
                }
            
            print("Successfully saved image to DB")
            //self.pv_delegate.photosViewControllerDidSave(self, project: self.project, bike: self.bike)
            //self.dismiss(animated: true, completion: nil)
            
            }

    }
        //HERE is where I'm putting the url in the database to later pull from the Storage
    

}
