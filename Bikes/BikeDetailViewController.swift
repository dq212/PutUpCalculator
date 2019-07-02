//
//  BikeDetailViewController.swift
//  MP
//
//  Created by DANIEL I QUINTERO on 12/24/16.
//  Copyright © 2016 DanielIQuintero. All rights reserved.
//

import UIKit
import CoreData
import Photos
import Firebase
import FirebaseDatabase
import FirebaseStorage
import DataCache
import os.log

protocol BikeDetailViewControllerDelegate: class {
    func bikeDetailViewControllerDidCancel(_ controller: BikeDetailViewController)
    func bikeDetailViewController(_ controller: BikeDetailViewController, didFinishAdding bike: FB_Bike)
    func bikeDetailViewController(_ controller: BikeDetailViewController, didFinishAddingThumbnail bike: FB_Bike)

    func bikeDetailViewController(_ controller: BikeDetailViewController, didFinishEditing bike: FB_Bike)
}

class BikeDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate,
UITextFieldDelegate{

    var doneBarButton: UIBarButtonItem?
    var cancelBarButton: UIBarButtonItem?
    
    var userCache:DataCache?
    var makeModelYearCache:DataCache?
    
    var jsonCache:DataCache?
    
    let dottedLineView1 = UIView()
    let dottedLineView2 = UIView()
    
    

    var appAlbumName:String = "MotoPreserve"
    var collectionList:PHCollectionList?
    var albumMainFound : Bool = false
    
    // MARK: - Photos
    var bikeCollectionList: PHCollectionList!
    var albumFound : Bool = false
    var photosAsset: PHFetchResult<AnyObject>!
    var assetThumbnailSize:CGSize!
    var assetCollection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    var request:PHAssetCollectionChangeRequest?
    
    var appAlbumPlaceholder:PHObjectPlaceholder?
    //
    var albumCollection:PHFetchResult<PHAssetCollection>?
    var createAlbumRequest:PHAssetCollectionChangeRequest?
    
    var ref: DatabaseReference?
    var allRef: DatabaseReference?
    
    var bikesRef: DatabaseReference?
    var tempImageName:String?
    var albumName: String?
    
    var timestamp:NSNumber?
    
    var makeArray = [String]()
    var modelArray = [String]()
    var yearArray = [String]()
    
    var stockData = [String]()
    
    var imageUrl:String?
    var thumbUrl:String?
    
    var currentMileage:String?
    var currentHours:String?
    
    weak var delegate: BikeDetailViewControllerDelegate?
    var bikeToEdit: FB_Bike!
    
    var bikes:[FB_Bike]?
    
    var makeName = "No Make Selected"
    var modelName = "No Model Selected"
    var bikeYear = "No Year Selected"
    
    var stackView:UIStackView?
    
    var selectedImageFromPicker:UIImage?
    var observer: Any!
    
    var pickerView:UIPickerView =  UIPickerView()
    var pickerDataSource=[[]]
    
    var titleBar = TitleBar()
    
    var isConnected:Bool?
    var uid:String?
    
    var activeTextField = UITextField()

    var imageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = (iv.frame.width/2)
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "thumb_placeholder")
        return iv
    }()

    func showImage(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
    }
    
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    var topBarHeight: CGFloat = 0
    
    
    
    func showThumb(imageName: String, bike:FB_Bike) {

        if bike.imageName != nil {
            let helper = MRPhotosHelper()
            if let identifier = bike.imageName {
                helper.retrieveImageWithIdentifer(localIdentifier: identifier, completion: { (image) -> Void in
                         self.imageView.image = image
                })
            }
        } else {
            imageView.image = #imageLiteral(resourceName: "bikeThumbNail")
        }
        imageView.isHidden = false
    }
    
    var svContentView:UIView = {
        let v = UIView()
        return v
    }()
    
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
    
    let thumbnailLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Add a thumbnail".uppercased()
        return label
    }()
    
    let hoursMilesLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Hours/Miles/Km"
        return label
    }()
    
    let milesHoursToggleSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = false
        s.tintColor = .mainRed()
        s.onTintColor = .mainRed()
        return s
    }()
    
    let milesHoursSegmentedControl: UISegmentedControl = {
        let items = ["Hours","Miles","Km"]
        let sc = UISegmentedControl(items: items)
        sc.backgroundColor = UIColor.white
        sc.tintColor = UIColor.mainRed()
        sc.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!], for: UIControl.State.normal)
        sc.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!], for: UIControl.State.highlighted)
        return sc
    }()
    
    let currentMileageLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "current mileage".uppercased()
        return label
    }()
    
    let mileageTextField:UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = UIFont(name: "Avenir", size:14)
        tf.textColor = UIColor.darkGray
        tf.borderStyle = .roundedRect
        tf.layer.masksToBounds = true
        tf.attributedPlaceholder = NSAttributedString(string: "Enter Current Mileage", attributes: [NSAttributedString.Key.foregroundColor: UIColor.veryLightGray()])
        tf.text = ""
        tf.keyboardAppearance = .dark
        tf.keyboardType = .numberPad
        return tf
    }()
    
    var valueType:String = "Miles"
