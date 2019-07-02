//
//  MaintenaceDetailViewController.swift
//  mp
//
//  Created by DQ on 1/11/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import Foundation

import UIKit
import UserNotifications
import FirebaseStorage
//import Firebase
import FirebaseDatabase

protocol MaintenanceDetailViewControllerDelegate: class {
    func maintenanceDetailViewControllerDidCancel(_ controller: MaintenanceDetailViewController)
    func maintenanceDetailViewController(_ controller:MaintenanceDetailViewController, didFinishAdding item: FB_MaintenanceItem)
    func maintenanceDetailViewController(_ controller: MaintenanceDetailViewController, didFinishEditing item: FB_MaintenanceItem)
}

class MaintenanceDetailViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIScrollViewDelegate {
    
    var doneBarButton: UIBarButtonItem?
    var cancelBarButton: UIBarButtonItem?
    var bike:FB_Bike!
    var bikes:[FB_Bike]!
    var selectedIndexPath:IndexPath!
    var maintenanceIndexPath:IndexPath?
    var stackView:UIStackView?
    var pickerView:UIPickerView =  UIPickerView()
    var numberPicker: UIPickerView = UIPickerView()
    var valueType:String = ""
    var titleBar:TitleBar = TitleBar()
    var currentMileage:String?
    var currentHours:String?
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
    
