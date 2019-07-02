//
//  AddBikeViewController.swift
//  MP
//
//  Created by DANIEL I QUINTERO on 12/11/16.
//  Copyright © 2016 DanielIQuintero. All rights reserved.
//

import Foundation

import UIKit
import Photos
import UserNotifications
import Firebase
import FirebaseStorage
import FirebaseDatabase

protocol AddProjectViewControllerDelegate: class {
    func addProjectViewControllerDidCancel(_ controller: AddProjectViewController)
    func addProjectViewController(_ controller:AddProjectViewController, didFinishAdding item: FB_ProjectItem)
    func addProjectViewController(_ controller:AddProjectViewController, didFinishAddingAfterYes item: FB_ProjectItem)
    func addProjectViewController(_ controller:AddProjectViewController, didFinishAddingAfterCancel item: FB_ProjectItem)

    func addProjectViewController(_ controller:AddProjectViewController, didFinishAddingThumbnail item: FB_ProjectItem)
    func addProjectViewController(_ controller: AddProjectViewController, didFinishEditing item: FB_ProjectItem)
}

class AddProjectViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate {

    
    var doneBarButton: UIBarButtonItem?
    var cancelBarButton: UIBarButtonItem?
    var newItem:FB_ProjectItem?
    
    var stackView:UIStackView?
    
    var pickerView:UIPickerView =  UIPickerView()
    
    
    //
    var projectTextArray = [[FB_ProjectItem]]()
    var categoryArray = [String]()
    var dict = [String:[FB_ProjectItem]]()
    var sortedSections = [String]()
    var tableSection = [FB_ProjectItem]()
    var projects: [FB_ProjectItem]?
    //
    
    //Properties
    var bike:FB_Bike!
    var projectToEdit: FB_ProjectItem?
    var bikes:[FB_Bike] = []
    var selectedIndexPath:IndexPath!
    var projectIndexPath:IndexPath!
    var projectName:String?
    var tempImageName:String?
    
    var isFromNew:Bool = false
    var timestamp:NSNumber?
    
    weak var delegate: AddProjectViewControllerDelegate?
    
    var selectedImageFromPicker:UIImage?
    
    
    var observer: Any!
    // MARK: - Photos
    var assetCollection: PHAssetCollection!
    var albumFound : Bool = false
    var photosAsset: PHFetchResult<AnyObject>!
    var assetThumbnailSize:CGSize!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    var fromPhotoDetails:Bool = false
    
    var assetCollectionList:PHCollectionList?
    //
    var datePickerVisible = false
    var selectedCategory : String = "Misc."
    
    var categories = ["Misc.", "Body & Frame", "Chain & Fluids", "Control & Brake", "Electrical", "Engine & Exhaust", "Fuel & Air", "Suspension", "Wheels & Tires"]
    
    var dueDate = Date()
    var titleBar = TitleBar()
    var imageUrl:String?
    var thumbUrl:String?
    
    var ref: DatabaseReference?
    var projectsRef: DatabaseReference?
    
