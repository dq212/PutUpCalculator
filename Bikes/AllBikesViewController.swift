//
//  AllBikesViewController.swift
//  MP
//
//  Created by DANIEL I QUINTERO on 12/24/16.
//  Copyright © 2016 DanielIQuintero. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import Foundation
import MessageUI
import AVFoundation
import AVKit
import DataCache

class AllBikesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BikeDetailViewControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, UITabBarControllerDelegate, MileageViewControllerDelegate, UIScrollViewDelegate {
    
    var tableView: UITableView!
    var addBikeButton: UIBarButtonItem!
    let cellId = "cellId"
    
    var c:UITableViewCell?
    
    let userCache = DataCache(name: "userCache")
    let makeModelYearCache = DataCache(name: "makeModelYearCache")
    let userBikesCache = DataCache(name: "userBikesCache")
    
    var selectedIndexPath:IndexPath?
    var titleBar = TitleBar()
    
    var currentBike: FB_Bike?
    var bike:FB_Bike?
    var bikes:[FB_Bike] = BikeData.sharedInstance.allBikes
    var bikeName = ""
    var uid:String?
    var bikeDictionary:[String: AnyObject] = [:]
    var makeDictionary:[String: AnyObject] = [:]
    var coachTipView:UIView?
    var maintenanceItems: [FB_MaintenanceItem] = []
    var currentMaintenanceItem:FB_MaintenanceItem?
    var maintenanceDictionary:[String: AnyObject] = [:]
    
    var coachMark:UIView?
    var coachMarkText:String?
    var localUID:String?
    
    var player:AVPlayer?
    var playerController = AVPlayerViewController()
    
    var path:String?
    
    var isConnected:Bool = false
    
    let videoView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()
    
    let scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddBike))
        
        //Mark: load any user bikes
        //view.backgroundColor = UIColor.tableViewBgGray()

        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BikeCell.self, forCellReuseIdentifier: cellId)
        view.addSubview(tableView)
      //  tableView.backgroundColor = UIColor.tableViewBgGray()
        tableView.setContentOffset(CGPoint.zero, animated: true)
    
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        titleBar.addTitleBarAndLabel(page: view, initialTitle: "GARAGE", ypos: 0, color:.black)
        
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let cm:UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0, alpha: 0.8)
            return view
        }()
        
        let cmBg:UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            view.layer.borderWidth = 2.0
            view.layer.borderColor =   UIColor.mainRed().cgColor
            view.layer.cornerRadius = 10
            return view
        }()
        
        