    let topDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .veryLightGray()
        return view
    }()
    
    let middleDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let bottomDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()

    let nameTextField:UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = UIFont(name: "Avenir", size: 14)
        tf.textColor = UIColor.darkGray
        tf.borderStyle = .roundedRect
        tf.layer.masksToBounds = true
        tf.text = ""
        tf.keyboardAppearance = .dark
        tf.attributedPlaceholder = NSAttributedString(string: "Name your Maintenance Task", attributes: [NSAttributedString.Key.foregroundColor: UIColor.veryLightGray()])
        return tf
    }()
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.text = "Name your maintenance task"
        return label
    }()
    
    let categoryLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.text = "Select Maintenance Type".uppercased()
        return label
    }()
    
    let selectedCategoryLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let setReminderLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let currentMileageLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Medium", size: 12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "current mileage".uppercased()
        return label
    }()
    
    let actualMileageLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Bold", size: 14)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    let remindLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size:11)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "set reminder".uppercased()
        return label
    }()
    
    let dueDateLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 14)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Due date".uppercased()
        return label
    }()
    
    let notesTextView:UITextView = {
        let tf = UITextView()
        tf.textAlignment = .left
        tf.font = UIFont(name: "Avenir", size: 14)
        tf.textColor = UIColor.lightGray
        let borderColor : UIColor = .veryLightGray()
        tf.layer.borderColor = borderColor.cgColor
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 0.5
        tf.keyboardAppearance = .dark
        tf.text = ""
        return tf
    }()
    
    let shouldRemindSwitch: UISwitch = {
       let s = UISwitch()
        s.isOn = false
        s.tintColor = .mainRed()
        s.onTintColor = .mainRed()
        s.addTarget(self, action: #selector(shouldRemindToggled), for: .valueChanged)
        return s
    }()
    
    let toolBar:UIToolbar = {
        let t = UIToolbar()
        t.backgroundColor = .veryLightGray()
        return t
    }()
    
    var taskToEdit: FB_MaintenanceItem?
    var delegate: MaintenanceDetailViewControllerDelegate?
    var selectedCategory: String = "Misc."
    var selectedNumber: String = "100"
    var selectedInt = 0
    var selectedNumInt = 0
    var observer: Any!
    
    var topBarHeight:CGFloat = 0
    var numValues = [String]()
    
    var categories = ["Misc.", "Battery & Electrics", "Brakes & Suspension", "Cables & Controls", "Chain & Sprockets", "Cleaning", "Filters & Fluids", "Fuel & Air", "Oil & Spark Plugs", "Wheels & Tires"]
    
    @objc func cancel() {
        delegate?.maintenanceDetailViewControllerDidCancel(self)
    }
    
    let scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    var svContentView:UIView = {
        let v = UIView()
        return v
    }()
    
    let dottedLineView1 = UIView()
    let dottedLineView2 = UIView()

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneBarButton?.isEnabled = false
        print("this is hit")
        if textView.text.isEmpty || textView.text == "Notes:" {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let txt = self.nameTextField.text {
            print("this is hit too, when done")
            let newText = txt as NSString
            doneBarButton?.isEnabled = ((newText.length) > 0)
        }
    }
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        var kbHeight = ((keyboardFrame.height) - 120) * (show ? 1 : -1)
        
        if !show {
            let returnHeight = 0
            kbHeight = CGFloat(returnHeight)
        }
        let point:CGPoint = CGPoint(x: 0.0, y: kbHeight)
        scrollView.setContentOffset(point, animated: true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    @objc func doneClicked(){
         self.notesTextView.scrollRangeToVisible(NSMakeRange(0, 0))
            notesTextView.endEditing(true)
            view.endEditing(true)
        if notesTextView.text.isEmpty {
            notesTextView.text = "Notes:"
            notesTextView.textColor = UIColor.lightGray
        } else {
            notesTextView.textColor = .black
        }
    }
    
    func setNumValues() {
        numValues = []
        if valueType == "Miles"  || valueType == "Km" {
            for m in 1 ... 60 {
                numValues.append(String(m * 100) )
            }
        }
        else {
            for h in 1 ... 50 {
                numValues.append(String(h) )
            }
        }
        
        numberPicker.reloadComponent(0)
    }
    
     override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        //for segemented control
        if bike.selectedValue != nil {
            self.valueType = bike.selectedValue!
        }
        
        self.currentMileageLabel.text = ("Current \(self.valueType)").uppercased()
        
        if bike.selectedValue == "Miles" || bike.selectedValue == nil {
            if bike.currentMileageString != nil {
             actualMileageLabel.text = bike.currentMileageString!
            } else {
                actualMileageLabel.text = "0"
            }
            setNumValues()
        } else if  bike.selectedValue == "Km" {
            if bike.currentMileageString != nil {
               actualMileageLabel.text = bike.currentMileageString!
            } else {
                actualMileageLabel.text = "0"
            }
            setNumValues()
        } else if  bike.selectedValue == "Hours" {
            if bike.currentHoursString != nil {
            actualMileageLabel.text = bike.currentHoursString!
            } else {
                actualMileageLabel.text = "0"
            }
            setNumValues()
        }

        drawDottedLines()
        
        //initialize this here
        notesTextView.text = "Notes:"
        notesTextView.textColor = UIColor.lightGray
        
        notesTextView.target(forAction: #selector(textViewDidBeginEditing(_:)), withSender: nil)
        notesTextView.target(forAction: #selector(textViewDidEndEditing(_:)), withSender: nil)
        
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
        
        let toolBar = UIToolbar()
        let barDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        barDoneButton.tintColor = .mainRed()
        toolBar.setItems([flexibleSpace, barDoneButton], animated: true)
        toolBar.sizeToFit()
        notesTextView.inputAccessoryView = toolBar
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.addSubview(svContentView)
        svContentView.backgroundColor = .white
        svContentView.addSubview(self.nameTextField)
        svContentView.addSubview(self.categoryLabel)
        svContentView.addSubview(self.notesTextView)
        svContentView.addSubview(topDividerView)
        svContentView.addSubview(setReminderLabel)
        svContentView.addSubview(dottedLineView1)
        svContentView.addSubview(dottedLineView2)
        svContentView.addSubview(self.currentMileageLabel)
        svContentView.addSubview(self.actualMileageLabel)
        svContentView.addSubview(hoursMilesLabel)
        
        svContentView.addSubview(self.selectedCategoryLabel)
        
         topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
       
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop:topBarHeight + 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width:0, height:view.frame.height * 1.25)
        
        view.backgroundColor = .white
        scrollView.addSubview(pickerView)
        scrollView.addSubview(numberPicker)

        scrollView.addSubview(shouldRemindSwitch)
        scrollView.addSubview(remindLabel)
        pickerView.dataSource = self
        numberPicker.dataSource = self
        pickerView.delegate = self
        numberPicker.delegate = self
        
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)

        titleBar.addTitleBarAndLabel(page: view, initialTitle:"Add a Maintenance Item", ypos: topBarHeight, color:.mainRed())
        
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        doneBarButton?.isEnabled = false
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)
        
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)

        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = cancelBarButton
        doneBarButton?.tintColor = .mainRed();
        cancelBarButton?.tintColor = .mainRed()
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        
        numberPicker.backgroundColor = UIColor.mainRed()
        numberPicker.setValue(UIColor.white, forKeyPath: "textColor")
        numberPicker.setValue(1.0, forKeyPath: "alpha")
        