    let imageView:UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "thumb_placeholder")
       
        return iv
    }()
    
    var activeTextField = UITextField()
    var inActiveTextField = UITextField()
    
    var kbHeight: CGFloat!
    //
 
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    

    let topDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let middleDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let cameraButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "camera_pressed"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
        return button
    }()
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Name your project".uppercased()
        return label
    }()
    
    let nameTextField:UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = UIFont(name: "Avenir", size: 14)
        tf.textColor = UIColor.black
        tf.borderStyle = .roundedRect
        tf.layer.masksToBounds = true
        tf.text = ""
        tf.keyboardAppearance = .dark
        return tf
    }()
    
    let categoryLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Pick a category".uppercased()
        return label
    }()
    
    var topBarHeight: CGFloat = 0
    
    let notesTextView:UITextView = {
        let tf = UITextView()
        tf.textAlignment = .left
        tf.font = UIFont(name: "Avenir", size: 14)
        tf.textColor = UIColor.lightGray
        let borderColor : UIColor = .veryLightGray()
        tf.layer.borderColor = borderColor.cgColor
        //tf.borderStyle = .roundedRect
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 0.5
        tf.keyboardAppearance = .dark
        tf.text = ""
        return tf
    }()
    
    let thumbnailLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Change thumbnail".uppercased()
        return label
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
    
    let borderColor : UIColor = UIColor.lightGray
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        selectedIndexPath = BikeData.sharedInstance.selectedIndexPath
        notesTextView.text = "Notes:"
        
        
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
        
        print("VIEW DID LOAD PROJECT INDEX PATH \(projectIndexPath)")
        notesTextView.target(forAction: #selector(textViewDidBeginEditing(_:)), withSender: nil)
        notesTextView.target(forAction: #selector(textViewDidEndEditing(_:)), withSender: nil)
  
        
        scrollView.isUserInteractionEnabled = true
        
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        
        view.addSubview(scrollView)
        scrollView.backgroundColor = .white
        scrollView.addSubview(svContentView)
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: topBarHeight + 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width:0, height:0)
        
        svContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height * 1.25)
        
        svContentView.addSubview(pickerView)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        scrollView.delegate = self
        
        stackView = UIStackView(arrangedSubviews: [self.nameLabel, self.nameTextField])
        stackView?.distribution = .fillEqually
        stackView?.axis = .vertical
        stackView?.distribution = UIStackView.Distribution(rawValue: Int(1.0))!
        svContentView.addSubview(stackView!)
      
        titleBar.addTitleBarAndLabel(page: view, initialTitle: "Add a Project", ypos: topBarHeight, color:.mainRed())

        svContentView.addSubview(self.thumbnailLabel)
        svContentView.addSubview(self.categoryLabel)
        svContentView.addSubview(self.notesTextView)
        svContentView.addSubview(self.imageView)
        svContentView.addSubview(cameraButton)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        scrollView.delegate = self
        
        notesTextView.delegate = self
        
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        
        doneBarButton?.isEnabled = false
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = cancelBarButton
        doneBarButton?.tintColor = .mainRed();
        cancelBarButton?.tintColor = .mainRed()
        
        stackView?.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 60)
        
        self.categoryLabel.anchor(top: stackView?.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 20)

        pickerView.anchor(top: categoryLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 100)
        
        self.notesTextView.anchor(top: pickerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 75)
        
        self.thumbnailLabel.anchor(top: notesTextView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        self.thumbnailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        
        self.cameraButton.anchor(top: thumbnailLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        imageView.anchor(top: self.cameraButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: view.frame.width/3, height: view.frame.width/3)
        self.cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let imageWidth = (view.frame.width)/3
        imageView.layer.cornerRadius = (imageWidth)/2
        imageView.layer.borderWidth = 1;
        
        imageView.layer.borderColor = borderColor.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        let toolBar = UIToolbar()

        let barDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        barDoneButton.tintColor = .mainRed()
        toolBar.setItems([flexibleSpace, barDoneButton], animated: true)
        toolBar.sizeToFit()
        notesTextView.inputAccessoryView = toolBar
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        
        self.nameTextField.delegate = self
        self.nameTextField.returnKeyType = .done
        self.nameTextField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEnd)
        self.nameTextField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        
        self.notesTextView.returnKeyType = .default
        self.notesTextView.target(forAction: #selector(textViewDidChange(_:)), withSender: self)
        self.notesTextView.target(forAction: #selector(textView(_:shouldChangeTextIn:replacementText:)), withSender: self)
        
        
        if let item = projectToEdit {
            thumbnailLabel.isHidden = false
            cameraButton.isHidden = false
            imageView.isHidden = false
            
            pickerView.selectRow(getSelectedCategory(item: item, currentString: item.category!), inComponent: 0, animated: true)
            guard item.category != nil else {return}
            selectedCategory = categories[getSelectedCategory(item: item, currentString: item.category!)]

            if (item.imageName != nil) {
                imageView.isHidden = false
                guard let imageName = item.imageName else {return}
                showThumb(thumbName: imageName, item:item)
            } else {
//              showImage(image: #imageLiteral(resourceName: "thumb_placeholder"))
                imageView.image = #imageLiteral(resourceName: "bikeThumbNail")
            }
            
            self.titleBar.updateTitle(newTitle:"Edit a Project")
            nameTextField.text = item.text
            doneBarButton?.isEnabled = true
                if item.category != nil {
                    selectedCategory = item.category!
                }
            
            if item.notes != "Notes:" || item.notes != nil {
                
                notesTextView.text = item.notes
                if notesTextView.text != "Notes:" {
                    notesTextView.textColor = .black
                }
                
            } else {
                notesTextView.text = "Notes:"
                notesTextView.textColor = UIColor.lightGray
            }
            
//            notesTextView.text = item.notes
//            if notesTextView.text.isEmpty || notesTextView.text == "Notes"{
//                notesTextView.text = item.notes
//                if notesTextView.text != "Notes:" {
//                    notesTextView.textColor = .black
//                }
//            } else {
//                notesTextView.textColor = .black
//            }
            timestamp = item.timestamp
        }
            
        else {
            self.titleBar.updateTitle(newTitle: "Add a Project")
            thumbnailLabel.isHidden = true
            cameraButton.isHidden = true
            imageView.isHidden = true
            doneBarButton?.isEnabled = false
        }
    }
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        if activeTextField == nameTextField {
            print("my text field name is \(activeTextField)")
             activeTextField = inActiveTextField
            return
        }
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        var kbHeight = (keyboardFrame.height - 60) * (show ? 1 : -1)
        
        if !show {
            let returnHeight = 0
            kbHeight = CGFloat(returnHeight)
        }
        let point:CGPoint = CGPoint(x: 0.0, y: kbHeight)
        scrollView.setContentOffset(point, animated: true)
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
       
        doneBarButton?.isEnabled = false
        print("this is hit")
        if textView.text.isEmpty || textView.text == "Notes:" {
            textView.text = nil
            textView.textColor = .black
      }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("my text field name is \(textField)")
         activeTextField = textField
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
   
        if let txt = self.nameTextField.text {
            print("this is hit too, when done")
            let newText = txt as NSString
            doneBarButton?.isEnabled = ((newText.length) > 0)
        }
    }
    

    @objc func doneClicked(){
        
        print("done clicked here")
        if projectToEdit != nil {
            projectToEdit?.notes = notesTextView.text
           // bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = projectToEdit!
           // bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
            saveBikes()
            print("got here")
             self.notesTextView.scrollRangeToVisible(NSMakeRange(0, 0))
            view.endEditing(true)
        }
        else {
            view.endEditing(true)
        }
        if notesTextView.text.isEmpty {
            notesTextView.text = "Notes:"
            notesTextView.textColor = UIColor.lightGray
        } else {
            notesTextView.textColor = .black
        }
    }
    
    @objc func cancel() {
        delegate?.addProjectViewControllerDidCancel(self)
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
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard (self.notesTextView.text) != nil else {return}
    }
    
    @objc  
    func didChangeText(textField:UITextField) {
        guard let txt = self.nameTextField.text else {return}
        let newText = txt as NSString
        doneBarButton?.isEnabled = ((newText.length) > 0)
        if newText.length > 0 {
            nameLabel.tintColor = .lightGray
        } else {
            nameLabel.tintColor = .darkGray
        }
    }
    
    @objc func done() {
        
        guard let bike = self.bike else {
            return
        }
        
        if let item = projectToEdit {
            if !(nameTextField.text?.isEmpty)! {
                item.text = nameTextField.text
                 projectName = item.text!
            }
           
            item.category = selectedCategory
            //print("SHOW ME THE CATEGORY \(item.category)")
            item.notes = notesTextView.text
            print(bikes)
            print(selectedIndexPath)
            print(projectIndexPath)

         
       
            self.isFromNew = false
            var _:String?
            var _:String?
            var _:UIImage?
            
            if self.selectedImageFromPicker != nil {
                 item.imageName = tempImageName
            }
            
            showThumb(thumbName: "bikeThumbNail", item:item)
            bikes[(selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!].notes = item.notes
            bikes[(selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!].text = item.text
            bikes[(selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!].category = item.category
           // bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = projectToEdit!
            bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
            
        //saveBikes()
           // 
            delegate?.addProjectViewController(self, didFinishEditing: item)
            
        } else {
            let thumbImageName:String = ""
            let timestamp:NSNumber = NSDate().timeIntervalSince1970 as NSNumber
            let itemID = NSUUID().uuidString
            let item = FB_ProjectItem(text: nameTextField.text!, uniqueID: itemID, category: selectedCategory, thumbUrl: thumbUrl, imageUrl: imageUrl, notes: notesTextView.text, bike: bike, thumbName: thumbImageName, imageName: nil, imagesArray:[], timestamp:timestamp)
     
            self.isFromNew = true
            self.projectToEdit = item
            
            bike.projects?.append(item!)
            
            let savedBikes = loadUserBikes()
            self.bikes = savedBikes!
            //bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
            bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects? = bike.projects!
            bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
           
            updateBikes()
            print("DID FINISH ADDING IN PROJECTS **")
            print("        THE BIKE.PROJECTS COUNT IS: \(String(describing: bike.projects?.count))")
          
            let alertController = UIAlertController(title: "Add a Thumbnail Image", message: nil, preferredStyle: .alert)
              alertController.view.tintColor = .black
                alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { (_) in
                    alertController.dismiss(animated: true, completion: nil)
                    self.isFromNew = false
                    if let p = self.projectToEdit {
                        self.delegate?.addProjectViewController(self, didFinishAdding: p)
                    }
                }))

                alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                    self.isFromNew = true
                    if let p = item {
                        self.delegate?.addProjectViewController(self, didFinishAddingAfterYes: p)
                    }
                    self.pickPhoto()
                }))
                saveBikes()
                present(alertController, animated: true, completion:nil)
                }
            }
    
        func setupTitleValues() {
            self.categoryArray = []
            self.projectTextArray = []
            self.dict = [:]
            self.sortedSections = []
            self.tableSection = []
        
        if let projects = self.projects {
            for item in projects {
                self.categoryArray.append(item.category!)
            }
            let mySet = Set<String>(categoryArray)
            categoryArray = Array(mySet)
            categoryArray.sort{$0 < $1}
        }
        self.projectTextArray = Array(repeating: [FB_ProjectItem]() , count: categoryArray.count )
        if let projects = self.projects {
            for i in 0..<projects.count {
                for k in 0..<categoryArray.count {
                    if projects[i].category == categoryArray[k] {
                        projectTextArray[k].append(projects[i])
                    }
                }
                //making the dictionary here
                for (index, element) in categoryArray.enumerated()
                {
                    self.dict[element] = projectTextArray[index]
                }
                self.sortedSections = categoryArray
            }
        }
        print("THESE ARE THE SORTED SECTIONS \(self.sortedSections)")
    }
    
 