//    var isMiles = true
    
    let toolBar:UIToolbar = {
        let t = UIToolbar()
        t.backgroundColor = .veryLightGray()
        return t
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
            label.text = "Name your bike".uppercased()
            return label
        }()
    
    let selectLabel:UILabel = {
        let label = UILabel()
            label.textAlignment = .left
            label.font = UIFont(name:"Avenir", size:12)
            label.textColor = UIColor.darkGray
            label.numberOfLines = 0
            label.text = "Select your Make, Model, and Year".uppercased()
            return label
    }()
        
    let nameTextField:UITextField = {
            let tf = UITextField()
            tf.textAlignment = .left
            tf.font = UIFont(name: "Avenir", size: 14)
            tf.textColor = UIColor.black
            tf.borderStyle = .roundedRect
            tf.layer.masksToBounds = true
            tf.keyboardAppearance = .dark
            tf.placeholder = "Name your Bike"
            tf.text = ""
            return tf
        }()
    
     let borderColor : UIColor = UIColor.lightGray
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        checkMyConnection()
    }
 
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    // Assign the newly active text field to your activeTextField variable
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawDottedLines()

        self.topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
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
        
           // scrollView.contentSize = CGSize(width: self.view.bounds.width , height: 2000)
        scrollView.isUserInteractionEnabled = true
        milesHoursSegmentedControl.addTarget(self, action: #selector(toggleMilesHours), for: .valueChanged)
        let toolBar = UIToolbar()
        let barDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        barDoneButton.tintColor = .mainRed()
        toolBar.setItems([flexibleSpace, barDoneButton], animated: true)
        toolBar.sizeToFit()
        
        checkPermission()
        view.addSubview(scrollView)
        scrollView.addSubview(svContentView)
        view.backgroundColor = .white
        svContentView.addSubview(pickerView)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)