//        let cmImg:UIImageView = {
//            let iv = UIImageView(image:#imageLiteral(resourceName: "cm_bikes"))
//            iv.contentMode = .scaleAspectFit
//            return iv
//
//        }()
        
        let cmText:UITextView = {
            let tv = UITextView()
            tv.font = UIFont(name: "Avenir-Medium", size: 16)
            tv.textColor = UIColor.black
            tv.isEditable = false
            tv.isSelectable = false
            tv.text = "Welcome to the GARAGE, where you'll be storing your BIKE(S).\n\nTouch the “+” button on the upper right to add a new BIKE.\n\nEnter a title, select a Make, Model, Year, and add a Thumbnail.\n\nIf your BIKE is not listed please select “Other”.\n\nSwipe left to edit from within the GARAGE list.\n\n"
            return tv
        }()
        
        let cmEmailButton:UIButton = {
            let button = UIButton(type: .system)
                button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
                button.setTitle("E-mail Us", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .mainRed()
                button.layer.cornerRadius = 5
            return button
        }()
        
        let cmArrowImage:UIImageView = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "curve_sign_small"))
            return iv
        }()
        
       // cmEmailButton.addTarget(self, action: #selector(emailButtonHandler), for: .touchUpInside)
        
        adjustUITextViewHeight(arg: cmText)
        
        view.addSubview(scrollView)
        scrollView.addSubview(cm)
        
        cm.addSubview(cmBg)
       // cm.addSubview(cmImg)
        cmBg.addSubview(cmText)
        
        let textHeightOffset = (cmText.frame.height + view.frame.height) - view.frame.height
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cm.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop:0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height + textHeightOffset )
       // cm.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        // cmImg.anchor(top: cm.topAnchor, left: cm.leftAnchor, bottom: cm.bottomAnchor, right: cm.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height:0)
        cm.addSubview(cmArrowImage)
        cmArrowImage.anchor(top: cm.topAnchor, left: nil, bottom: nil, right: cm.rightAnchor, paddingTop: 35, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
       // cmBg.anchor(top: cmArrowImage.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 190, paddingRight: 10, width: 0, height: 0)
        cmBg.anchor(top: cmArrowImage.bottomAnchor, left: cm.leftAnchor, bottom: nil, right: cm.rightAnchor, paddingTop:10, paddingLeft: 10, paddingBottom:20, paddingRight: 10, width: 0, height: 0)
        
        cmText.anchor(top: cmBg.topAnchor, left: cmBg.leftAnchor, bottom: cmBg.bottomAnchor, right: cmBg.rightAnchor, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        
        let fixedWidth = cmText.frame.size.width
        let newSize = cmText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        cmText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height + 10)
        
       // cm.addSubview(cmEmailButton)
        
       // cmBg.dropShadow()
        
        //cmEmailButton.anchor(top: cmText.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 0)
        //cmEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        self.coachMark = scrollView
        coachMark?.isHidden = false
        
        //show if not logged in
        if Auth.auth().currentUser == nil {
                DispatchQueue.main.async {
                    let loginController = LoginViewController()
                    let navigationController = UINavigationController(rootViewController: loginController)
                    self.present(navigationController, animated: true, completion: nil)
                }
            return
        }
        
        navigationController?.navigationBar.isTranslucent = false
        let newNavItemColor = UIColor(red: 167.0/255, green: 44.0/255, blue: 21.0/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = newNavItemColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.selected)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControl.State.highlighted)
        
        

        setupLogoutButton()
        
        checkConnection()
        getBikes()
        checkVideo()
        
       
        
    }
    
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }

    
//    //MARK: this is where I check the connection, this is just to establish a cached UID
        func checkConnection() {
    //        let userLastOnlineRef = FIRDatabase.database().reference(withPath: "users/\(uid)/lastOnline")
    //        userLastOnlineRef.onDisconnectSetValue(FIRServerValue.timestamp())
    //        print("last time online \(userLastOnlineRef.onDisconnectSetValue(FIRServerValue.timestamp()))")
            let connectedRef = Database.database().reference(withPath: ".info/connected")
            connectedRef.observe(.value, with: { snapshot in
                if snapshot.value as? Bool ?? false {
                    print("Connected in AllBikes")
                    self.isConnected = true
                    // Load any saved meals, otherwise load sample data.
                } else {
                    print("Not connected")
                    self.isConnected = false
                }
                if(self.isConnected) {
                    if let uid = Auth.auth().currentUser?.uid {
                        self.userCache.write(object: uid as NSCoding, forKey: "uid")
                    }
                }
            })
        }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func checkVideo() {
        if (UserDefaults.standard.bool(forKey: "hasViewedVideo") == false) {
            view.addSubview(videoView)
            videoView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            
            let videoString = Bundle.main.path(forResource: "MP_intro_2", ofType: ".mp4")
            if let url = videoString {
                let videoUrl = NSURL(fileURLWithPath: url)
                self.player = AVPlayer(url: videoUrl as URL)
            
                self.playerController.player = self.player
            }
            
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            self.playerController.showsPlaybackControls = false
            self.present(self.playerController, animated: false, completion: {
                self.playerController.player?.play()
            })
        }
        else {return}
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.playerController.dismiss(animated: true) {
            self.videoView.removeFromSuperview()
            UserDefaults.standard.set(true, forKey: "hasViewedVideo")
        }
    }
            
    func checkCoachMark() {
        if (bikes.count > 0) {
            coachMark?.isHidden = true
        }
    }
        
    @objc func handleAddBike() {
        let addBikeViewController = BikeDetailViewController()
        let navController = UINavigationController(rootViewController: addBikeViewController)
            addBikeViewController.delegate = self
            addBikeViewController.bikes = self.bikes
            BikeData.sharedInstance.allBikes = self.bikes
        self.present(navController, animated: true, completion: nil)
    }
    
    fileprivate func setupLogoutButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
    }
    
    private func getBikes(){
        if let savedBikes = self.loadUserBikes() {
            self.bikes = savedBikes
            BikeData.sharedInstance.allBikes = self.bikes
            print("\(BikeData.sharedInstance.allBikes.count) the bikes count from GET BIKES")
            saveBikes()
        }
    }
    
    private func loadUserBikes() -> [FB_Bike]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }
    
    func updateBikes() {
        bikes = []
        if let savedBikes = loadUserBikes() {
            bikes += savedBikes
            BikeData.sharedInstance.allBikes = self.bikes
            print("\(BikeData.sharedInstance.allBikes.count) the bikes count from UPDATE BIKES")
        }
        saveBikes()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func saveBikes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("successfully saved")
             print("\(BikeData.sharedInstance.allBikes.count) the bikes count from SAVE BIKES Bikes")
            self.checkCoachMark()
        } else {
            print("un-successfully saved")
        }
    }
