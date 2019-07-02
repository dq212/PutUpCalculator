//
//  PhotosViewController.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 2/20/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import Photos
import FirebaseDatabase
import FirebaseStorage
import Firebase
//import DataCache

protocol PhotosViewControllerDelegate: class {
    func photosViewController(_ controller:PhotosViewController, didFinishAddingThumbnail item: FB_ProjectItem)
    func photosViewController(_ controller: PhotosViewController, didFinishEditing item: FB_ProjectItem)
}

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, PhotoAlbumHeaderDelegate, UIScrollViewDelegate, UITextViewDelegate, CameraControllerDelegate, UIDocumentInteractionControllerDelegate {
    
    var photosArray = [String]()
    
    
    
    var assetCollection:PHAssetCollection = PHAssetCollection()
    var photosAsset:PHFetchResult<PHAsset>?
    var albumFound:Bool = false
    
    var bikeCollectionList:PHCollectionList?
    var albumName:String?
    var indexPath:IndexPath?
    
    var selectedImage:UIImage?
    
    //these have default values for the first instance -- since there is no saved reference to save images too yet -->
    var projectIndexPath:IndexPath?
    var projects:[FB_ProjectItem]!
    
    var documentController:UIDocumentInteractionController = UIDocumentInteractionController()
    
    var index:Int = 0
    
    var titleBar:TitleBar = TitleBar()
    weak var delegate: PhotosViewControllerDelegate?
    
    var isGridView = true
    
    var isSelectionView = false
    var fromPhotoDetails:Bool?
    
    var isChecked:Bool = false
    
    var header:PhotoAlbumHeader?
    
    var collectionView:UICollectionView?
    
    var projectThumbName:String?
    
    var projectImages = [PostImage]()
    
    func didDeleteView() {
    collectionView?.reloadData()
    }
    
    func didSelectionView() {
        toggleToolBarItems()
    }
    
    func didSelectCameraView() {
        pickPhoto()
    }
    
    let photoCell = "photoCell"
    let listCell = "listCell"
    let headerId = "headerId"
    let gridCell = "gridCell"
    
    //Properties
    var project:FB_ProjectItem!
    var projectName:String!
    var bike:FB_Bike!
    var bikes:[FB_Bike] = []
    
    var collectionList:PHCollectionList?
    var selectedImageFromPicker:UIImage?
    var appCollectionList:PHCollectionList?
    
    var btnTrash: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    func btnPhotoAlbum(_ sender: Any) {
                let layout = UICollectionViewFlowLayout()
        let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
        let navController = UINavigationController(rootViewController: photoSelectorController)
            photoSelectorController.projectName = project.text
            photoSelectorController.project = project
            photoSelectorController.bike = bike
        present(navController, animated: true, completion: nil)
     }
    
    func addProjectThumbnailImage(item:FB_ProjectItem) {
        
    }
 
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        header = (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! PhotoAlbumHeader)
        header?.titleBar.addTitleBarAndLabel(page: header!, initialTitle: "PROJECT DETAILS", ypos: 0)
        header?.bike = self.bike
        header?.project = self.project
        if project.imageName != nil {
            let helper = MRPhotosHelper()
            if let identifier = project.imageName {
                helper.retrieveImageWithIdentifer(localIdentifier: identifier, completion: { (image) -> Void in
                    self.header?.thumbnailImageView.image = image
                })
            }
        } else {
            header?.thumbnailImageView.image = #imageLiteral(resourceName: "bikeThumbNail")
        }
        header?.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleEditProject))
        header?.thumbnailImageView.addGestureRecognizer(tap)
        header?.thumbnailImageView.isUserInteractionEnabled = true
        return header!
    }
    
    @objc func handleEditProject() {
        saveBikes()
        let addProjectViewController = AddProjectViewController()
        let navController = UINavigationController(rootViewController: addProjectViewController)
        _ = ProjectViewController()
        addProjectViewController.delegate = self.delegate as? AddProjectViewControllerDelegate
        addProjectViewController.bike = self.bike
        addProjectViewController.bikes = self.bikes
        addProjectViewController.projectIndexPath = self.projectIndexPath
        print(self.projectIndexPath)
        addProjectViewController.projectToEdit = self.project
        self.present(navController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 121)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            var width = (view.frame.width - 2) / 3
        if (projectImages.count > 6) {
            width = (view.frame.width - 4 ) / 5
        }
            return CGSize(width: width, height: width)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    let notesTextView: UITextView = {
        let notes = UITextView()
        notes.textColor = .black
        notes.font = UIFont(name: "Avenir", size: 15)
        notes.keyboardAppearance = .dark //.default//.light//.alert
        return notes
    }()
    
    var topBarHeight: CGFloat = 0
    
    let notesTitleBar: UIView = {
        let v = UIView()
        v.backgroundColor = .tableHeaderBG()
        return v
    }()
    
    let notesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 12)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.text = "Notes"
        return label
    }()
    
    let topDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .veryLightGray()
        return view
    }()
    
    let bottomDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .veryLightGray()
        return view
    }()
    
    let scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    var svContentView:UIView = {
        let v = UIView()
        return v
    }()
    
    var selectButton:UIBarButtonItem?
    var backToProjectsButton:UIBarButtonItem?
    var selectedImagesArray = [PostImage]()
    var kbHeight: CGFloat!

    

    
    @objc func keyboardWillShow(_ notification: Notification) {
            trashBarButton.isEnabled = false
            shareBarButton.isEnabled = false
            cameraBarButton.isEnabled = false
            adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if isSelectionView {
            trashBarButton.isEnabled = true
            shareBarButton.isEnabled = true
            cameraBarButton.isEnabled = false
        } else {
            trashBarButton.isEnabled = false
            shareBarButton.isEnabled = false
            cameraBarButton.isEnabled = true
        }
                adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    let selectToolBar:UIToolbar = {
        let t = UIToolbar()
        t.backgroundColor = .veryLightGray()
        return t
    }()
    
   var trashBarButton:UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .mainRed()
        return button
    }()
    
    var cameraBarButton:UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .mainRed()
        return button
    }()
    
    var flexBarButtonLeft:UIBarButtonItem = {
        let button = UIBarButtonItem()
        return button
    }()
    
    var flexBarButtonRight:UIBarButtonItem = {
        let button = UIBarButtonItem()
        return button
    }()
    
    var shareBarButton:UIBarButtonItem = {
        let button = UIBarButtonItem()
        return button
    }()
    
    var postDictionary:[String: AnyObject] = [:]
    let toolBar = UIToolbar()
    let barDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    
    //Toolbar button handlers
    @objc func shareHandler() {
        for item in projectImages {
            if (item.checked == true) {
                selectedImagesArray.append(item)
            }
        }
        handleShare()
    }
    
    @objc func deleteHandler() {
        for item in projectImages {
            if (item.checked == true) {
                selectedImagesArray.append(item)
            }
        }
         handleTrash()
    }

    func deleteImage(selectedImagesArray:[PostImage]) {

        //saveBikes()
        print("ALL THE IMAGES...\(projectImages)")
        print("THE SELECTED IMAGES ...\(selectedImagesArray)")
        //filter and keep non-selected items and reloadke
        projectImages = projectImages.filter({!$0.checked!})
        print("ALL THE IMAGES --- AFTER THE FILTER...\(projectImages)")
//        bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!].imagesArray = projectImages
        saveBikes()
        handleSelect()
        collectionView?.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
       // checkForThumbnail()
    }
    
    func checkStatus() {
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
           // self.createAlbum()
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            //may have to make an alert here to let folks know about the photos
        }
            
        else if (status == PHAuthorizationStatus.notDetermined) {
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                  //  self.createAlbum()
                }
                else {
                    //
                }
            })
        }
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }
        //textField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        imagePicker.navigationBar.tintColor = UIColor.mainRed()
        checkStatus()
        print("@@@@@@ \(projectIndexPath)")
