    //
//  MaintenanceViewController.swift
//  mp
//
//  Created by DQ on 1/4/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase


class MaintenanceViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MaintenanceDetailViewControllerDelegate, UIScrollViewDelegate

{
  
    fileprivate let maintenanceCellIdentifier = "MaintenanceItem"
    
    var bike: FB_Bike!
    var uid:String!
    var selectedIndexPath:IndexPath?
    var maintenanceIndexPath:IndexPath?
    var bikes:[FB_Bike] = []
    
    var alertMileageTextField = UITextField()
    
    let dottedLineView1 = UIView()
    
    var mileageView:UIView = UIView()
    
    let currentMileageLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Medium", size: 17)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.text = "current mileage".uppercased()
        return label
    }()
    
    let mileageButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 11)
        button.setTitle("Update", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainRed()
        button.layer.cornerRadius = 2
        return button
    }()
    
    var cellId = "cellId"
    
    var tableView:UITableView = UITableView()
    var sectionArray = [String]()
    var tempArray = [String]()
    var itemArray = [[FB_MaintenanceItem]]()
    var categoryArray = [String]()
    
    var dict = [String:[FB_MaintenanceItem]]()
    
    var sortedSections = [String]()
    var tableSection = [FB_MaintenanceItem]()
    var maintenanceItems: [FB_MaintenanceItem] = []
    var currentMaintenanceItem:FB_MaintenanceItem?
    
    var valueType:String = "Miles"
    var titleBar:TitleBar = TitleBar()
    
    var count:Int = 0
    var coachMark:UIView?
    
    let headerTitleBar: UIView = {
        let tb = UIView()
        tb.backgroundColor = .black
        return tb
    }()
    
    let scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.setEditing(false, animated: true)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        if bike.selectedValue != nil {
            self.valueType = self.bike.selectedValue!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
         drawDottedLines()
        self.bike = BikeData.sharedInstance.bike!
        self.selectedIndexPath = BikeData.sharedInstance.selectedIndexPath
        
        if bike.currentMileageString == nil {
            bike.currentMileageString = "0"
        }
        if bike.currentHoursString == nil {
            bike.currentHoursString = "0"
        }
        
        if bike.selectedValue == "Miles" {
            currentMileageLabel.text = "Current Mileage: \(bike.currentMileageString!)"
        } else if bike.selectedValue == "Hours"{
            currentMileageLabel.text = "Current Hours: \(bike.currentHoursString!)"
        } else if bike.selectedValue == "Km" {
            currentMileageLabel.text = "Current Km: \(bike.currentMileageString!)"
        }
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.tableViewBgGray()
        
        if bike.selectedValue != nil {
            self.valueType = self.bike.selectedValue!
        }
        
        //guard let bike = bike else { return }
        view.addSubview(mileageView)
        view.addSubview(dottedLineView1)
        mileageView.addSubview(currentMileageLabel)
        mileageView.addSubview(mileageButton)
        view.addSubview(tableView)
        
        mileageView.backgroundColor = UIColor.black
        alertMileageTextField.keyboardType = .numberPad
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        titleBar.addTitleBarAndLabel(page: view, initialTitle: "MAINTENANCE LOG", ypos: topBarHeight)
        mileageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 89, paddingLeft: 00, paddingBottom: 0, paddingRight: 0, width: 0, height: 75)
        
        dottedLineView1.anchor(top: mileageView.topAnchor, left: mileageView.leftAnchor, bottom: nil, right: mileageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        currentMileageLabel.anchor(top: mileageView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
         currentMileageLabel.centerXAnchor.constraint(equalTo: mileageView.centerXAnchor).isActive = true
        mileageButton.anchor(top: currentMileageLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop:10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 24)
         mileageButton.centerXAnchor.constraint(equalTo: mileageView.centerXAnchor).isActive = true
        tableView.anchor(top: mileageView.bottomAnchor , left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        tableView.register(MaintenanceCell.self, forCellReuseIdentifier: cellId)
        
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: self.tabBarController!.tabBar.frame.height, right: 0)
        self.tableView.contentInset = adjustForTabbarInsets
        self.tableView.scrollIndicatorInsets = adjustForTabbarInsets
        
        let cm:UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0, alpha: 0.8)
            return view
        }()
        
        let cmText:UITextView = {
            let tv = UITextView()
            tv.font = UIFont(name: "Avenir-Medium", size: 16)
            tv.textColor = UIColor.black
            tv.text = "Log your MAINTENANCE.\n\nTouch the “+” button in the upper right to add a new item.\n\nEnter a Title, document Mileage, select a Category and add Notes.\n\nYou can also set a reminder to schedule upcoming MAINTENANCE.\n\n"
            return tv
        }()
        
        let cmBg:UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            view.layer.borderWidth = 2.0
            view.layer.borderColor =   UIColor.mainRed().cgColor
            view.layer.cornerRadius = 10
            return view
        }()

        let cmArrowImage:UIImageView = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "curve_sign_small"))
            return iv
        }()
        
        adjustUITextViewHeight(arg: cmText)
        view.addSubview(scrollView)
        scrollView.addSubview(cm)
        cm.addSubview(cmBg)
        cmBg.addSubview(cmText)
       // cm.addSubview(cmImg)
        
        let textHeightOffset = (cmText.frame.height + view.frame.height) - view.frame.height
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: topBarHeight, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cm.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop:0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height + textHeightOffset )
      
        //cm.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 64, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
       // cmImg.anchor(top: cm.topAnchor, left: cm.leftAnchor, bottom: cm.bottomAnchor, right: cm.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height:0)
        
        cm.addSubview(cmArrowImage)
        cmArrowImage.anchor(top: cm.topAnchor, left: nil, bottom: nil, right: cm.rightAnchor, paddingTop: 35, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
         cmBg.anchor(top: cmArrowImage.bottomAnchor, left: cm.leftAnchor, bottom: nil, right: cm.rightAnchor, paddingTop:10, paddingLeft: 10, paddingBottom:20, paddingRight: 10, width: 0, height:0)
        
          cmText.anchor(top: cmBg.topAnchor, left: cmBg.leftAnchor, bottom: cmBg.bottomAnchor, right: cmBg.rightAnchor, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        
      
        let fixedWidth = cmText.frame.size.width
        let newSize = cmText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        cmText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height + 20)
        
        cmBg.dropShadow()
        
        self.coachMark = scrollView
        coachMark?.isHidden = false
        mileageView.isHidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddMaintenanceTask))
        navigationItem.rightBarButtonItem?.tintColor = .mainRed()
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        
        self.getMaintenanceItems()
        mileageButton.addTarget(self, action: #selector(mileageButtonHandler), for: .touchUpInside)
    }
    
    func checkCoachMark() {
        if (maintenanceItems.count > 0) {
            coachMark?.isHidden = true
            mileageView.isHidden = false
        }
    }
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }

    func drawDottedLines() {
        //layer dashed line
        let layer1 = dottedLineView1.layer
        
        let lineDashPatterns: [[NSNumber]?]  = [[3,5]]
        for (index, lineDashPattern) in lineDashPatterns.enumerated() {
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = UIColor.veryLightGray().cgColor
            shapeLayer.lineWidth = 0.5
            shapeLayer.lineDashPattern = lineDashPattern
            
            let path = CGMutablePath()
            let y = CGFloat(index * 50)
            path.addLines(between: [CGPoint(x: 0, y: y), CGPoint(x: 640, y: y)])
            
            shapeLayer.path = path
            layer1.addSublayer(shapeLayer)
        }
    }
    
    @objc func mileageButtonHandler() {
        if bike.selectedValue == nil {
            bike.selectedValue = "Miles"
        }
       
            let alert = UIAlertController(title: "Update your \(String(describing: bike.selectedValue!)):", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.view.tintColor = .black
            alert.addTextField { (alertMileageTextField) in
       
                if self.bike.currentMileageString != nil && self.bike.selectedValue == "Miles" {
                   alertMileageTextField.text = self.bike.currentMileageString!
                }     else if self.bike.currentHoursString != nil && self.bike.selectedValue == "Hours" {
                   alertMileageTextField.text = self.bike.currentHoursString!
                }  else if self.bike.currentMileageString != nil && self.bike.selectedValue == "Km" {
                    alertMileageTextField.text = self.bike.currentMileageString!
                } else {
                    alertMileageTextField.text = "0"
                }
                self.alertMileageTextField = alertMileageTextField
                alertMileageTextField.keyboardType = .numberPad
                alertMileageTextField.keyboardAppearance = .dark
            }
            
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { action in
            if self.bike.selectedValue == "Miles" {
                self.bike.currentMileageString = self.alertMileageTextField.text
            } else if self.bike.selectedValue == "Hours" {
                self.bike.currentHoursString = self.alertMileageTextField.text
            } else if self.bike.selectedValue == "Km" {
                self.bike.currentMileageString = self.alertMileageTextField.text
            }
            if self.bike.selectedValue == "Miles" {
                self.currentMileageLabel.text = "Current Mileage: \(self.bike.currentMileageString!)"
            } else  if self.bike.selectedValue == "Hours" {
                self.currentMileageLabel.text = "Current Hours: \(self.bike.currentHoursString!)"
            } else if self.bike.selectedValue == "Km" {
               
                self.currentMileageLabel.text = "Current Km: \(self.bike.currentMileageString!)"
            }
            self.bikes[(self.selectedIndexPath?.row)!] = self.bike
            self.saveBikes()
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func handleAddMaintenanceTask() {
        let addMaintenanceTaskViewController = MaintenanceDetailViewController()
        let navController = UINavigationController(rootViewController: addMaintenanceTaskViewController)
        addMaintenanceTaskViewController.delegate = self
        addMaintenanceTaskViewController.bike = self.bike
        addMaintenanceTaskViewController.selectedIndexPath = self.selectedIndexPath
        self.present(navController, animated: true, completion: nil)
    }
   
    
    func setupTitleValues() {
        self.categoryArray = []
        self.itemArray = []
        self.dict = [:]
        self.sortedSections = []
        self.tableSection = []

        for item in maintenanceItems {
            self.categoryArray.append(item.category!)
        }
        let mySet = Set<String>(categoryArray)
        
            categoryArray = Array(mySet)
            categoryArray.sort{$0 < $1}
        
        self.itemArray = Array(repeating: [FB_MaintenanceItem]() , count: categoryArray.count)
        
        for i in 0..<maintenanceItems.count {
            for k in 0..<categoryArray.count {
                if maintenanceItems[i].category == categoryArray[k] {
                    itemArray[k].append(maintenanceItems[i])
                }
            }
            //making the dictionary here
            for (index, element) in categoryArray.enumerated()
            {
                self.dict[element] = itemArray[index]
            }
            self.sortedSections = categoryArray
            }
        }
    
    func getMaintenanceItems() {
        self.bikes = []
        if let savedBikes = self.loadUserBikes() {
            self.bikes += savedBikes
        }
        self.maintenanceItems = bike.maintenance!
        self.setupTitleValues()
        checkCoachMark()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func maintenanceDetailViewControllerDidCancel(_ controller: MaintenanceDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    //
    func maintenanceDetailViewController(_ controller: MaintenanceDetailViewController, didFinishAdding item: FB_MaintenanceItem) {
        tableView.setEditing(false, animated: true)
       // self.setupTitleValues()
        self.currentMaintenanceItem = item
        self.getMaintenanceItems()
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
         dismiss(animated: true, completion: nil)
    }
    
    func maintenanceDetailViewController(_ controller: MaintenanceDetailViewController, didFinishEditing item: FB_MaintenanceItem) {
        tableView.setEditing(false, animated: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        self.setupTitleValues()
        dismiss(animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            configure(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.white
        }
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Avenir-Medium", size: 11)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        headerView.backgroundColor = .tableHeaderBG()
        header.backgroundView = headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75;//Choose your custom row height
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = dict[sortedSections[section]]?.count
        return sectionInfo!
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = sortedSections[section]
        return sectionInfo.uppercased()
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        let sections = self.dict.count
        return sections
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func deleteItem(indexPath:IndexPath) {
        bikes[(selectedIndexPath?.row)!] = self.bike
        bikes[(selectedIndexPath?.row)!].maintenance? = self.maintenanceItems
        saveBikes()
        
        self.setupTitleValues()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
    }
    
    func updateBikes() {
        bikes = []
        if let savedBikes = loadUserBikes() {
            bikes += savedBikes
        }
        maintenanceItems = bike.maintenance!
        checkCoachMark()
        saveBikes()
    }
    
    private func loadUserBikes() -> [FB_Bike]?  {
        //self.checkCoachMark()
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }
    
    private func saveBikes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("successfully saved")
            BikeData.sharedInstance.allBikes = self.bikes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            print("un-successfully saved")
        }
    }
    
    func showAsCompleted(indexPath:IndexPath) {
        tableSection = dict[sortedSections[indexPath.section]]!
        let maintenanceItem = tableSection[indexPath.row]
        
        maintenanceItem.shouldRemind = false
        if (bike.selectedValue == "Miles") {
            let bm = bike.currentMileageString!
            maintenanceItem.completedAtString = bm
            maintenanceItem.storedMileageRef = Int(bike.currentMileageString!)
        } else if (bike.selectedValue == "Hours") {
            let bh = bike.currentHoursString!
            maintenanceItem.completedAtString = bh
            maintenanceItem.storedMileageRef = Int(bike.currentMileageString!)
        }
        else if (bike.selectedValue == "Km") {
            let bm = bike.currentMileageString!
            maintenanceItem.completedAtString = bm
            maintenanceItem.storedMileageRef = Int(bike.currentMileageString!)
        }
        
        //maintenanceItem.mileageTotal = Int(bike.currentMileageString!)!
    
        //self.bikes[(self.selectedIndexPath?.row)!].maintenance?[(self.maintenanceIndexPath?.row)!] = maintenanceItem
        self.bikes[(self.selectedIndexPath?.row)!] = self.bike
        self.saveBikes()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.tableSection = self.dict[self.sortedSections[indexPath.section]]!
            let deleteMsg = "Are you sure you want\nto delete this Maintenance Item? \n You cannot undo this action."
            let alert = UIAlertController(title: "Delete Maintenance Item?", message: deleteMsg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
            
                let i = self.maintenanceItems.firstIndex(of:self.tableSection[indexPath.row])
                self.maintenanceItems.remove(at: i!)
                self.tableSection.remove(at: indexPath.row)
                self.deleteItem(indexPath: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "View/Edit") { (action, indexPath) in
            let editMaintenanceViewController = MaintenanceDetailViewController()
            let navController = UINavigationController(rootViewController: editMaintenanceViewController)
            self.tableSection = self.dict[self.sortedSections[indexPath.section]]!
            self.currentMaintenanceItem = self.tableSection[indexPath.row]
                editMaintenanceViewController.delegate = self
                editMaintenanceViewController.bike = self.bike
                editMaintenanceViewController.bikes = self.bikes
                editMaintenanceViewController.taskToEdit = self.currentMaintenanceItem
                editMaintenanceViewController.selectedIndexPath = self.selectedIndexPath
            self.maintenanceIndexPath = indexPath
            editMaintenanceViewController.maintenanceIndexPath = self.maintenanceIndexPath
            
            self.present(navController, animated: true, completion: nil)
        }
    
       let completed = UITableViewRowAction(style: .destructive, title: "Completed") { (action, indexPath) in
            self.tableSection = self.dict[self.sortedSections[indexPath.section]]!
//            let projectItem = self.tableSection[indexPath.row]
            self.showAsCompleted(indexPath:indexPath)
        }
        
        
        let newSwiftColor = UIColor(red: 100.0/255, green: 100.0/255, blue: 100.0/255, alpha: 1)
        let completedColor = UIColor(red: 35.0/255, green: 79.0/255, blue: 3.0/255, alpha: 1)
            edit.backgroundColor = newSwiftColor
            completed.backgroundColor = completedColor
        
        self.tableSection = self.dict[self.sortedSections[indexPath.section]]!
        if self.tableSection[indexPath.row].shouldRemind == false {
             return [delete, edit]
        } else {
        return [delete, edit, completed]
        }
    }
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? MaintenanceCell else {
            return
        }
        tableSection = dict[sortedSections[indexPath.section]]!
        let maintenanceItem = tableSection[indexPath.row]
            cell.nameLabel.text = maintenanceItem.title
            //cell.maintenanceNotes.isEditable = false
            cell.maintenanceNotes.text = maintenanceItem.notes
            print("\(cell.maintenanceNotes) = maintenanceItem.notes")

        let currentMileage = bike.currentMileageString
//        print("CURRENT MILEAGE IS \(String(describing: currentMileage))")
       
        if bike.selectedValue == "Miles" || bike.selectedValue == nil {
            cell.mileageLabel.text = ("Current Miles: \(bike.currentMileageString!)")
        } else if bike.selectedValue == "Hours" {
            cell.mileageLabel.text = ("Current Hours: \(bike.currentHoursString!)")
        }else if bike.selectedValue == "Km" {
            cell.mileageLabel.text = ("Current Km: \(bike.currentMileageString!)")
        }
        
        if bike.selectedValue == "Miles" || bike.selectedValue == "Km" {
            if maintenanceItem.mileageTotal != nil && maintenanceItem.shouldRemind == true {
//                && bike.currentMileageString != "" && maintenanceItem.shouldRemind == true
//                print("\(String(describing: maintenanceItem.mileageTotal)) is the MILEAGE TOTAL from Maintenance Item")
//                print("CURRENT MILEAGE FROM #2 IS \(currentMileage)")
            if maintenanceItem.mileageTotal! <= Int(bike.currentMileageString!)! {
                    cell.overdueLabel.isHidden = false
                } else {
                    cell.overdueLabel.isHidden = true
                }
            } else {
                 cell.overdueLabel.isHidden = true
            }

        } else if (bike.selectedValue == "Hours") {
            if Int(maintenanceItem.mileageTotal!) < Int(bike.currentHoursString!)! && maintenanceItem.shouldRemind == true{
                cell.overdueLabel.isHidden = false
            } else {
                cell.overdueLabel.isHidden = true
            }
        }
//
        if maintenanceItem.completedAtString != nil && maintenanceItem.shouldRemind == false {
            cell.completedAtLabel.text = "Completed at: \(maintenanceItem.completedAtString!) \(bike.selectedValue!)"
            cell.completedAtLabel.isHidden = false
        } else {
            cell.completedAtLabel.text = ""
            cell.completedAtLabel.isHidden = true
        }
//
        if (maintenanceItem.shouldRemind == true) {
            if maintenanceItem.reminderNumber != nil {
                   cell.reminderDateLabel.text = "Reminder at \(String(describing: maintenanceItem.mileageTotal!)) \(bike.selectedValue!)"
                }
            guard let cm = currentMileage else {return}
            if (cm > (cm + String(describing: maintenanceItem.reminderNumber)) ) {
                cell.alarm.image = #imageLiteral(resourceName: "alarm_clock_off")
            } else {
                cell.alarm.image = #imageLiteral(resourceName: "alarm_clock")
            }
            cell.reminderDateLabel.isHidden = false
            cell.alarm.isHidden = false
        } else {
            cell.reminderDateLabel.isHidden = true
            cell.alarm.isHidden = true
        }
       
    }
}
    