func addThumbnailImage(item: FB_ProjectItem) {
    
    if self.selectedImageFromPicker != nil {
        item.imageName = tempImageName
    }
    bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
    saveBikes()
    delegate?.addProjectViewController(self, didFinishAdding: item)
}

     func loadUserBikes() -> [FB_Bike]?  {
        //print("loading user bikes from Projects")
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }
    
//    func updateBikes() {
//        //print("updating bikes")
//        bikes = []
//        if let savedBikes = loadUserBikes() {
//            bikes = savedBikes
//            //bikes += savedBikes
//        }
//        saveBikes()
//    }
    func updateBikes() {
        bikes = []
        if let savedBikes = loadUserBikes() {
            bikes = savedBikes
            BikeData.sharedInstance.allBikes = bikes
        }
        projects = bike.projects
        saveBikes()
    }
    
     func saveBikes() {
        BikeData.sharedInstance.allBikes = bikes
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("successfully saved new category")
        } else {
            print("un-successfully saved")
        }
    }

    func showImage(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
    }
    
    func showThumb(thumbName: String, item:FB_ProjectItem) {
        if item.imageName != nil {
            let helper = MRPhotosHelper()
            if let identifier = item.imageName {
                helper.retrieveImageWithIdentifer(localIdentifier: identifier, completion: { (image) -> Void in
                    self.imageView.image = image
                })
            }
        } else {
            imageView.image = #imageLiteral(resourceName: "bikeThumbNail")
        }
        imageView.isHidden = false
    }
 
    //Picker View
    func getSelectedCategory(item:FB_ProjectItem, currentString:String) -> Int {
        for i in 0..<categories.count {
            if item.category == categories[i] {
                return i
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label = view as! UILabel?
        if label == nil {
            label = UILabel()
        }
        
        let data = categories[row]
        let title = NSAttributedString(string: data, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir", size: 16)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
        print("\(selectedCategory) THIS IS THE SELECTED VALUE FROM PICKER")
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        }
    }

extension AddProjectViewController: UIImagePickerControllerDelegate  {
    @objc func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
         alertController.view.layoutIfNeeded()
        alertController.view.tintColor = .black
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.tintColor = UIColor.mainRed()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
      func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.tintColor = UIColor.mainRed()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] {
            selectedImageFromPicker = originalImage as? UIImage
        }

        if let theImage = selectedImageFromPicker {
            showImage(image: theImage)
            let _:NSData = theImage.jpegData(compressionQuality: 1)! as NSData
            showImage(image: theImage)
            saveProjectImageToAlbum(image: theImage, view: self.view)
        }
        
        dismiss(animated: true, completion: nil)
        
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
            if (self.isFromNew) {
                self.addThumbnailImage(item: self.projectToEdit!)
            }
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if let p = self.projectToEdit {
            self.delegate?.addProjectViewController(self, didFinishAdding: p)
        }
        dismiss(animated: true, completion: nil)
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