//      checkPermission()
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        trashBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteHandler))
        cameraBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(pickPhoto))
        flexBarButtonLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        flexBarButtonRight = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareHandler))

        let barButtonArray = [shareBarButton,flexBarButtonLeft,cameraBarButton, flexBarButtonRight, trashBarButton]
        
        for item in barButtonArray {
            item.tintColor = .mainRed()
            item.isEnabled = false
        }
        
        cameraBarButton.isEnabled = true
    
        selectToolBar.setItems(barButtonArray, animated: true)
//        let bikeThumbDictionary = ["imageUrl": self.bike.thumbnailUrl, "uniqueID":self.bike.uniqueID]
//        let projectThumbDictionary = ["imageUrl": self.project.thumbUrl,"uniqueID":self.bike.uniqueID]
//        let bikeThumbPost = PostImage(dictionary: bikeThumbDictionary)
//        let projectThumbPost = PostImage(dictionary: projectThumbDictionary)
//        self.projectImages.append(bikeThumbPost)
//        self.projectImages.append(projectThumbPost)
        
        toolBar.barTintColor = .tableHeaderBG()
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)
        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(handleSelect))
        navigationItem.rightBarButtonItem = selectButton
        selectButton?.isEnabled = false
        
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)
        
        //
        navigationItem.leftBarButtonItem?.tintColor = .mainRed()
        navigationItem.rightBarButtonItem?.tintColor = .mainRed()
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)
        
        backToProjectsButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBackToProjects))
        backToProjectsButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        backToProjectsButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        backToProjectsButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        backToProjectsButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        backToProjectsButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)

        navigationItem.leftBarButtonItem = backToProjectsButton
        //setupViewResizerOnKeyboardShown()
        
        scrollView.isUserInteractionEnabled = true
      
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        self.navigationController?.navigationBar.tintColor = .mainRed();
        
        view.addSubview(scrollView)
        //scrollView.backgroundColor = UIColor.tableViewBgGray()
        scrollView.addSubview(svContentView)

        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width:0, height:0)
        
        svContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height*1.8)
                
        view.backgroundColor = UIColor.tableViewBgGray()
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.svContentView.frame, collectionViewLayout: layout)
        collectionView?.backgroundColor = .white
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        scrollView.delegate = self
        notesTextView.delegate = self
        self.notesTextView.target(forAction: #selector(textViewDidChange(_:)), withSender: self)
        self.notesTextView.target(forAction: #selector(textView(_:shouldChangeTextIn:replacementText:)), withSender: self)
        notesTextView.target(forAction: #selector(textViewDidBeginEditing(_:)), withSender: nil)
        collectionView?.backgroundColor = .white
    
        svContentView.addSubview(collectionView!)
        collectionView?.anchor(top: svContentView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: (view.frame.height / 5) * 3.5)
        svContentView.addSubview(selectToolBar)
        
        svContentView.addSubview(notesTitleBar)
        svContentView.addSubview(topDividerView)
        svContentView.addSubview(bottomDividerView)
        notesTitleBar.addSubview(notesLabel)
        svContentView.addSubview(notesTextView)

        topDividerView.anchor(top: collectionView?.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)
//
        selectToolBar.anchor(top: nil, left: view.leftAnchor, bottom: topDividerView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//
        notesTitleBar.anchor(top: topDividerView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 20)
        notesLabel.anchor(top: notesTitleBar.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0)
//
        bottomDividerView.anchor(top: notesTitleBar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)
//
        svContentView.addSubview(notesTextView)
        notesTextView.anchor(top: notesTitleBar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 80, paddingRight: 10, width: 0, height: 200)
        
    
    
//
//        if (project.notes != nil) {
//            self.notesTextView.text = project.notes ?? "Notes:"
//        }
//
     //   print(self.notesTextView.text)
//        print("\(project) ))))))))))))))))))))))))))))))))))))))))))))))))))))))")
     //   print(project.notes)
        
        notesLabel.centerYAnchor.constraint(equalTo: notesTitleBar.centerYAnchor).isActive = true
        
        if  self.project.imagesArray != nil {
//            print("\(self.project.text) is the name of the project")
            self.projectImages = self.project.imagesArray!
//            print(self.projectImages)
            for i in 0..<self.projectImages.count {
                projectImages[i].checked = false
            }
        }
        
        self.projectName = project.text
        self.notesTextView.text = project.notes
        
        
        if (project.imageName != nil) {
            guard let imageName = project.imageName else {return}
            showThumb(imageName: imageName)
        } else {
            showThumb(imageName: "thumb_placeholder")
        }
            self.albumName = "MotoPreserve"
        
            collectionView?.register(PhotoAlbumHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
//          collectionView?.register(ProjectDetailCell.self, forCellWithReuseIdentifier: listCell)
            collectionView?.register(ProjectPhotoCell.self, forCellWithReuseIdentifier: gridCell)
            projectImages = []
            getPosts()
        
            barDoneButton.tintColor = .white
            toolBar.setItems([flexibleSpace, barDoneButton], animated: true)
            barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
            barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
            barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
            barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
            toolBar.sizeToFit()
            notesTextView.inputAccessoryView = toolBar

        }
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        var kbHeight = (keyboardFrame.height) * (show ? 1 : -1)
        
        if !show {
            let returnHeight = -topBarHeight
            kbHeight = CGFloat(returnHeight)
        }
        let point:CGPoint = CGPoint(x: 0.0, y: kbHeight)
        scrollView.setContentOffset(point, animated: true)
        //scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("this is hit")
        if textView.text.isEmpty || textView.text == "Notes:" {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
  
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
        //view.endEditing(true)
          // textView.text = textView.text + "\n"
            return true
        } else {
            return true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard (self.notesTextView.text) != nil else {return}
    }
    
   
    
    @objc func doneClicked(){
    
        project.notes = notesTextView.text
        updateBikes()
        self.notesTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        
        //bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!].notes = project.notes
        //bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = project
        
        saveBikes()
        view.endEditing(true)
        if notesTextView.text.isEmpty {
            notesTextView.text = "Notes:"
            notesTextView.textColor = UIColor.lightGray
        } else {
            notesTextView.textColor = .black
        }
    }
    
    func handleTrash() {
        if (selectedImagesArray.count > 0) {
             let alert = UIAlertController(title: "Delete Image(s)", message: "Are you sure you want to DELETE?", preferredStyle: .alert)
                alert.view.tintColor = UIColor.black
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {(alertAction) in
                      self.deleteImage(selectedImagesArray: self.selectedImagesArray)
                    }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(alertAction) in
                        //Do not delete photo
            self.resetSelections()
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion:nil)
        } else if (selectedImagesArray.count == 0) {
            let alert = UIAlertController(title: "Can't delete", message: "You have not selected any images.", preferredStyle: .alert)
                alert.view.tintColor = UIColor.mainRed()
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                        alert.dismiss(animated: true, completion: nil)
            }))
                self.present(alert, animated: true, completion:nil)
            }
        }
    
    func handleShare() {
       // let size:CGSize = CGSize(width: 1024, height: 2048.0)
        let imagesArray = NSMutableArray()
        var stringArray:[String] = []
        let option = PHImageRequestOptions()

        let imgManager = PHImageManager.default()
        if (selectedImagesArray.count > 0) {
            let alert = UIAlertController(title: "Share Image(s)", message: "Are you ready to share?", preferredStyle: .alert)
           
            alert.view.tintColor = .black
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {(alertAction) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {(alertAction) in
                for i in 0..<self.selectedImagesArray.count {
                    stringArray.append(self.selectedImagesArray[i].imageName)
                    print("\(self.project.imagesArray![i].imageName) name from projects")
                    print("\(self.selectedImagesArray[i].imageName) name from selected images")
                }
                print(stringArray)
                
                    let manager = PHImageManager.default()
                    let option = PHImageRequestOptions()
                    option.isSynchronous = true
                if let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: stringArray, options: nil) {
                if fetchResult.count > 0 {
                 for j in 0..<stringArray.count {
                    manager.requestImage(for: fetchResult.object(at: j), targetSize:CGSize(width: fetchResult.object(at: j).pixelWidth, height: fetchResult.object(at: j).pixelHeight), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                       // thumbnail = result!
                         imagesArray.add(result as Any)
                    })
            }
              
//                if let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: stringArray, options: nil) {
//                 if fetchResult.count > 0 {
//                        print(stringArray)
//                        for j in 0..<stringArray.count {
//                            imgManager.requestImage(for: fetchResult.object(at: j) as PHAsset, targetSize:CGSize(width: fetchResult.object(at: j).pixelWidth, height: fetchResult.object(at: j).pixelHeight), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
//                                imagesArray.add(result as Any)
//                                print(fetchResult.object(at: j).pixelWidth)
//                                print(fetchResult.object(at: j).pixelHeight)
//
//                            })
//                        }
                    }
                }
                let activityController = UIActivityViewController(activityItems:imagesArray as! [Any] , applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
                self.selectedImagesArray = []
                self.resetSelections()
            }))
           
            self.present(alert, animated: true, completion:nil)
        } else if (selectedImagesArray.count == 0) {
            
            let alert = UIAlertController(title: "Can't share", message: "You have not selected any images.", preferredStyle: .alert)
             alert.view.tintColor = UIColor.mainRed()
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                alert.dismiss(animated: true, completion: nil)
               // self.resetSelections()
            }))
            self.present(alert, animated: true, completion:nil)
        }
    }
    
     func getPosts(){
        self.projectImages = []
        if let savedBikes = self.loadUserBikes() {
            self.bikes = savedBikes
            guard let p = project.imagesArray else {return}
            self.projectImages = p
//            DispatchQueue.main.async {
//                self.collectionView?.reloadData()
//            }
        } else {
        }
    }

    func updateBikes() {
        bikes = []
        if let savedBikes = loadUserBikes() {
            bikes = savedBikes
        }
//        DispatchQueue.main.async {
//            self.collectionView?.reloadData()
//        }
        getPosts()
        //saveBikes()
    }
    
     func loadUserBikes() -> [FB_Bike]?  {
        print("loading user bikes from Projects")
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }
    
     func saveBikes() {
        
        project.imagesArray = projectImages
      //  bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = project
     //   bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
        
        BikeData.sharedInstance.allBikes = self.bikes
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("successfully saved")
        } else {
            print("un-successfully saved")
        }
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func shareImages(selectedImagesArray: [PostImage]) {
        handleSelect()
    }

    func showThumb(imageName: String) {
        if project.imageName != nil {
            let helper = MRPhotosHelper()
        if let identifier = project.imageName {
            helper.retrieveImageWithIdentifer(localIdentifier: identifier, completion: { (image) -> Void in
               self.header?.thumbnailImageView.image = image
            })
        } else {
            self.header?.thumbnailImageView.image = #imageLiteral(resourceName: "bikeThumbNail")
            }
        }
    }

     override func viewWillAppear(_ animated: Bool) {
        //fetch photos from collection
        self.navigationController?.hidesBarsOnTap = false
        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        self.header?.projectLabel.text = self.project.text
        self.header?.categoryLabel.text = self.project.category
        //No photos in the assetCollection
        //...Have a label that says "No photos"
        if project.imageName != nil {
        let helper = MRPhotosHelper()
        if let identifier = project.imageName {
            helper.retrieveImageWithIdentifer(localIdentifier: identifier, completion: { (image) -> Void in
                self.header?.thumbnailImageView.image = image
            })
            }
        else {
            self.header?.thumbnailImageView.image = #imageLiteral(resourceName: "bikeThumbNail")
            }
        }
        if project.notes != nil {
            notesTextView.text = project.notes
        }
    }
    
    @objc func handleBackToProjects() {
        print("PROJECT INDEX PATH IS \(self.projectIndexPath) FROM HANDLE BACK TO PROJECTS")
        //collectionView?.collectionViewLayout.invalidateLayout() // or reloadData()
//        DispatchQueue.main.async {
//            self.collectionView?.reloadData()
//            }
       // DispatchQueue.main.async {
            // your stuff here executing after collectionView has been layouted
            self.delegate?.photosViewController(self, didFinishAddingThumbnail: self.project)
        //}
        
        //saveBikes()
       // self.delegate?.photosViewController(self, didFinishAddingThumbnail: self.project)
    }
    
    func resetSelections() {
        for selected in selectedImagesArray {
            selected.checked = false
        }
        selectedImagesArray = []
        for item in projectImages {
            item.checked = false
        }
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    @objc func handleSelect() {
        isSelectionView = !isSelectionView
        toggleToolBarItems()
        
        if(isSelectionView) {
            selectButton?.title = "Cancel"
            selectedImagesArray = []
            resetSelections()
        }else {
            for item in projectImages {
                item.checked = false
                selectedImagesArray = []
            }
           selectButton?.title = "Select"
        }
//        DispatchQueue.main.async {
//            self.collectionView?.reloadData()
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UICollectionViewDataSource Methods
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = projectImages.count
        if (self.photosAsset != nil && (self.photosAsset?.count)! > 0) {
            count = (self.photosAsset?.count)!
        }
        print(" \(count) is the photo asset count")
        return count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Modify the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCell, for: indexPath) as! ProjectPhotoCell
        cell.post = projectImages[indexPath.item]
        cell.selectMarker.isHidden = !projectImages[indexPath.item].checked!
        selectButton?.isEnabled = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.indexPath = indexPath
        self.index = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCell, for: indexPath) as! ProjectPhotoCell
        guard let header = header else {return}
        if isSelectionView == true {
            let item = projectImages[indexPath.row]
            item.toggleChecked()
            //cell.toggleChecked()
            configureCheckmark(for: cell, with: item)
            collectionView.reloadItems(at: [indexPath])
        } else {
            let fullScreenPhoto = FullViewPhotoViewController()
            fullScreenPhoto.post = projectImages[indexPath.item]
            navigationController?.pushViewController(fullScreenPhoto, animated: true)
        }
    }
    
    //Flow layout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }
    }

