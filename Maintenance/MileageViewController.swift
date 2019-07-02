//
//  MileageViewController.swift
//  MotoPreserve-App
//
//  Created by DANIEL I QUINTERO on 12/27/17.
//  Copyright © 2017 DANIEL I QUINTERO. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import UserNotifications

protocol MileageViewControllerDelegate: class {
    func mileageViewControllerDidCancel(_ controller: MileageViewController)
    //func mileageViewController(_ controller:MileageViewController, didFinishAdding item: FB_TaskItem)
    func mileageViewControllerDidFinishEditing(_ controller: MileageViewController)
}

class MileageViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var bike:FB_Bike!
//    var taskToEdit: FB_MaintenanceItem?
    var selectedIndexPath:IndexPath!
    var maintenanceIndexPath:IndexPath?
    var observer: Any!
    
    var valueType:String = "Miles"
    var currentMileage:String?
    var currentHours:String?
    
    var dueDate:NSNumber?
    var stackView:UIStackView?
    var stackViewDate:UIStackView?
    var reminderDate:NSNumber?
    
    var buttonRow:Int?
    
    let dottedLineView1 = UIView()
    let dottedLineView2 = UIView()
    
    var bikes:[FB_Bike] = BikeData.sharedInstance.allBikes
    
    weak var delegate: MileageViewControllerDelegate?
    
    let scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    var svContentView:UIView = {
        let v = UIView()
        return v
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
        sc.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!], for: UIControl.State.focused)
        sc.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!], for: UIControl.State.disabled)

        return sc
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
    
    let mileageTextView:UITextView = {
        let tv = UITextView()
        tv.textAlignment = .left
        tv.font = UIFont(name: "Avenir", size:16)
        tv.textColor = UIColor.black
        tv.isSelectable = false
        tv.isEditable = false
        tv.text = "Entering the current mileage for this bike allows you to set and schedule reminders for upcoming maintenance like oil changes, tune-ups, chain lubrication and general care."
        return tv
    }()
    //
    let enterMileageLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.text = "ENTER CURRENT MILEAGE:"
        return label
    }()
    
    let currentMileageLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.text = "current mileage".uppercased()
        return label
    }()
    
    let remindLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size:12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "set a reminder".uppercased()
        return label
    }()
    
    let dueDateLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Due date".uppercased()
        return label
    }()
    
    let shouldRemindSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = false
        s.tintColor = .mainRed()
        s.onTintColor = .mainRed()
        return s
    }()
    
    let toolBar:UIToolbar = {
        let t = UIToolbar()
        t.backgroundColor = .veryLightGray()
        return t
    }()
    
    var titleBar:TitleBar = TitleBar()
    
    var doneBarButton: UIBarButtonItem?
    var cancelBarButton: UIBarButtonItem?
    var selectedCategory: String = "Misc."
    var selectedNumber: String = "500"
    var selectedInt = 0
    var selectedNumInt = 0
    
    var numValues = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
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
        
        self.valueType = bike.selectedValue!
        currentMileageLabel.text = ("current \(self.valueType)").uppercased()
        
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        if bike.selectedValue == "Miles" {
             self.valueType = "Miles"
            milesHoursSegmentedControl.selectedSegmentIndex = 1
            self.mileageTextField.text = bike.currentMileageString
        } else if bike.selectedValue == "Hours" {
             self.valueType = "Hours"
            milesHoursSegmentedControl.selectedSegmentIndex = 0
            self.mileageTextField.text = bike.currentHoursString
        } else if bike.selectedValue == "Km"{
            milesHoursSegmentedControl.selectedSegmentIndex = 2
            self.valueType = "Km"
            self.mileageTextField.text = bike.currentMileageString
        }

        if bike.selectedValue == "Miles" && bike.currentMileageString != nil {
            self.mileageTextField.text = bike.currentMileageString
        } else if bike.selectedValue == "Hours" && bike.currentHoursString != nil{
            self.mileageTextField.text = bike.currentHoursString
        } else if bike.selectedValue == "Km" && bike.currentMileageString != nil {
            self.mileageTextField.text = bike.currentMileageString
        }
        
        view.backgroundColor = .white
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)
        doneBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)

        
        doneBarButton?.isEnabled = false
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)

        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = cancelBarButton
        doneBarButton?.tintColor = .mainRed();
        cancelBarButton?.tintColor = .mainRed()
   
        titleBar.addTitleBarAndLabel(page: view, initialTitle:"Enter Mileage", ypos: 0, color:.mainRed())
        
        print("NAVBAR \(topBarHeight)")
        
        view.addSubview(scrollView)
        scrollView.addSubview(svContentView)
        svContentView.addSubview(mileageTextView)
        svContentView.addSubview(mileageTextField)
        
        milesHoursSegmentedControl.addTarget(self, action: #selector(toggleMilesHours), for: .valueChanged)
        
        navigationItem.leftBarButtonItem?.tintColor = .mainRed()
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)

    
        svContentView.addSubview(dottedLineView1)
        svContentView.addSubview(dottedLineView2)
        svContentView.addSubview(self.currentMileageLabel)
        svContentView.addSubview(milesHoursSegmentedControl)
        svContentView.addSubview(hoursMilesLabel)
        svContentView.addSubview(mileageTextField)
        svContentView.addSubview(enterMileageLabel)
        
        
         titleBar.addTitleBarAndLabel(page: view, initialTitle:"Enter Mileage", ypos: 0, color:.mainRed())
       
        mileageTextField.returnKeyType = .done
        self.mileageTextField.delegate = self
        self.mileageTextField.addTarget(self, action: #selector(didStartEditing), for: .editingDidBegin)
        self.mileageTextField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        self.mileageTextField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEnd)
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        svContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height*1.25)
        
        self.mileageTextView.anchor(top: svContentView.topAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 35, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 160)
        
         self.dottedLineView1.anchor(top: mileageTextView.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)

        self.milesHoursSegmentedControl.anchor(top: dottedLineView1.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
          self.enterMileageLabel.anchor(top: milesHoursSegmentedControl.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: nil, paddingTop:15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        self.currentMileageLabel.anchor(top: enterMileageLabel.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: nil, paddingTop:15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        self.mileageTextField.anchor(top: enterMileageLabel.bottomAnchor, left: currentMileageLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0 , height: 25 )
        
         self.dottedLineView2.anchor(top: mileageTextField.bottomAnchor, left: svContentView.leftAnchor, bottom: nil, right: svContentView.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)
        

        
//        shouldRemindSwitch.addTarget(self, action: #selector(switchChanged(_ :)), for: .valueChanged)
        
        let toolBar = UIToolbar()
        let barDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        barDoneButton.tintColor = .mainRed()
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.disabled)
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.focused)
        barDoneButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)

        toolBar.setItems([flexibleSpace, barDoneButton], animated: true)
        toolBar.sizeToFit()
        mileageTextField.inputAccessoryView = toolBar
        
        drawDottedLines()
    }
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        var kbHeight = (keyboardFrame.height - 80) * (show ? 1 : -1)
        
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
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.numValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
            selectedNumber = numValues[row]
            selectedNumInt = row
            numberChanged(row: row)
