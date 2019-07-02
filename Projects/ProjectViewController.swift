
//
//  ViewController.swift
//  MP
//
//  Created by DANIEL I QUINTERO on 11/28/16.
//  Copyright © 2016 DanielIQuintero. All rights reserved.
//
import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import Photos
//import DataCache
class ProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  AddProjectViewControllerDelegate, PhotosViewControllerDelegate, UITabBarControllerDelegate, UIScrollViewDelegate {
    
    var cellId = "cellId"
    var tableView:UITableView = UITableView()
    
    @objc func cancelThisView() {
        dismiss(animated: true, completion: nil)
    }
    
    var sectionArray = [String]()
    var tempArray = [String]()
    var projectTextArray = [[FB_ProjectItem]]()
    var categoryArray = [String]()
    var dict = [String:[FB_ProjectItem]]()
    var sortedSections = [String]()
    var tableSection = [FB_ProjectItem]()
    var projects: [FB_ProjectItem]?
    var bikes:[FB_Bike] = []
    var bike:FB_Bike!
    var delegate: UIViewController?
    var coachTipView:UIView?
    var currentProject:FB_ProjectItem?
    var uid:String!
    var titleBar = TitleBar()
    var photosViewController = PhotosViewController()
    var coachMark:UIView?
    var projectIndexPath:IndexPath?
    var selectedIndexPath:IndexPath?
    
    let scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        self.getProjects()
        tableView.setEditing(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectIndexPath = nil
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        tabBarController?.delegate = self
    
        self.selectedIndexPath = BikeData.sharedInstance.selectedIndexPath
        print("\(String(describing: BikeData.sharedInstance.bike)) this is an actual value")
        view.backgroundColor = UIColor.tableViewBgGray()
        
        guard let bike = bike else { return }
        
        BikeData.sharedInstance.bike = self.bike
        
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.backgroundColor = UIColor.tableViewBgGray()
//        tableView.backgroundColor = UIColor.nearlyBlack()
        tableView.backgroundColor = UIColor.tableViewBgGray()
        
        view.addSubview(tableView)
        
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        if let bn = bike.name {
            titleBar.addTitleBarAndLabel(page: view, initialTitle: "PROJECTS for \(bn)", ypos: topBarHeight)
        } else {
            titleBar.addTitleBarAndLabel(page: view, initialTitle: "PROJECTS", ypos: topBarHeight)
        }
        
        tableView.anchor(top: titleBar.headerTitleBar?.bottomAnchor , left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        tableView.anchor(top: view.topAnchor , left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        
        tableView.register(ProjectCell.self, forCellReuseIdentifier: cellId)
        
        let cm:UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0, alpha: 0.8)
            return view
        }()
        
        let cmBg:UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            view.layer.borderColor = UIColor.mainRed().cgColor
            view.layer.borderWidth = 2.0
            view.layer.cornerRadius = 10
            return view
        }()
        
        let cmText:UITextView = {
            let tv = UITextView()
            tv.isEditable = false
            tv.isSelectable = false
            tv.font = UIFont(name: "Avenir-Medium", size: 16)
            tv.textColor = UIColor.black
            tv.text = "PROJECTS is where you'll be tracking the progress of your BIKE.\n\nTouch the “+” button in the upper right to get started.\n\nTitle your PROJECT, select a Category, add some Photos and Notes.\n\nTouch your PROJECT thumbnail to see the PROJECT DETAILS.\n\nSwipe left to edit from within the PROJECTS list.\n\n"
            return tv
        }()
        
        
        
//        let cmText:UITextView = {
//            let tv = UITextView()
//            tv.font = UIFont(name: "AvenirNextCondensed-Regular", size: 17)
//            tv.textAlignment = .left
//            tv.textColor = UIColor.white
//            tv.isEditable = false
//            tv.backgroundColor = UIColor(white: 0, alpha: 0.0)
//            tv.text = "PROJECTS is where you'll be tracking the progress of your BIKE.\n\nTouch the “+” button in the upper right to get started.\n\nTitle the PROJECT, select a Category, add Photos and Notes.\n\nAll of this information will be stored on the PROJECT DETAIL screen.\n\nEdits can be made by swiping left from the main PROJECT list screen or by tapping the PROJECT icon from within the PROJECT DETAIL screen."
//            return tv
//        }()
        
//        let cmImg:UIImageView = {
//            let iv = UIImageView(image:#imageLiteral(resourceName: "cm_projects"))
//            iv.contentMode = .scaleAspectFit
//            return iv
//
//        }()
        