extension PhotosViewController: UIImagePickerControllerDelegate {
    @objc func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
            print("Choosing from library")
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = .black
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.handleCamera() })
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        alertController.addAction(chooseFromLibraryAction)
        alertController.view.layoutIfNeeded()
        present(alertController, animated: true, completion: nil)
    }
    
    func handleCamera() {
        let cameraController = CameraController()
            cameraController.project = self.project
            cameraController.delegate = self
            cameraController.projects = self.projects
            cameraController.bike = self.bike
            cameraController.bikes = self.bikes
            cameraController.projectIndexPath = self.projectIndexPath
        let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            view.window!.layer.add(transition, forKey: kCATransition)
            present(cameraController, animated: false, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        imagePicker.navigationBar.tintColor = UIColor.mainRed()
        present(imagePicker, animated: true, completion: nil)
    }
    
    //UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let theImage = selectedImageFromPicker {
            self.selectedImage = theImage
            self.saveImageToAlbum(image: theImage, view: self.view)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    ////This saves to the phone photo library in the "MotoPreserve" album
    func saveImageToAlbum(image:UIImage, view:UIView, isCameraView:Bool = false) -> Void {
        let helper = MRPhotosHelper()
        var imageIdentifier:String?
        // save the image to library
        helper.saveImageAsAsset(image: image, completion: { (localIdentifier) -> Void in
            imageIdentifier = localIdentifier
                self.saveLocalImageToProjectImagesArray(name:imageIdentifier! , item: self.project)
        })
    }
  
    func saveLocalImageToProjectImagesArray(name:String, item:FB_ProjectItem) {
        let id = NSUUID().uuidString
        let timestamp:NSNumber = NSDate().timeIntervalSince1970 as NSNumber
        let post = PostImage(imageName: name, uniqueID: id, timestamp:timestamp, checked: isChecked)
        item.imagesArray?.append(post!)
        projectImages = item.imagesArray!
        self.project = item
        print("\(projectIndexPath) Project Index Path from save local")
        updateBikes()
       // print(item == bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!])
     //   bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = item
      //  bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
        print("\(item.imagesArray?.count) = count of images before save")
        saveBikes()
        //updateBikes()
    }
    
    func configureCheckmark(for cell: ProjectPhotoCell, with item: PostImage) {
        cell.selectMarker.isHidden = cell.checked!
    }
    
   func toggleToolBarItems() {
    if projectImages.count < 1{
        shareBarButton.isEnabled = false
        cameraBarButton.isEnabled = true
        trashBarButton.isEnabled = false
        return
    }
    if (isSelectionView == true) {
        shareBarButton.isEnabled = true
        cameraBarButton.isEnabled = false
        trashBarButton.isEnabled = true
        } else {
        shareBarButton.isEnabled = false
        cameraBarButton.isEnabled = true
        trashBarButton.isEnabled = false
        }
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func cameraController(_ controller:CameraController, didFinishAddingThumbnail item: FB_ProjectItem) {
        updateBikes()
//        bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
//        BikeData.sharedInstance.allBikes = bikes
        //saveBikes()
//        getPosts()
//        DispatchQueue.main.async {
//            self.collectionView?.reloadData()
//        }
        saveBikes()
    }
}

extension PHPhotoLibrary {
    // MARK: - PHPhotoLibrary+SaveImage
    func savePhoto(image:UIImage, albumName:String, completion:((PHAsset?)->())? = nil) {
        func save() {
            if let album = PHPhotoLibrary.shared().findAlbum(albumName: albumName) {
                PHPhotoLibrary.shared().saveImage(image: image, album: album, completion: completion)
            } else {
                PHPhotoLibrary.shared().createAlbum(albumName: albumName, completion: { (collection) in
                    if let collection = collection {
                        PHPhotoLibrary.shared().saveImage(image: image, album: collection, completion: completion)
                    } else {
                        completion?(nil)
                    }
                })
            }
        }
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            save()
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    save()
                }
            })
        }
    }
    
    // MARK: - Private
    fileprivate func findAlbum(albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else {
            return nil
        }
        return photoAlbum
    }
    
    fileprivate func createAlbum(albumName: String, completion: @escaping (PHAssetCollection?)->()) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                guard let placeholder = albumPlaceholder else {
                    completion(nil)
                    return
                }
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album = fetchResult.firstObject else {
                    completion(nil)
                    return
                }
                completion(album)
            } else {
                completion(nil)
            }
        })
    }
    
    fileprivate func saveImage(image: UIImage, album: PHAssetCollection, completion:((PHAsset?)->())? = nil) {
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else { return }
            placeholder = photoPlaceholder
            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)
        }, completionHandler: { success, error in
            guard let placeholder = placeholder else {
                completion?(nil)
                return
            }
            if success {
                let assets:PHFetchResult<PHAsset> =  PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                let asset:PHAsset? = assets.firstObject
                completion?(asset)
            } else {
                completion?(nil)
            }
        })
    }
}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
