//
//  PreviewPhotoContainerView.swift
//  MotoPreserve
//
//  Created by DANIEL I QUINTERO on 7/7/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import Firebase
//import DataCache

class PreviewPhotoContainerView: UIView {
    
    var project:FB_ProjectItem?
    var bike:FB_Bike?
    var projects:[FB_ProjectItem]?
    var bikes:[FB_Bike]?
    var tempImageName:String?
    
    var projectIndexPath:IndexPath?
    
    //var imagesCache:DataCache?
    
    let previewImageView:UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        saveButton.isEnabled = true
        
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        
        addSubview(saveButton)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom:24, paddingRight: 0, width: 60, height: 60)
    }
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
//    func saveBikes() {
//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes as Any, toFile: FB_Bike.ArchiveURL.path)
//        if isSuccessfulSave {
//            print("successfully saved")
//            //os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
//        } else {
//            print("un-successfully saved")
//            // os_log("Failed to save meals...", log: OSLog.default, type: .error)
//        }
//    }
    
    func saveBikes() {
        
       // project.imagesArray = projectImages
        //  bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = project
        //   bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
        
        BikeData.sharedInstance.allBikes = self.bikes!
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("successfully saved")
        } else {
            print("un-successfully saved")
        }
        
    }
    
    func updateBikes() {
        bikes = []
        if let savedBikes = loadUserBikes() {
            bikes = savedBikes
            //bikes += savedBikes
        }
        saveBikes()
        //project = bike.projects as! [FB_ProjectItem]
    }
    
    func loadUserBikes() -> [FB_Bike]?  {
        //self.checkCoachMark()
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }
    
//    func saveLocalImageToProjectImagesArray(name:String, item:FB_ProjectItem) {
//        //guard let image = selectedImage else {return}
//        //set the value here
//        //projectImages = []
//        //var dictionary = ["imageName":name]
//        print(name)
//        let timestamp:NSNumber = NSDate().timeIntervalSince1970 as NSNumber
//        let post = PostImage(imageName: self.tempImageName! , uniqueID: item.uniqueID, timestamp:timestamp, checked: false)
//        print(item.imagesArray?.count)
//        item.imagesArray?.append(post!)
//        print(item.imagesArray?.count)
//        //projectImages = item.imagesArray!
//
//        self.project = item
//        print("GIMME THE COUNT OF THE NEWEST PHOTOS")
//        print( "\( bikes?[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!].imagesArray?.count)")
//        bikes?[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!].imagesArray = item.imagesArray
//        print( "\( bikes?[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!].imagesArray?.count)")
//
//       // bikes?[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike!
//
//        //saveBikes()
//        updateBikes()
//
//    }
    
    func saveLocalImageToProjectImagesArray(name:String, item:FB_ProjectItem) {
        let id = NSUUID().uuidString
        let timestamp:NSNumber = NSDate().timeIntervalSince1970 as NSNumber
        let post = PostImage(imageName: name, uniqueID: id, timestamp:timestamp, checked: false)
        item.imagesArray?.append(post!)
       // projectImages = item.imagesArray!
        self.project = item
       // print("\(projectIndexPath) Project Index Path from save local")
        updateBikes()
        // print(item == bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!])
        //   bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = item
        //  bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
       // print("\(item.imagesArray?.count) = count of images before save")
        saveBikes()
        //updateBikes()
    }
    
    @objc func handleSave() {
        guard self.bike != nil else {return}
        guard self.bikes != nil else {return}
        guard self.project != nil else {return}
        guard let image = previewImageView.image  else {return}
        saveProjectImageToAlbum(image: image, view: self, isCameraView: true)
        //saveImageToAlbum(image: image, view: self, isCameraView: true)
        self.saveButton.isHidden = true
        self.saveButton.isEnabled = false
        
        //saveImageToProjects(bike: bike, project: project, previewImageView: previewImageView, cache:imagesCache!)
    }
    /////////////////////////
    ////This saves to the phone photo library in the "MotoPreserve" album
    func saveProjectImageToAlbum(image:UIImage, view:UIView, isCameraView:Bool = false) -> Void {
        let helper = MRPhotosHelper()
        var imageIdentifier:String?
        
        // save the image to library
        helper.saveImageAsAsset(image: image, completion: { (localIdentifier) -> Void in
            imageIdentifier = localIdentifier
            self.tempImageName = imageIdentifier
            self.saveLocalImageToProjectImagesArray(name:imageIdentifier! , item: self.project!)
        })
        
        self.removeFromSuperview()
    }
    /////////////////////////


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