//            doneBarButton?.isEnabled = true
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numValues.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
//    @objc func switchChanged(_ switch: UISwitch) -> Bool {
//        setReminderLabel.isHidden = !shouldRemindSwitch.isOn
//        toggleMilesHours(sender: milesHoursSegmentedControl)
//        return setReminderLabel.isHidden
//    }
    
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
    
     @objc func done() {
        delegate?.mileageViewControllerDidFinishEditing(self)
    }
    
    @objc func toggleMilesHours(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 1:
            self.valueType = "Miles"
            self.bike.selectedValue = "Miles"
            self.selectedNumber = "100"
            mileageTextField.attributedPlaceholder = NSAttributedString(string: "Enter Current \(self.valueType)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.veryLightGray()])
            currentMileageLabel.text = "current mileage:".uppercased()
            updateNumberLabel()
//            self.setReminderLabel.text = "Set for: \(self.selectedNumber) \(self.valueType)"
            if bike.currentMileageString == nil {
                mileageTextField.text = "0"
            } else {
                mileageTextField.text = bike.currentMileageString
            }
            
        case 2:
            self.valueType = "Km"
             self.bike.selectedValue = "Km"
            self.selectedNumber = "100"
            mileageTextField.attributedPlaceholder = NSAttributedString(string: "Enter Current \(self.valueType)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.veryLightGray()])
            currentMileageLabel.text = "current Km:".uppercased()
            updateNumberLabel()
//            self.setReminderLabel.text = "Set for: \(self.selectedNumber) \(self.valueType)"
            if bike.currentMileageString == nil {
                mileageTextField.text = "0"
            } else {
                mileageTextField.text = bike.currentMileageString
            }
            
        default:
            self.valueType = "Hours"
             self.bike.selectedValue = "Hours"
            self.selectedNumber = "1"
            mileageTextField.attributedPlaceholder = NSAttributedString(string:  "Enter Current \(self.valueType)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.veryLightGray()])
            currentMileageLabel.text = "current hours:".uppercased()
            updateNumberLabel()
//            self.setReminderLabel.text = "Set for: \(self.selectedNumber) \(self.valueType)"
            if bike.currentHoursString == nil {
                mileageTextField.text = "0"
            } else {
                mileageTextField.text = bike.currentHoursString
            }
        }
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

    @objc func cancel() {
        print("cancelling")
        delegate?.mileageViewControllerDidCancel(self)
    }
    
    @objc func didStartEditing(textField:UITextField) {
        doneBarButton?.isEnabled = false
    }
    
    @objc func didChangeText(textField:UITextField) {
        let newText = self.mileageTextField.text! as NSString
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneBarButton?.isEnabled = true
        self.view.endEditing(true)
        return true
    }
    
    @objc func numberChanged(row: Int) {
        print("what is the new number?")
        self.updateNumberLabel()
    }
    
    func updateNumberLabel() {
//            self.setReminderLabel.text = "Set for: \(self.selectedNumber) \(self.valueType)"
    }
//
    
    @objc func doneClicked(){
        if valueType == "Miles" || valueType == "Km" {
            bike.currentMileageString = mileageTextField.text!
        } else {
            bike.currentHoursString = mileageTextField.text!
        }
        bikes = []
        let savedBikes = loadUserBikes()
        bikes = savedBikes!
        bike.selectedValue = self.valueType
        print("what is the selected index path \(self.selectedIndexPath)")
        bikes[(self.buttonRow)!] = bike
            saveBikes()
            view.endEditing(true)
    }

    private func loadUserBikes() -> [FB_Bike]?  {
        //self.checkCoachMark()
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }

    private func saveBikes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.bikes, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("successfully saved")
        } else {
            print("un-successfully saved")
        }
    }
    
    //Due Date
    func updateDueDateLabel() {
        let date = NSDate(timeIntervalSince1970: TimeInterval(truncating: self.reminderDate!)) as Date
        self.reminderDate = date.timeIntervalSince1970 as NSNumber
//        setReminderLabel.text = date.toString(dateFormat: "MMM d, h:mm a")
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
                    //strongSelf.notesTextView.resignFirstResponder()
                }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