//            self.nameLabel,
        stackView = UIStackView(arrangedSubviews: [ self.nameTextField])
        stackView?.distribution = .fillEqually
        stackView?.axis = .vertical
        stackView?.distribution = UIStackView.Distribution(rawValue: Int(1.0))!
        svContentView.addSubview(stackView!)
        
        svContentView.addSubview(self.selectLabel)
        //view.addSubview(self.middleDividerView)
        svContentView.addSubview(self.thumbnailLabel)
        svContentView.addSubview(self.imageView)
        
        svContentView.addSubview(dottedLineView1)
        svContentView.addSubview(dottedLineView2)
        svContentView.addSubview(self.currentMileageLabel)
        svContentView.addSubview(milesHoursSegmentedControl)
        svContentView.addSubview(hoursMilesLabel)
        svContentView.addSubview(mileageTextField)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        scrollView.delegate = self
        
        svContentView.addSubview(cameraButton)
        
        mileageTextField.inputAccessoryView = toolBar
        mileageTextField.delegate = self
        
        titleBar.addTitleBarAndLabel(page: view, initialTitle: "Add a Bike", ypos: topBarHeight, color:.mainRed())
        
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)

        doneBarButton?.isEnabled = false
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = cancelBarButton
        doneBarButton?.tintColor = .mainRed();
        cancelBarButton?.tintColor = .mainRed()
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
         svContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height*1.25)
        stackView?.anchor(top: svContentView.topAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 35, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)

        self.selectLabel.anchor(top: stackView?.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight:20, width: 0, height: 0)
        self.selectLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        self.pickerView.anchor(top: selectLabel.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: view.frame.width-40, height: 120)
        //self.middleDividerView.anchor(top: pickerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0.5)
        //
        self.dottedLineView1.anchor(top: pickerView.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)
        
        self.milesHoursSegmentedControl.anchor(top: dottedLineView1.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        self.currentMileageLabel.anchor(top: milesHoursSegmentedControl.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: nil, paddingTop:15, paddingLeft: 15, paddingBottom: 0, paddingRight: 10, width: 0, height: 30)
        
        self.mileageTextField.anchor(top: milesHoursSegmentedControl.bottomAnchor, left: currentMileageLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 160, height: 25 )
        
        self.dottedLineView2.anchor(top: mileageTextField.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)
        
        self.thumbnailLabel.anchor(top: dottedLineView2.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.thumbnailLabel.centerXAnchor.constraint(equalTo: svContentView.centerXAnchor).isActive = true

        self.cameraButton.anchor(top: thumbnailLabel.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.cameraButton.centerXAnchor.constraint(equalTo: svContentView.centerXAnchor).isActive = true
        imageView.anchor(top: self.cameraButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: view.frame.width/3, height: view.frame.width/3)
        
        self.cameraButton.centerXAnchor.constraint(equalTo: svContentView.centerXAnchor).isActive = true
        
        let imageWidth = (view.frame.width)/3
        imageView.layer.cornerRadius = (imageWidth)/2
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = borderColor.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.centerXAnchor.constraint(equalTo: svContentView.centerXAnchor).isActive = true
        
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        
        nameTextField.returnKeyType = .done
        self.nameTextField.delegate = self
        self.nameTextField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEnd)
        self.nameTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidBegin)
        self.mileageTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidBegin)
        
        checkStatus()
       // initializeView()
        //checkConnection()
        //self.getMakes()
        //fetchUser()
        //listenForBackgroundNotification()
        
    }
    

    @objc func doneClicked(){
        self.currentMileage = mileageTextField.text!
        self.currentHours = mileageTextField.text!
        
        if bikeToEdit != nil {
            if valueType == "Miles" || valueType == "" {
                bikeToEdit?.currentMileageString = mileageTextField.text!
                self.currentMileage = mileageTextField.text!
            } else if valueType == "Hours" {
                bikeToEdit?.currentHoursString = mileageTextField.text!
            } else if valueType == "Km" {
                bikeToEdit?.currentMileageString = mileageTextField.text!
            }
            
            bikeToEdit?.selectedValue = valueType
           
            saveBikes()
            view.endEditing(true)
        }
        else {
            view.endEditing(true)
        }
    }
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        
        if activeTextField == nameTextField {
            return
        } else {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        var kbHeight = (keyboardFrame.height - 60) * (show ? 1 : -1)
        
        if !show {
            let returnHeight = -64
            kbHeight = CGFloat(returnHeight)
        }
        
        let point:CGPoint = CGPoint(x: 0.0, y: kbHeight)
        scrollView.setContentOffset(point, animated: true)
        }
        
    }
    
    
    func drawDottedLines() {
        //layer dashed line
        let layer1 = dottedLineView1.layer
        let layer2 = dottedLineView2.layer
        
        let lineDashPatterns: [[NSNumber]?]  = [[3,5]]
        for (index, lineDashPattern) in lineDashPatterns.enumerated() {
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = UIColor.veryLightGray().cgColor
            shapeLayer.lineWidth = 0.5
            shapeLayer.lineDashPattern = lineDashPattern
            
            let path = CGMutablePath()
            let y = CGFloat(index * 50)
            path.addLines(between: [CGPoint(x: 0, y: y), CGPoint(x: 640, y: y)])
            
            let shapeLayer2 = CAShapeLayer()
            shapeLayer2.strokeColor = UIColor.veryLightGray().cgColor
            shapeLayer2.lineWidth = 0.5
            shapeLayer2.lineDashPattern = lineDashPattern
            
            let path2 = CGMutablePath()
            let y2 = CGFloat(index * 50)
            path2.addLines(between: [CGPoint(x: 0, y: y2), CGPoint(x: 640, y: y2)])
            shapeLayer.path = path
            shapeLayer2.path = path2
            layer1.addSublayer(shapeLayer)
            layer2.addSublayer(shapeLayer2)
        }
    }
    
    @objc func toggleMilesHours(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
        case 1:
            self.valueType = "Miles"
            mileageTextField.attributedPlaceholder = NSAttributedString(string: "Enter Current \(self.valueType)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.veryLightGray()])
            currentMileageLabel.text = "current mileage:".uppercased()
            if bikeToEdit != nil {
                if bikeToEdit.currentMileageString == nil {
                    mileageTextField.text = "0"
                } else {
                    mileageTextField.text = bikeToEdit.currentMileageString
                    bikeToEdit.selectedValue = valueType
                }
            }
            
        case 2:
            self.valueType = "Km"
            mileageTextField.attributedPlaceholder = NSAttributedString(string: "Enter Current \(self.valueType)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.veryLightGray()])
            currentMileageLabel.text = "current Km:".uppercased()
            if bikeToEdit != nil {
                if bikeToEdit.currentMileageString == nil {
                    mileageTextField.text = "0"
                } else {
                    mileageTextField.text = bikeToEdit.currentMileageString
                    bikeToEdit.selectedValue = valueType
                }
            }
            
        default:
            self.valueType = "Hours"
            mileageTextField.attributedPlaceholder = NSAttributedString(string:  "Enter Current \(self.valueType)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.veryLightGray()])
            currentMileageLabel.text = "current hours:".uppercased()
            if bikeToEdit != nil {
                if bikeToEdit.currentHoursString == nil {
                    mileageTextField.text = "0"
                } else {
                    mileageTextField.text = bikeToEdit.currentHoursString
                    bikeToEdit.selectedValue = valueType
                }
            }
        }
    }
    
    func initializeView() {
        
        if bikeToEdit == nil {
            milesHoursSegmentedControl.selectedSegmentIndex = 1
        }
        
        if let bike = bikeToEdit {
            self.titleBar.updateTitle(newTitle: "Edit a Bike")
            self.nameTextField.text = bike.name
            makeName = bike.make!
            modelName = bike.model!
            bikeYear = bike.year!
            
            if bike.selectedValue == "Miles" || bike.selectedValue == nil {
                milesHoursSegmentedControl.selectedSegmentIndex = 1
            } else if bike.selectedValue == "Hours" {
                milesHoursSegmentedControl.selectedSegmentIndex = 0
            }
            else if bike.selectedValue == "Km" {
                milesHoursSegmentedControl.selectedSegmentIndex = 2
            }
            
            print("????????? \(bike.selectedValue)")
            
            currentMileage = bike.currentMileageString
            currentHours = bike.currentHoursString
            
            if bike.selectedValue == "Miles" {
                self.valueType = "Miles"
                self.mileageTextField.text = bike.currentMileageString
            } else if bike.selectedValue == "Hours" {
                self.valueType = "Hours"
                self.mileageTextField.text = bike.currentHoursString
            } else if bike.selectedValue == "Km" {
                self.valueType = "Km"
                self.mileageTextField.text = bike.currentMileageString
            }
            
            getModelsForMake(mk: makeName)
            //getYearForModel(mk: makeName, mdl: modelName)
            pickerDataSource = [self.makeArray ,self.modelArray ,self.yearArray]
            doneBarButton?.isEnabled = true
            cameraButton.tintColor = UIColor.mainRed()
            cameraButton.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
//            guard let imageName = bike.imageName else {return}
            
            
            print("bike image name is \(bike.imageName)")
            if bike.imageName != nil {
                let imageName = bike.imageName
                showThumb(imageName: imageName! , bike:bike)
            } else {
                showThumb(imageName: "bikeThumbNail", bike: bike)
            }
            
        } else {
            // textField.becomeFirstResponder()
           
            self.titleBar.updateTitle(newTitle: "Add a Bike")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //nameTextField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = textField
        print("\(self.activeTextField) is the active text field")
    }
    
    @objc func didChangeText(textField:UITextField) {
        guard let txt = self.nameTextField.text else {return}
        let newText = txt as NSString
        doneBarButton?.isEnabled = ((newText.length) > 0)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label = view as! UILabel?
            if label == nil {
                label = UILabel()
            }
        
        let data = ("  \(pickerDataSource[component][row])")
        let title = NSAttributedString(string: data , attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12) ?? ""])
        

        label?.attributedText = title
        label?.textAlignment = .left
        
        switch (component) {
        case 0:
             label?.textAlignment = .left
            return  label!
        case 1:
             label?.textAlignment = .left
            return  label!
        case 2:
            label?.textAlignment = .right
            return  label!
        default:
            return label!
        }
        return label!
    }
   
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let w =  CGFloat(pickerView.frame.width)
        let seg = w/8
        switch (component){
        case 0:
            return  (seg * 2.25);
        case 1:
            return  (seg * 3.5);
        case 2:
            return  (seg * 2);
        default:
            return 0;
        }
        return 0;
    }

     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        //post()
        if(component == 0)
        {
            self.modelName = "No Model Selected"
            self.bikeYear = "No Year Selected"
            self.modelArray = [" "]
            self.yearArray = [" "]
            pickerDataSource = [self.makeArray, self.modelArray, self.yearArray]
            pickerView.selectRow(0, inComponent:1, animated: true)
            makeName = pickerDataSource[0][row] as! String
           
            self.getModelsForMake(mk: makeName)
            pickerView.reloadComponent(1)
            pickerView.reloadComponent(2)
        
            }
        else if(component == 1)
        {
            self.bikeYear = "No Year Selected"
            pickerView.selectRow(0, inComponent: 2, animated: true)

            modelName = pickerDataSource[1][row] as! String
            pickerView.reloadComponent(2)
            self.getYearForModel(mk: makeName, mdl:modelName)
            self.yearArray = [" "]
        }
            
        else if(component == 2)
        {
            bikeYear = pickerDataSource[2][row] as! String
            print("\(bikeYear)")
        }
    }
    
    func getYearForModel(mk: String, mdl:String) {
        if isConnected == true {
            ref?.child("bikes").child(mk).child(mdl).queryOrderedByKey().observe(.value, with: { (snapshot) in

                // ref?.child("bikes").child(mk).child(mdl).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? NSDictionary else {return}
                //print(dictionary)
                let sortedKeys = (dictionary.allKeys as! [String]).sorted(by: <)
                self.yearArray = sortedKeys

                self.pickerDataSource = [self.makeArray, self.modelArray, self.yearArray]
                self.pickerView.reloadComponent(2)
                if self.bikeYear == "No Year Selected" {
                    self.bikeYear = self.yearArray[0]
                    self.pickerView.selectRow(self.yearArray.firstIndex(of:self.bikeYear)!, inComponent: 2, animated: true)
                } else {

                    self.pickerView.selectRow(self.yearArray.firstIndex(of:self.bikeYear)!, inComponent: 2, animated: true)
                }
                self.makeModelYearCache?.write(object: self.yearArray as NSCoding, forKey: "years")
            }, withCancel: nil)
        } else {
            print("we have no connection, now we need to parse the json object for the year")
            self.yearArray = self.makeModelYearCache?.readObject(forKey: "years") as! [String]
            self.pickerDataSource = [self.makeArray, self.modelArray, self.yearArray]
            self.pickerView.reloadComponent(2)
            self.bikeYear = self.yearArray[0]
            if (self.bikeYear != self.yearArray[0]) {
                self.pickerView.selectRow(self.yearArray.firstIndex(of:self.bikeYear)!, inComponent: 2, animated: true)
            }
        }
    }