        let cmArrowImage:UIImageView = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "curve_sign_small"))
            return iv
        }()
        
    
        adjustUITextViewHeight(arg: cmText)
        
        view.addSubview(scrollView)
        scrollView.addSubview(cm)
        cm.addSubview(cmBg)
        cmBg.addSubview(cmText)
        //cm.addSubview(cmImg)
        
        let textHeightOffset = (cmText.frame.height + view.frame.height) - view.frame.height
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: topBarHeight, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cm.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop:0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height + textHeightOffset )
       // cm.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 64, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
      //  cmImg.anchor(top: cm.topAnchor, left: cm.leftAnchor, bottom: cm.bottomAnchor, right: cm.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height:0)
        cm.addSubview(cmArrowImage)
        cmArrowImage.anchor(top: cm.topAnchor, left: nil, bottom: nil, right: cm.rightAnchor, paddingTop: 35, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
       // cmBg.anchor(top: cmArrowImage.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 90, paddingRight: 10, width: 0, height: 0)
        
        cmBg.anchor(top: cmArrowImage.bottomAnchor, left: cm.leftAnchor, bottom: nil, right: cm.rightAnchor, paddingTop:10, paddingLeft: 10, paddingBottom:20, paddingRight: 10, width: 0, height: 0 )
        
        cmText.anchor(top: cmBg.topAnchor, left: cmBg.leftAnchor, bottom: cmBg.bottomAnchor, right: cmBg.rightAnchor, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        
        
        let fixedWidth = cmText.frame.size.width
        let newSize = cmText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        cmText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height + 10)
        
        cmBg.dropShadow()
        
        self.coachMark = scrollView
        coachMark?.isHidden = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Garage", style: .plain, target: self, action: #selector(cancelThisView))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "garage_open_pressed"), style: .plain, target: self, action: #selector(cancelThisView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddProject))
        
        navigationItem.leftBarButtonItem?.tintColor = .mainRed()
        navigationItem.rightBarButtonItem?.tintColor = .mainRed()
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: .normal)
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: .selected)
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: .highlighted)
        
        navigationItem.backBarButtonItem = backButton
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        
        self.delegate = self
        self.getProjects()
    }
    
    func checkCoachMark() {
        if (bike.projects?.count != 0) {
            coachMark?.isHidden = true
        } else {
            coachMark?.isHidden = false
        }
    }
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }

    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        //        let tabBarIndex = tabBarController.selectedIndex