//    //MARK: this is where the uid is sorted out, then BOTH conditions look to load the bikes from the local data (later, more logice will be added here, to see if we need to compare and sync the data)


    // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            bikes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = .black
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated:true, completion:nil)
                
            } catch let logoutError {
               print(logoutError)
           }
        }))
        alertController.addAction(UIAlertAction(title: "Contact Us", style: .default, handler: { (_) in
            let contactController = ContactViewController()
            let navController = UINavigationController(rootViewController: contactController)
            self.present(navController, animated:true, completion:nil)
        }))
        alertController.addAction(UIAlertAction(title: "General Information", style: .default, handler: { (_) in
            let infoViewController = InfoViewController()
            let navController = UINavigationController(rootViewController: infoViewController)
            self.present(navController, animated:true, completion:nil)
        }))
        alertController.addAction(UIAlertAction(title: "Backup/Restore your Data", style: .default, handler: { (_) in
            let backupController = BackupViewController()
            let navController = UINavigationController(rootViewController: backupController)
            self.present(navController, animated:true, completion:nil)
        }))
        alertController.addAction(UIAlertAction(title: "View Legal", style: .default, handler: { (_) in
            let legalController = LegalViewController()
            let navController = UINavigationController(rootViewController: legalController)
            self.present(navController, animated:true, completion:nil)
        }))
        