//
//    func getYearForModel(mk: String, mdl:String) {
//        if isConnected == true {
//
//        ref?.child("bikes").child(mk).child(mdl).queryOrderedByKey().observeSingleEvent(of: .value, with: {
//            (snapshot) in
//            guard let dictionary = snapshot.value as? NSDictionary else {return}
//            //print(dictionary)
//            let sortedKeys = (dictionary.allKeys as! [String]).sorted(by: <)
//            self.yearArray = sortedKeys
//
//            self.pickerDataSource = [self.makeArray, self.modelArray, self.yearArray]
//            self.pickerView.reloadComponent(2)
//            if self.bikeYear == "No Year Selected" {
//            self.bikeYear = self.yearArray[0]
//            self.pickerView.selectRow(self.yearArray.index(of:self.bikeYear)!, inComponent: 2, animated: true)
//            } else {
//
//                self.pickerView.selectRow(self.yearArray.index(of:self.bikeYear)!, inComponent: 2, animated: true)
//            }
//             self.makeModelYearCache?.write(object: self.yearArray as NSCoding, forKey: "years")
//        })
//        } else {
//            print("we have no connection, now we need to parse the json object for the year")
//            self.yearArray = self.makeModelYearCache?.readObject(forKey: "years") as! [String]
//            self.pickerDataSource = [self.makeArray, self.modelArray, self.yearArray]
//            self.pickerView.reloadComponent(2)
//            self.bikeYear = self.yearArray[0]
//            if (self.bikeYear != self.yearArray[0]) {
//                self.pickerView.selectRow(self.yearArray.index(of:self.bikeYear)!, inComponent: 2, animated: true)
//            }
//        }
//    }

    func getModelsForMake(mk:String) {
        if isConnected == true {
       // ref?.child("bikes").child(mk).queryOrderedByKey().observeSingleEvent(of: .value, with: {
           ref?.child("bikes").child(mk).queryOrderedByKey().observe(.value, with: { (snapshot) in
           // (snapshot) in
            guard let dictionary = snapshot.value as? NSDictionary else {return}
            //print(dictionary)
            let sortedKeys = (dictionary.allKeys as! [String]).sorted(by: <)
            self.modelArray = sortedKeys
            
            self.pickerDataSource = [self.makeArray, self.modelArray, self.yearArray]
            self.pickerView.reloadComponent(1)
            if self.modelName == "No Model Selected" {
            self.modelName = self.modelArray[0]
            self.pickerView.selectRow(self.modelArray.firstIndex(of:self.modelName)!, inComponent: 1, animated: true)
            } else {
                self.pickerView.selectRow(self.modelArray.firstIndex(of:self.modelName)!, inComponent: 1, animated: true)
            }
            self.makeModelYearCache?.write(object: self.modelArray as NSCoding, forKey: "models")
            self.getYearForModel(mk: self.makeName, mdl: self.modelName)
           }, withCancel: nil)
        } else {
            print("we have no connection, now we need to parse the json for the models")
            self.modelArray = self.makeModelYearCache?.readObject(forKey: "models") as! [String]
            self.pickerDataSource = [self.makeArray, self.modelArray, self.yearArray]
            self.pickerView.reloadComponent(1)
             self.modelName = self.modelArray[0]
            if (self.modelName !=  self.makeArray[0]) {
                self.pickerView.selectRow(self.modelArray.firstIndex(of:self.modelName)!, inComponent: 1, animated: true)
            }
        }
    }
    

    func getMakes() {
        if isConnected == true {
            self.makeArray = [" "]
            self.modelArray = [" "]
            self.yearArray = [" "]
            ref = Database.database().reference()
           // ref?.child("make").queryOrderedByKey().observeSingleEvent(of: .value, with: {
           ref?.child("make").queryOrderedByKey().observe(.value, with: { (snapshot) in
           // (snapshot) in
                
           guard let mk = snapshot.value as? NSArray else {return}
           for i in 0..<mk.count {
                self.makeArray.append((mk[i] as AnyObject).value(forKey:"make") as! String)
            }
            
                self.makeArray.sort { $0 < $1 }
            
            self.makeModelYearCache?.write(object: mk as NSCoding, forKey: "makes")
            self.pickerDataSource = [self.makeArray, self.modelArray, self.yearArray]
            self.pickerView.reloadAllComponents()
            if (self.bikeToEdit != nil) {
                if (self.makeName == "No Make Selected" || self.makeName == " " ){
                    return
                }
                self.pickerView.selectRow(self.makeArray.firstIndex(of:self.makeName)!, inComponent: 0, animated: true)
            }
        }, withCancel: nil)
        } else {
            print("we have no connection, now we need to parse the json for the makes")
            self.makeArray = [" "]
            let cachedData = makeModelYearCache?.readObject(forKey: "makes") as? NSArray
            print(cachedData as Any)
            guard let mk = cachedData else {return}
                for i in 0..<mk.count {
                    self.makeArray.append((mk[i] as AnyObject).value(forKey:"make") as! String)
                }
                self.pickerDataSource = [self.makeArray, self.modelArray, self.yearArray]
                self.pickerView.reloadAllComponents()
                if (self.bikeToEdit != nil) {
                    print("bike to edit is not nil")
                   print(self.makeName)
                    if (self.makeName == "No Make Selected" || self.makeName == " " ){
                        return
                    }
                    self.pickerView.selectRow(self.makeArray.firstIndex(of:self.makeName)!, inComponent: 0, animated: true)
                }
        }
    }
    
    func checkStatus() {
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            self.createAlbum()
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            //may have to make an alert here to let folks know about the photos
        }
            
        else if (status == PHAuthorizationStatus.notDetermined) {
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.createAlbum()
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
    
    @objc func cancel() {
        delegate?.bikeDetailViewControllerDidCancel(self)
    }
    
    func checkMyConnection() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                self.isConnected = true
                self.uid = Auth.auth().currentUser?.uid
                self.getMakes()
                self.initializeView()
            } else {
                self.isConnected = false
                guard let userCache = self.userCache else {return}
                self.uid = userCache.readObject(forKey: "uid") as? String
                self.getMakes()
                self.initializeView()
            }
        })
    }
    
    @objc func done() {
        if let bike = bikeToEdit {
            guard bike.uniqueID != nil else {
                return
            }
           
            bike.name = self.nameTextField.text!
            bike.make = makeName
            bike.model = modelName
            bike.year = bikeYear
            
            if bike.selectedValue == "Miles"  {
                if mileageTextField.text != "" {
                    bike.currentMileageString = mileageTextField.text!
                } else {
                    bike.currentMileageString = "0"
                }
            } else if bike.selectedValue == "Hours" {
                if mileageTextField.text != "" {
                    bike.currentHoursString = self.mileageTextField.text!
                } else {
                    bike.currentMileageString = "0"
                }
            } else if bike.selectedValue == "Km" {
                    if mileageTextField.text != "" {
                         bike.currentMileageString = mileageTextField.text!
                    } else {
                        bike.currentMileageString = "0"
                    }
            }
            
            if self.selectedImageFromPicker != nil {
                bike.imageName = tempImageName
            }
            showThumb(imageName: "bikeThumbNail", bike: bike)
           
            saveBikes()
            delegate?.bikeDetailViewController(self, didFinishEditing: bike)
            
        } else {
            let timestamp:NSNumber = NSDate().timeIntervalSince1970 as NSNumber
            
            let bikeID = NSUUID().uuidString
            let bike = FB_Bike(name: nameTextField.text!, uniqueID: bikeID, make: makeName, model: modelName, year: bikeYear, imageUrl: nil, thumbUrl: nil, timestamp: timestamp, maintenance: [], projects: [], imageName: nil, thumbName: nil, currentMileageString:"0", currentHoursString:"0", selectedValue:"Miles")
            
            if self.selectedImageFromPicker != nil {
                bike?.imageName = tempImageName
            }
            
            bike?.selectedValue = self.valueType
            
            if bike?.selectedValue == "Miles"  {
                if mileageTextField.text != "" {
                    bike?.currentMileageString = mileageTextField.text!
                } else {
                    bike?.currentMileageString = "0"
                }
            } else if bike?.selectedValue == "Hours" {
                if mileageTextField.text != "" {
                    bike?.currentHoursString = self.mileageTextField.text!
                } else {
                    bike?.currentMileageString = "0"
                }
            }
            else if bike?.selectedValue == "Km" {
                if mileageTextField.text != "" {
                    bike?.currentMileageString = mileageTextField.text!
                } else {
                    bike?.currentMileageString = "0"
                }
            }
            
            self.bikeToEdit = bike
            guard let b = bike else {return}
            bikes?.append(b)
            saveBikes()
            delegate?.bikeDetailViewController(self, didFinishAdding: b)
        }
    }
    
    private func saveBikes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes as Any, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("successfully saved")
            print("\(BikeData.sharedInstance.allBikes.count) the bikes count from SAVE BIKES Bikes EDIT")
        } else {
            print("un-successfully saved")
        }
    }
    
    //MARK: - Notification
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil, queue: OperationQueue.main) {
        [weak self] _ in
                
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                        strongSelf.dismiss(animated: false, completion: nil)
                    }
                    strongSelf.nameTextField.resignFirstResponder()
                }
        }
    }
    deinit {
       NotificationCenter.default.removeObserver(observer)
    }
}

extension BikeDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func pickPhoto() {
        //checkStatus()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
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
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.navigationBar.tintColor = UIColor.mainRed()
            present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.navigationBar.tintColor = UIColor.mainRed()
            present(imagePicker, animated: true, completion: nil)
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        if let theImage = selectedImageFromPicker {
            
        let _:NSData = theImage.jpegData(compressionQuality: 1) as! NSData
         // showImage(image: theImage)
        saveImageToAlbum(image: theImage, view: self.view)
            //showImage(image: theImage)
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
            self.tempImageName = imageIdentifier
            DispatchQueue.main.async {
                self.showImage(image: image)
            }
           //self.showImage(image: image)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func createAlbum() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", appAlbumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if (collection.firstObject != nil) {
            self.albumFound = true
            self.assetCollection = collection.firstObject!
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                self.request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.appAlbumName)
            }, completionHandler: { success, error in
                self.albumFound = (success ? true:false)
                if (success) {
                    print("bike album \(self.appAlbumName) has been created")
                } else {
                    print("Error creating folder for bike album")
                }
            })
        }
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