//        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop:90, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width:0, height:0)
        
        svContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height + 120)
        
        self.nameTextField.anchor(top: svContentView.topAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
        
        self.categoryLabel.anchor(top: nameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        pickerView.anchor(top: categoryLabel.topAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 80)
        
          self.notesTextView.anchor(top: pickerView.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
        self.dottedLineView1.anchor(top: notesTextView.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)
        
        self.currentMileageLabel.anchor(top: dottedLineView1.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: nil, paddingTop:8, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        self.actualMileageLabel.anchor(top: nil, left: currentMileageLabel.rightAnchor, bottom: nil, right: nil, paddingTop:10, paddingLeft:8, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        self.currentMileageLabel.centerYAnchor.constraint(equalTo: actualMileageLabel.centerYAnchor).isActive = true
        
        self.dottedLineView2.anchor(top: currentMileageLabel.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)

        self.remindLabel.anchor(top: dottedLineView2.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
        self.shouldRemindSwitch.anchor(top: dottedLineView2.bottomAnchor, left: nil, bottom: nil, right: svContentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)

        self.setReminderLabel.anchor(top: dottedLineView2.bottomAnchor, left: nil, bottom: nil, right: shouldRemindSwitch.leftAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        self.setReminderLabel.centerYAnchor.constraint(equalTo: shouldRemindSwitch.centerYAnchor).isActive = true
        
        numberPicker.anchor(top: setReminderLabel.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 22, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height:180)
        
        shouldRemindSwitch.addTarget(self, action: #selector(switchChanged(_ :)), for: .valueChanged)
        
        self.notesTextView.returnKeyType = .default
        
        notesTextView.delegate = self
        
        nameTextField.delegate = self
        self.nameTextField.returnKeyType = .done
        self.nameTextField.target(forAction: #selector(textViewShouldEndEditing(_:)), withSender: self)
        self.nameTextField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        
        barDoneButton.tintColor = .mainRed()
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)

        toolBar.setItems([flexibleSpace, barDoneButton], animated: true)
        toolBar.sizeToFit()
        notesTextView.inputAccessoryView = toolBar
        
        numberPicker.isHidden = true
        
        if let item = taskToEdit {
            self.titleBar.updateTitle(newTitle:"Edit Maintenance Item")
            
            if item.notes != "Notes:" || item.notes != "" {
                
                    notesTextView.text = item.notes
                 if notesTextView.text != "Notes:" {
                    notesTextView.textColor = .black
                }
                    
            } else {
                notesTextView.text = "Notes:"
                notesTextView.textColor = UIColor.lightGray
            }
           
        numberPicker.isHidden = true
            
            if item.shouldRemind == true {
                    numberPicker.isHidden = false
             
            } else {
                numberPicker.isHidden = true
                item.reminderNumber = 100
                numberPicker.selectRow(getSelectedNumber(item: item, currentString: String(describing: item.reminderNumber!)), inComponent: 0, animated: true)
            }
            
            pickerView.selectRow(getSelectedCategory(item: item, currentString: item.category!), inComponent: 0, animated: true)
                if item.category != nil {
                    selectedCategory = categories[getSelectedCategory(item: item, currentString: item.category!)]
                }
            
            if item.reminderNumber != nil {
                numberPicker.selectRow(getSelectedNumber(item: item, currentString: String(describing: item.reminderNumber!)), inComponent: 0, animated: true)
            }
            
            if item.reminderNumber != nil {
                    self.selectedNumber = numValues[getSelectedNumber(item: item, currentString: String(describing: item.reminderNumber!))]
                }
                nameTextField.text = item.title
            
            if item.notes != "" {
                    notesTextView.text = item.notes
                }
            
            if bike.selectedValue != nil {
                self.valueType = bike.selectedValue!
            }
            
            currentMileage = bike.currentMileageString
            currentHours = bike.currentHoursString
                        
            if valueType == "Miles" || valueType == "" {
                if bike.currentMileageString != nil {
                    self.currentMileageLabel.text = "CURRENT MILES:"
                    self.actualMileageLabel.text = "\(bike.currentMileageString!)"
                } else {
                    self.currentMileageLabel.text = "CURRENT MILES:"
                    self.actualMileageLabel.text = "0"

                }
            } else if valueType == "Hours" {
                if bike.currentHoursString != nil {
                self.currentMileageLabel.text = "CURRENT HOURS:"
                self.actualMileageLabel.text = "\(bike.currentHoursString!)"
                }else {
                    self.currentMileageLabel.text = "CURRENT HOURS:"
                    self.actualMileageLabel.text = "0"
                }
            } else if valueType == "Km" {
                if bike.currentHoursString != nil {
                    self.currentMileageLabel.text = "CURRENT Km:"
                    self.actualMileageLabel.text = "\(bike.currentMileageString!)"
                }else {
                    self.currentMileageLabel.text = "CURRENT Km:"
                    self.actualMileageLabel.text = "0"
                }
            }
        
            if item.reminderNumber != nil {
                if (item.shouldRemind == true) {
                    shouldRemindSwitch.isOn = true
                   self.updateViewConstraints()
                    if item.reminderNumber != nil {
                        self.selectedNumber = String(describing: item.reminderNumber!)
                        self.setReminderLabel.text = "Set for: \(self.selectedNumber) \(self.valueType)"
                    }
                } else {
                     self.selectedNumber = "100"
                     shouldRemindSwitch.isOn = false
                }
            }
        }
    }
    
    @objc func mileageButtonHandler() {
        let mileageViewController = MileageViewController()
        navigationController?.pushViewController(mileageViewController, animated: true)
        mileageViewController.delegate = self as? MileageViewControllerDelegate
    }
    func textViewDidChange(_ textView: UITextView) {
        guard (self.notesTextView.text) != nil else {return}
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
           // view.endEditing(true)
           // textView.text = textView.text + "\n"
            return true
        } else {
            return true
        }
    }
    
   
    
    @objc func numberChanged(row: Int) {
        self.updateNumberLabel()
    }
    
    func updateNumberLabel() {
//        if (selectedNumber != nil) {
            self.setReminderLabel.text = "Set for: \(self.selectedNumber) \(self.valueType)"
//        }
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
   
    @objc func switchChanged(_ switch: UISwitch) -> Bool {
        setReminderLabel.isHidden = !shouldRemindSwitch.isOn
        if shouldRemindSwitch.isOn {
        var bottomOffset = CGPoint(x:0, y: self.pickerView.frame.height + 80)
        self.scrollView.setContentOffset(bottomOffset, animated: true)
        }else {
            var bottomOffset = CGPoint(x:0, y: 0)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
        return setReminderLabel.isHidden
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func done() {
        
        if let item = taskToEdit {
            let timestamp:NSNumber = NSDate().timeIntervalSince1970 as NSNumber
            item.timestamp = timestamp
            item.shouldRemind = shouldRemindSwitch.isOn
            item.reminderNumber = Int(self.selectedNumber)
            bike.selectedValue = self.valueType
            if shouldRemindSwitch.isOn {
                updateNumberLabel()
                if item.storedMileageRef == nil {
                    item.storedMileageRef = 0
                }
                if item.reminderNumber != nil  {
                    if valueType == "Miles" || valueType == "Km" {
                        if bike.currentMileageString != nil {
                            var num = (Int(bike.currentMileageString!)! as NSNumber)
                            if (item.storedMileageRef == 0){
                                item.storedMileageRef = Int(bike.currentMileageString!)
                            }
                            item.mileageTotal = item.reminderNumber! + item.storedMileageRef!
                        }
                    } else if  valueType == "Hours" {
                        if bike.currentHoursString != nil {
                            if (item.storedMileageRef == 0) {
                                item.storedMileageRef = Int(bike.currentHoursString!)
                            }
                            item.mileageTotal = item.reminderNumber! + item.storedMileageRef!
                        }
                    }
                    
//                    var val = NumberFormatter().number(from: bike.currentMileageString!)!.floatValue * 1.6
//                    var i = Int(val)
//                    item?.storedMileageRef = i
                    item.reminderNumber = Int(selectedNumber)
                }
              
                item.scheduleNotification(vc: self, totalNum:item.mileageTotal!)
                
            } else {
                item.storedMileageRef = 0
                item.mileageTotal = 0
                item.reminderNumber = nil
            }
            
            item.notes = notesTextView.text
            item.category = selectedCategory
            item.title = nameTextField.text
            
            //Update the object here and then save
            bikes[(selectedIndexPath?.row)!].maintenance?[(maintenanceIndexPath?.row)!] = item
            bikes[(selectedIndexPath?.row)!] = bike
            saveBikes()
            delegate?.maintenanceDetailViewController(self, didFinishEditing: item)
            
        } else {
            
            let title = nameTextField.text
            let itemID = NSUUID().uuidString
            let timestamp:NSNumber = NSDate().timeIntervalSince1970 as NSNumber
            
            let item = FB_MaintenanceItem(title: title!, uniqueID: itemID, category: self.selectedCategory, timestamp: timestamp, notes: self.notesTextView.text, shouldRemind: shouldRemindSwitch.isOn, bike: bike, reminderNumber: Int(self.selectedNumber), mileageTotal:0, storedMileageRef:0, completedAtString: nil)
           //set this to zero first in case they don't set a reminder
            item?.storedMileageRef = 0
            
            if shouldRemindSwitch.isOn {
                self.updateNumberLabel()
                    item?.shouldRemind = shouldRemindSwitch.isOn
                if item?.shouldRemind == true {
                    item?.mileageTotal = 0
                }
                    item?.reminderNumber = Int(selectedNumber)
                if item?.reminderNumber != nil  {
                    if valueType == "Miles" || valueType == ""  || valueType == "Km"{
                            valueType = "Miles"
                        let num = Int(bike.currentMileageString!)
                                item?.storedMileageRef = num
                                item?.mileageTotal = (item?.reminderNumber!)! + num!
                    } else if  valueType == "Hours" {
                        let num = Int(bike.currentHoursString!)
                                item?.storedMileageRef = num
                                item?.mileageTotal = (item?.reminderNumber!)! + num!
                        }
                    }
                
                item?.scheduleNotification(vc:self, totalNum:(item?.mileageTotal)!)
            } else {
                item?.storedMileageRef = 0
                item?.mileageTotal = 0
            }
            
            //Save here
            bikes = []
            let savedBikes = loadUserBikes()
            bikes = savedBikes
            bike.maintenance?.append(item!)
            bike.selectedValue = self.valueType
            bikes?[(selectedIndexPath?.row)!] = bike
            saveBikes()
           
            delegate?.maintenanceDetailViewController(self, didFinishAdding: item!)
        }
    }
    
    @objc func didChangeText(textField:UITextField) {
        guard let txt = self.nameTextField.text else {return}
        let newText = txt as NSString
        doneBarButton?.isEnabled = ((newText.length) > 0)
    }

    private func loadUserBikes() -> [FB_Bike]?  {
        //self.checkCoachMark()
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }
    
    private func saveBikes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("successfully saved")
            BikeData.sharedInstance.allBikes = bikes
        } else {
            print("un-successfully saved")
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func shouldRemindToggled(_ switchControl: UISwitch) {
    if switchControl.isOn == false {
        setReminderLabel.isHidden = true
        numberPicker.isHidden = true
    }
        if switchControl.isOn {
            setReminderLabel.isHidden = false
            numberPicker.isHidden = false
        }
    }
    
      func getSelectedCategory(item: FB_MaintenanceItem, currentString:String) -> Int {
        for i in 0..<categories.count {
            if item.category == categories[i] {
                return i
            }
        }
        return 0
    }
    
    func getSelectedNumber(item: FB_MaintenanceItem, currentString:String) -> Int {
        if item.reminderNumber != nil {
        for i in 0..<numValues.count {
            if String(describing: item.reminderNumber!) == numValues[i] {
                return i
                }
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case numberPicker:
                return self.numValues[row]
            default:
                return categories[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel?
            if label == nil {
                label = UILabel()
            }
            var data:String = ""
            switch pickerView {
            case numberPicker:
                data = numValues[row]
                label?.textColor = .white
            default:
                data = categories[row]
            }
            let title = NSAttributedString(string: data, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 16)!])
            label?.attributedText = title
            label?.textAlignment = .center
            return label!
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView {
            case numberPicker :
                selectedNumber = numValues[row]
                selectedNumInt = row
                numberChanged(row: row)
                let newText = nameLabel.text! as NSString
             doneBarButton?.isEnabled = ((newText.length) > 0)
            default :
                selectedCategory = categories[row]
                selectedInt = row
                let newText = nameLabel.text! as NSString
                doneBarButton?.isEnabled = ((newText.length) > 0)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
            case numberPicker :
                return numValues.count
            default :
                return categories.count
        }
    }
    
    func getEntryDateLabel(date:NSDate) ->String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date as Date)
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
                   // strongSelf.notesTextView.resignFirstResponder()
                }
            }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

 //
    
}


    