//        alertController.addAction(UIAlertAction(title: "Refresh Stock Data", style: .default, handler: { (_) in
//            let refreshController = RefreshViewController()
//            let navController = UINavigationController(rootViewController: refreshController)
//            self.present(navController, animated:true, completion:nil)
//
//
//        }))
        if alertController.title == "Cancel" {
            alertController.view.tintColor = UIColor.mainRed()
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    //This resets the last bike when you come back to the app
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bikes = []
        getBikes()
        
        tableView.setContentOffset(.zero, animated: true)
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.setEditing(false, animated: true)
        getBikes()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
        return 380
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("count from tableView \(bikes.count)")
        return bikes.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        configure(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bike = bikes[indexPath.row]
        self.selectedIndexPath = indexPath
        
        BikeData.sharedInstance.selectedIndexPath = indexPath
        BikeData.sharedInstance.bike = self.currentBike
        let mainTabBarController = MainTabBarController()
        mainTabBarController.delegate = self
        let navigationController = mainTabBarController.viewControllers![0] as! UINavigationController
        let controller = navigationController.topViewController as! ProjectViewController
        controller.bike = bike
        controller.bikes = BikeData.sharedInstance.allBikes
        print("SELECTED INDEX PATH -global- from BIKES TABLE VIEW SELECTION \(BikeData.sharedInstance.selectedIndexPath)")
        present(mainTabBarController, animated: true, completion: nil)
//        navigationController.pushViewController(mainTabBarController, animated: true)
    }
    
    @objc func emailButtonHandler() {
        
        if !MFMailComposeViewController.canSendMail() {
           // print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["info@motopreserve.com"])
        composeVC.setSubject("MotoPreserve User Feedback")
        //composeVC.setMessageBody("Hello from California!", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }

    func deleteBike(indexPath:IndexPath) {
        // Delete the row from the data source
        bikes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        saveBikes()
    }
    

    func mileageViewControllerDidCancel(_ controller: MileageViewController) {
        navigationController?.popViewController(animated: true)
            //dismiss(animated: true, completion: nil)
    }
    
    func mileageViewControllerDidFinishEditing(_ controller: MileageViewController){
        tableView.setEditing(false, animated: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
       navigationController?.popViewController(animated: true)
    }
  
    
    @objc func mileageButtonHandler(_ sender:UIButton!) {
        let buttonRow = sender.tag
        let mileageViewController = MileageViewController()
            mileageViewController.bike = bikes[buttonRow]
            mileageViewController.buttonRow = sender.tag
        //photosViewController.selectedIndexPath = self.selectedIndexPath
        navigationController?.pushViewController(mileageViewController, animated: true)
        mileageViewController.delegate = self as? MileageViewControllerDelegate
               // mileageViewController.project = projectItem
                    mileageViewController.bikes = self.bikes
//                if self.bike != nil {
//                    mileageViewController.bike = bike
//                    mileageViewController.selectedIndexPath = self.selectedIndexPath
//                }
               // self.selectedIndexPath = indexPath
               // mileageViewController.projectIndexPath = indexPath
              //  mileageViewController.projects = self.projects
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let name = self.bikes[indexPath.row].name!
            let deleteMsg = "Are you sure you want \nto delete this bike? \n You cannot undo this action."
            let alert = UIAlertController(title: "Delete \(name)?", message: deleteMsg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
                self.deleteBike(indexPath: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            //print("\(self.bikes[indexPath.row].name) = is the name ")
            let editBikeViewController = BikeDetailViewController()
            let navController = UINavigationController(rootViewController: editBikeViewController)
            editBikeViewController.delegate = self
            editBikeViewController.bikeToEdit = self.bikes[indexPath.row]
            self.present(navController, animated: true, completion: nil)
        }
        let newSwiftColor = UIColor(red: 100.0/255, green: 100.0/255, blue: 100.0/255, alpha: 1)
        edit.backgroundColor = newSwiftColor
        
        return [delete, edit]
    }
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        //print("configure")
        guard let cell = cell as? BikeCell else {
            return
        }
           DispatchQueue.main.async {
                 cell.selectionStyle = .none
            }
        
        //cell.selectionStyle = UITableViewCellSelectionStyle.default
        let bike = bikes[indexPath.row]
        cell.indexPath = indexPath
        cell.makeLabel.text = bike.make
        cell.modelLabel.text = bike.model
        cell.yearLabel.text = bike.year
        cell.titleLabel.text = bike.name
        
        if bike.currentMileageString == "" {
            bike.currentMileageString = "0"
        }
        if bike.currentHoursString == "" {
            bike.currentHoursString = "0"
        }
        if bike.selectedValue == "Miles"  {
            cell.unitsLabel.text = "Mileage: \( bike.currentMileageString!)"
            cell.mileageButton.setTitle("Update Miles", for: .normal)
        } else if bike.selectedValue == "Hours" {
            cell.unitsLabel.text = "Hours: \(bike.currentHoursString!)"
            cell.mileageButton.setTitle("Update Hours", for: .normal)
        } else if bike.selectedValue == "Km" {
            cell.unitsLabel.text = "Km: \(bike.currentMileageString!)"
            cell.mileageButton.setTitle("Update Km", for: .normal)
        }
        self.bike = bike
            cell.bike = bike
            cell.mileageButton.addTarget(self, action: #selector(mileageButtonHandler),  for: .touchUpInside)
            cell.mileageButton.tag = indexPath.row
    DispatchQueue.main.async {
        let iconImageView = cell.thumbNailImageView as UIImageView
      //  iconImageView.layer.borderWidth = 1
       // let newSwiftColor = UIColor(red: 200.0/255, green: 200.0/255, blue: 200.0/255, alpha: 0.8)
       // iconImageView.layer.borderColor = newSwiftColor.cgColor
        //NEW CACHE STUFF
            if bike.imageName != nil {
            let helper = MRPhotosHelper()
            if let identifier = bike.imageName {
                helper.retrieveImageWithIdentifer(localIdentifier: identifier, completion: { (image) -> Void in
                    iconImageView.image = image
                })
            }
        } else {
            iconImageView.image = #imageLiteral(resourceName: "thumb_placeholder_large")
        }
        }
    }
    
    //for the Delegate Protocols
    func bikeDetailViewControllerDidCancel(_ controller: BikeDetailViewController) {
        //tableView.setEditing(false, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func bikeDetailViewController(_ controller: BikeDetailViewController, didFinishAdding bike: FB_Bike) {
        tableView.setEditing(false, animated: true)
        updateBikes()
        checkCoachMark()
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func bikeDetailViewController(_ controller: BikeDetailViewController, didFinishAddingThumbnail bike: FB_Bike) {
        tableView.setEditing(false, animated: true)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    
    func bikeDetailViewController(_ controller: BikeDetailViewController, didFinishEditing bike: FB_Bike) {
        tableView.setEditing(false, animated: true)
        saveBikes()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        dismiss(animated: true, completion: nil)
        }
    
    
    }

