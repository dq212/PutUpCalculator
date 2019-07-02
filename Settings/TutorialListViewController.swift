//
//  TutorialListViewController.swift
//  MotoPreserve-App
//
//  Created by Daniel I Quintero on 11/25/17.
//  Copyright © 2017 DANIEL I QUINTERO. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class TutorialListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    let cellId = "cellId"
    
    var delegate: UIViewController?
    var titleBar = TitleBar()
    
    var ref:DatabaseReference?
    var keyArray = [String]()
    var valueArray = [String]()
    
    var sortedSections = [String]()
    var tableSection = [FB_Video]()
    var categoryArray = [String]()
    var videoTextArray = [[FB_Video]]()
    var dict = [String:[FB_Video]]()
    
    var videos = [FB_Video]()
    
     var isConnected:Bool?
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(true)
        keyArray = []
        valueArray = []
        videos = []
      sortedSections = []
      tableSection = []
      categoryArray = []
      videoTextArray = []
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        keyArray = []
        valueArray = []
        sortedSections = []
        tableSection = []
        categoryArray = []
        videoTextArray = []
         self.videos = []
        checkConnection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        self.delegate = self
        tableView.separatorStyle = .none
        //tableView.separatorColor = UIColor.tableHeaderBG()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TutorialListCell.self, forCellReuseIdentifier: cellId)
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor.tableViewBgGray()
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        tableView.anchor(top: view.topAnchor , left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: topBarHeight+25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
      
        
        titleBar.addTitleBarAndLabel(page: view, initialTitle: "VIDEOS", ypos: topBarHeight)
        

        //getVideos()
        
    }
    
    func setupTitleValues() {
        self.categoryArray = []
        self.videoTextArray = []
        self.dict = [:]
        self.sortedSections = []
        self.tableSection = []
        
            for item in videos {
                self.categoryArray.append(item.category!)
            }
            let mySet = Set<String>(categoryArray)
            categoryArray = Array(mySet)
            categoryArray.sort{$0 < $1}
        
        self.videoTextArray = Array(repeating: [FB_Video]() , count: categoryArray.count )
       
            for i in 0..<videos.count {
                for k in 0..<categoryArray.count {
                    if videos[i].category == categoryArray[k] {
                        videoTextArray[k].append(videos[i])
                    }
                }
                //making the dictionary here
                for (index, element) in categoryArray.enumerated()
                {
                    self.dict[element] = videoTextArray[index]
                }
                self.sortedSections = categoryArray
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.white
        }
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Avenir-Medium", size: 12)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        headerView.backgroundColor = .tableHeaderBGLight()
        header.backgroundView = headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
       
            return UITableView.automaticDimension
     
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("count from tableView \(bikes.count)")
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        configure(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableSection = self.dict[self.sortedSections[indexPath.section]]!
        let vid = self.tableSection[indexPath.row]
        
//        print("!!!!!!!!!!!!!!! \(vid.videoUrl)")
       
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        
        let controller = VideoPlayerViewController()
        controller.url = vid.videoUrl
        present(controller, animated: false, completion: nil)

        //self.present(controller, animated:true, completion:nil)
    }
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? TutorialListCell else {
            return
        }
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = bgColorView
        
        tableSection = dict[sortedSections[indexPath.section]]!
        let videoItem = tableSection[indexPath.row]
        cell.titleLabel.text = videoItem.title
        cell.descLabel.text = videoItem.desc
        
        let iconImageView = cell.thumbNailImageView as UIImageView
        
                    if videoItem.thumbUrl != nil {
                        cell.thumbNailImageView.loadImage(urlString: videoItem.thumbUrl!)
                    } else {
                        iconImageView.image = #imageLiteral(resourceName: "bikeThumbNail")
                    }
        }
        
        
//        if videos != nil {
//            let video = self.videos![indexPath.row]
//            cell.titleLabel.text = video.title
//            cell.descLabel.text = video.desc
//
//            let iconImageView = cell.thumbNailImageView as UIImageView
//
//            if video.thumbUrl != nil {
//                cell.thumbNailImageView.loadImage(urlString: video.thumbUrl!)
//            } else {
//                iconImageView.image = #imageLiteral(resourceName: "bikeThumbNail")
//            }
//        }

    
    func getVideos() {
        self.videos = []
                let videosRef = Database.database().reference().child("videos")
                videosRef.queryOrdered(byChild: "title").observe(.childAdded, with: { (snapshot) in
                    if let videoDictionary = snapshot.value as? [String: Any] {
                        let title = videoDictionary["title"] as? String
                        let category = videoDictionary["category"] as? String
                        let desc = videoDictionary["desc"] as? String
                        let thumbUrl = videoDictionary["thumbUrl"] as? String
                        let videoUrl = videoDictionary["videoUrl"] as? String
                        
                        let video = FB_Video(title: title!, category: category, thumbUrl: thumbUrl, videoUrl: videoUrl, desc: desc)
                            self.videos.append(video!)
                            self.setupTitleValues()
                    }
                        self.tableView.reloadData()
            
                }, withCancel: nil)
        }
    
    func checkConnection() {
        //        let userLastOnlineRef = FIRDatabase.database().reference(withPath: "users/\(uid)/lastOnline")
        //        userLastOnlineRef.onDisconnectSetValue(FIRServerValue.timestamp())
        //        print("last time online \(userLastOnlineRef.onDisconnectSetValue(FIRServerValue.timestamp()))")
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
                self.isConnected = true
                self.getVideos()
                // Load any saved meals, otherwise load sample data.
            } else {
                print("Not Connected")
                self.isConnected = false
                self.showAlert()
            }
        })
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Check your connection.", message: "You must be connected to the internet to view videos.", preferredStyle: .alert)
        alert.view.tintColor = UIColor.mainRed()
        alert.addAction(UIAlertAction(title: "I am connected.Try again.", style: .default, handler: {(alertAction) in
            self.getVideos()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
    }
    
}