//        navigationController?.popViewController(animated: true)
//    }
    
    @objc func handleAddProject() {
        let addProjectViewController = AddProjectViewController()
        let navController = UINavigationController(rootViewController: addProjectViewController)
        addProjectViewController.delegate = self
        addProjectViewController.bike = self.bike

        
        self.present(navController, animated: true, completion: nil)
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
        print(self.sortedSections)
    }
    
    func getProjects() {
        self.bikes = []
        if let savedBikes = self.loadUserBikes() {
            self.bikes = savedBikes
            BikeData.sharedInstance.allBikes = self.bikes
        }
        self.projects = bike.projects
        self.setupTitleValues()
        //saveBikes()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        self.checkCoachMark()
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.white
        }
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Avenir", size: 11)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        headerView.backgroundColor = .tableHeaderBG()
        header.backgroundView = headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        configure(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = dict[sortedSections[section]]?.count
        return sectionInfo!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        SECTION 
        let sectionInfo = sortedSections[section]
        return sectionInfo.uppercased()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = self.dict.count
        return sections
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableSection = self.dict[self.sortedSections[indexPath.section]]!
        let projectItem = self.tableSection[indexPath.row]
        //let projectItem = projects![indexPath.row]
        print("CLICKED INDEX PATH ********************* \(indexPath)")
        photosViewController = PhotosViewController()
        photosViewController.delegate = self
        photosViewController.project = projectItem
        photosViewController.bike = self.bike
        photosViewController.bikes = self.bikes
        self.projectIndexPath = indexPath
        photosViewController.projectIndexPath = self.projectIndexPath
        photosViewController.projects = self.projects
        navigationController?.pushViewController(photosViewController, animated: true)
    }
    
    func updateBikes() {
        bikes = []
        if let savedBikes = loadUserBikes() {
            bikes = savedBikes
            BikeData.sharedInstance.allBikes = bikes
        }
        projects = bike.projects
        saveBikes()
    }
    
    private func loadUserBikes() -> [FB_Bike]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }
    
    private func saveBikes() {
        BikeData.sharedInstance.allBikes = self.bikes
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(BikeData.sharedInstance.allBikes, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("\(BikeData.sharedInstance.allBikes.count) the bikes count from SAVE BIKES Bikes")
            getProjects()
            //self.checkCoachMark()
        } else {
            print("un-successfully saved")
        }
    }
    

    
    // Edit and Delete
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.tableSection = self.dict[self.sortedSections[indexPath.section]]!
            let deleteMsg = "Are you sure you want to\ndelete this Project? \nYou cannot undo this action."
            
            let projectItem = self.tableSection[indexPath.row]
            let name = projectItem.text!
            let alert = UIAlertController(title: "Delete \(name)?", message: deleteMsg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
                
               // if let projects = self.projects {
                //var p = self.projects
                print("\(self.projects?.count) length before")
                if self.projects != nil {
                    let i = self.projects?.firstIndex(of:self.tableSection[indexPath.row])
                    self.projects?.remove(at: i!)
                    print("\(self.projects?.count) length after")
                    self.tableSection.remove(at: indexPath.row)
                    self.deleteItem(indexPath: indexPath)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            
            self.tableSection = self.dict[self.sortedSections[indexPath.section]]!
            let projectItem = self.tableSection[indexPath.row]
            self.currentProject = projectItem
            
            let addProjectViewController = AddProjectViewController()
            let navController = UINavigationController(rootViewController: addProjectViewController)
            addProjectViewController.delegate = self
            addProjectViewController.bike = self.bike
            addProjectViewController.bikes = self.bikes
            addProjectViewController.projectToEdit = projectItem
            
            self.projectIndexPath = indexPath
            addProjectViewController.projectIndexPath = self.projectIndexPath
            
            print("PROJECT INDEX PATH FROM LIST VIEW EDIT   ********************* \(self.projectIndexPath)")
            
            
            self.present(navController, animated: true, completion: nil)
        }
        let newSwiftColor = UIColor(red: 100.0/255, green: 100.0/255, blue: 100.0/255, alpha: 1)
        edit.backgroundColor = newSwiftColor
        
        return [delete, edit]
    }
    
    func deleteItem(indexPath:IndexPath) {
        
        print("TRYING TO DELETE")
        //
        bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = self.bike
        if let projects = self.projects {
            bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects? = projects
        }
        saveBikes()
        self.setupTitleValues()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? ProjectCell else {
            return
        }
        tableSection = dict[sortedSections[indexPath.section]]!
        let projectItem = tableSection[indexPath.row]
        cell.projectLabel.text = projectItem.text
        cell.notesTextView.text = projectItem.notes
        let iconImageView = cell.thumbNailImageView as UIImageView
        
        iconImageView.layer.borderWidth = 1
        let newSwiftColor = UIColor(red: 200.0/255, green: 200.0/255, blue: 200.0/255, alpha: 0.8)
        iconImageView.layer.borderColor = newSwiftColor.cgColor
        
        if projectItem.imageName != nil {
            print("\(projectItem.imageName) = projectItem image name ")
            let helper = MRPhotosHelper()
            if let identifier = projectItem.imageName {
                helper.retrieveImageWithIdentifer(localIdentifier: identifier, completion: { (image) -> Void in
                    iconImageView.image = image
                })
            }
        } else {
            iconImageView.image = #imageLiteral(resourceName: "bikeThumbNail")
        }
        // cell.backgroundColor = .black
    }
    
    //for the Delegate Protocols
    func addProjectViewControllerDidCancel(_ controller: AddProjectViewController) {
        tableView.setEditing(false, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func addProjectViewController(_ controller: AddProjectViewController, didFinishAddingThumbnail item: FB_ProjectItem) {
        bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = item
        projects = bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects
        bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
        tableView.setEditing(false, animated: true)
        //        self.setupTitleValues()
        //        print("DID FINISH ADDING THUMBNAIL")
        //        DispatchQueue.main.async {
        //            self.tableView.reloadData()
        //        }
        //        self.setupTitleValues()
    }
    
    func addProjectViewController(_ controller: AddProjectViewController, didFinishAdding item: FB_ProjectItem) {
        print("DID FINISH ADDING ----------------->>>>>>>>")
        
         DispatchQueue.main.async {
            self.tableView.setEditing(false, animated: true)
            self.getProjects()
        }
        DispatchQueue.main.async {
           
            self.setupTitleValues()
            
            let indexOfSection = self.sortedSections.firstIndex(of: item.category!)
            
            print("DAMMIT give me the idex   \(indexOfSection)")
            
            print(self.dict)
            
            let arr = self.dict[item.category!]
            
            let indexOfRow = arr?.firstIndex(where: { $0.uniqueID == item.uniqueID! })
            self.projectIndexPath = IndexPath(row: indexOfRow!, section: indexOfSection!)
//            var sec:Int = 0
//            var r:Int = 0
//            var c:Int = (self.projects?.count)!
//            var nSections = self.tableView.numberOfSections
//            for j in 0 ..< nSections {
//                if nSections == 0 {
//                    self.projectIndexPath = [0, 0]
//                }
//                var nRows = self.tableView.numberOfRows(inSection: j)
//
//                for i in 0 ..< nRows {
//                    var indexPath = IndexPath(row: i, section: j)
//                    print("printed index path \(indexPath)")
//                }
//            }
//
//            if r != nil && sec != nil {
//                self.projectIndexPath = IndexPath(row: r, section: sec)
//            }
            self.currentProject = item
            self.photosViewController.projectIndexPath = self.projectIndexPath
            print("THE NEW AND IMPROVED INDEX PATH  ***************** \(self.projectIndexPath)")
            self.photosViewController.project = self.currentProject
            print("\(item) this is the project as item")
            self.photosViewController.bike = self.bike
            self.photosViewController.bikes = self.bikes
            self.photosViewController.delegate = self
            
            self.photosViewController.projectImages = []
            self.photosViewController.collectionView?.reloadData()
            
            self.saveBikes()
            
            self.navigationController?.pushViewController(self.photosViewController, animated: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func addProjectViewController(_ controller: AddProjectViewController, didFinishEditing item: FB_ProjectItem) {
            print("DID FINISH EDITING *************************** \(self.projectIndexPath)")
//        self.tableSection = self.dict[self.sortedSections[(self.projectIndexPath?.section)!]]!
//        print("TABLE SECTION \(tableSection)")
//        print("ITEM \(item)")
//        self.tableSection[(projectIndexPath?.row)!] = item
        
       // bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = item
        //projects = bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects
        //bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike

        saveBikes()
//        tableView.setEditing(false, animated: true)
//
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
       
        dismiss(animated: true, completion: nil)
    }
    
    func addProjectViewController(_ controller: AddProjectViewController, didFinishAddingAfterYes item: FB_ProjectItem) {
        //        print("DID FINISH ADDING AFTER YES ----------------->>>>>>>>")
        self.tableView.setEditing(false, animated: true)
        
        // self.bikes = BikeData.sharedInstance.allBikes
        DispatchQueue.main.async {
            self.getProjects()
           
        }
        
        DispatchQueue.main.async {
             self.setupTitleValues()
            
            let indexOfSection = self.sortedSections.firstIndex(of: item.category!)
            
            print("DAMMIT give me the idex \(indexOfSection)")
            
            print(self.dict)
            
            let arr = self.dict[item.category!]
            
            let indexOfRow = arr?.firstIndex(where: { $0.uniqueID == item.uniqueID! })
            self.projectIndexPath = IndexPath(row: indexOfRow!, section: indexOfSection!)
            //from HERE
            //  self.setupTitleValues()
//            let sec:Int = 0
//            let r:Int = 0
//            //            let c:Int = (self.projects?.count)!
//            let nSections = self.tableView.numberOfSections
//            for j in 0 ..< nSections {
//                if nSections == nil {
//                    self.projectIndexPath = [0, 0]
//                }
//                let nRows = self.tableView.numberOfRows(inSection: j)
//
//                for i in 0 ..< nRows {
//                    var indexPath = IndexPath(row: i, section: j)
//                    //                    print("printed index path \(indexPath)")
//                }
//            }
//            self.projectIndexPath = IndexPath(row: r, section: sec)
        }
        //            To HERE
        
        DispatchQueue.main.async {
            self.currentProject = item
            self.photosViewController.projectIndexPath = self.projectIndexPath
            //            print("THE NEW AND IMPROVED INDEX PATH \(self.projectIndexPath)")
            self.photosViewController.project = self.currentProject
            //            print("\(item) this is the project as item")
            self.photosViewController.bike = BikeData.sharedInstance.bike
            self.photosViewController.bikes = BikeData.sharedInstance.allBikes
            self.photosViewController.delegate = self
            
            self.photosViewController.projectImages = []
            self.photosViewController.collectionView?.reloadData()
            // self.saveBikes()
            print("this is where updates")
            self.updateBikes()
            
            // self.navigationController?.pushViewController(self.photosViewController, animated: true)
        }
        //dismiss(animated: true, completion: nil)
    }
    
    
    func addProjectViewController(_ controller: AddProjectViewController, didFinishAddingAfterCancel item: FB_ProjectItem) {
        //        print("DID FINISH ADDING AFTER CANCEL ----------------->>>>>>>>")
        self.tableView.setEditing(false, animated: true)
        DispatchQueue.main.async {
            self.getProjects()
        }
        
        DispatchQueue.main.async {
            //from HERE
            //  self.setupTitleValues()
            let sec:Int = 0
            let r:Int = 0
            //            let c:Int = (self.projects?.count)!
            let nSections = self.tableView.numberOfSections
            for j in 0 ..< nSections {
                if nSections == 0 {
                    self.projectIndexPath = [0, 0]
                }
                let nRows = self.tableView.numberOfRows(inSection: j)
                
                for i in 0 ..< nRows {
                    //                    var indexPath = IndexPath(row: i, section: j)
                    //                    print("printed index path \(indexPath)")
                }
            }
            self.projectIndexPath = IndexPath(row: r, section: sec)
        }
        //            To HERE
        DispatchQueue.main.async {
            
            self.currentProject = item
            //probablyl need this below just the one line
           // self.addProjectViewController.projectIndexPath = self.projectIndexPath
            //            print("THE NEW AND IMPROVED INDEX PATH \(self.projectIndexPath)")
            //            self.photosViewController.project = self.currentProject
            //            print("\(item) this is the project as item")
            //            self.photosViewController.bike = self.bike
            //            self.photosViewController.bikes = self.bikes
            //            self.photosViewController.delegate = self
            //
            //            self.photosViewController.projectImages = []
            //            self.photosViewController.collectionView?.reloadData()
            self.updateBikes()
            
            // self.navigationController?.pushViewController(self.photosViewController, animated: true)
        }
        //dismiss(animated: true, completion: nil)
    }
    
    
    
    
    func photosViewController(_ controller: PhotosViewController, didFinishEditing item: FB_ProjectItem) {
        // updateBikes()
        print("\( self.tableSection[(self.projectIndexPath?.row)!] )" == "\(item)")
        print("DID FINISH EDITING IN PHOTOS VIEW CONTROLLER")
        self.tableSection = self.dict[self.sortedSections[(self.projectIndexPath?.section)!]]!
        self.tableSection[(self.projectIndexPath?.row)!] = item
       // bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = item
       // projects = bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects
       // bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
        tableView.setEditing(false, animated: true)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
//        self.setupTitleValues()
        self.projectIndexPath = nil
        dismiss(animated: true, completion: nil)
       // updateBikes()
        saveBikes()
    }
    
    func photosViewController(_ controller: PhotosViewController, didFinishAddingThumbnail item: FB_ProjectItem) {
            print("DID FINISH ADDING THUMBNAIL IN PHOTOS VIEW CONTROLLER")
            print("\(projectIndexPath) is the Project Index Path for the project")

            print("\(self.projectIndexPath ) this is the project index path")
            print(self.projectIndexPath?.row)
            print(bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?.count)
          self.tableSection = self.dict[self.sortedSections[(self.projectIndexPath?.section)!]]!
          self.tableSection[(projectIndexPath?.row)!] = item
            //bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects?[(projectIndexPath?.row)!] = item
     
        item.imagesArray = controller.projectImages
        bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!].projects = self.projects
   
        bikes[(BikeData.sharedInstance.selectedIndexPath?.row)!] = bike
        //tableView.setEditing(false, animated: true)
        //updateBikes()
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//        self.setupTitleValues()
        saveBikes()
        
        //self.projectIndexPath = nil
        photosViewController.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
}

