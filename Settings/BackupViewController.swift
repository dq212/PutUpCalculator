//
//  BackupViewController.swift
//  MotoPreserve
//
//  Created by DANIEL I QUINTERO on 10/9/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class BackupViewController: UIViewController, UIScrollViewDelegate {
    
    var backBarButton:UIBarButtonItem?
    var bikes = BikeData.sharedInstance.allBikes
    var senderView:UIView?
    
    let backupView:UIView = {
        let view = UIView()
       // view.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return view
    }()
    
    let backupText:UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: "Avenir-Medium", size: 17)
        tv.textAlignment = .left
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.isSelectable = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor(white: 0, alpha: 0.0)
        tv.text = "Back up your data so your hard work is safe for future reference.  Data can be restored in the event of a lost or damaged phone. \n\nImportant things to remember: \n\nData and Photos are backed up differently.  Data backup is performed wirelessly through the MotoPreserve APP.  \n\nPhoto backup is performed via your iCloud or iTunes sync.  \n\nIf you have any backup or restore issues, please shoot us an email so we can help."
        return tv
    }()
    
    let backupDataButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 17)
        button.setTitle("Backup", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 5
        return button
    }()
    let restoreDataButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 17)
        button.setTitle("Restore", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainRed()
        button.layer.cornerRadius = 5
        return button
    }()
    
    let backupPhotosButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 17)
        button.setTitle("Backup your Photos", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainRed()
        button.layer.cornerRadius = 5
        return button
    }()
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.clipsToBounds = true
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancelThisView))
        navigationItem.leftBarButtonItem?.tintColor = .mainRed()
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(backupView)
        backupView.addSubview(backupDataButton)
        backupView.addSubview(restoreDataButton)
        backupText.isEditable = false
        backupText.isSelectable = false
        
        adjustUITextViewHeight(arg: backupText)
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        backupView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height + 120)
        
        backupView.addSubview(backupText)
        backupText.anchor(top: backupView.topAnchor, left: backupView.leftAnchor, bottom: nil, right: backupView.rightAnchor, paddingTop: 25, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height:0)
        
        let fixedWidth = backupText.frame.size.width
        let newSize = backupText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        backupText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        let contentSize = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height + 100)
        backupView.frame.size = contentSize
        
        
        
        backupDataButton.anchor(top: restoreDataButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 160, height: 40)
        backupDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        restoreDataButton.anchor(top: backupText.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 160, height: 40)
        restoreDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        backupDataButton.addTarget(self, action: #selector(backupDataButtonHandler), for: .touchUpInside)
        restoreDataButton.addTarget(self, action: #selector(restoreDataButtonHandler), for: .touchUpInside)
        
        if (bikes.count < 1) {
            backupDataButton.isHidden = true
        } else {
            backupDataButton.isHidden = false
        }
    }
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    
    func loadUserBikes() -> [FB_Bike]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }
    
    @objc func backupDataButtonHandler() {
        checkConnectionForBackup(vc: self, bikes: BikeData.sharedInstance.allBikes,  msg_string: "Backup")
    }
    @objc func restoreDataButtonHandler() {
         self.bikes = []
        checkConnectionForBackup(vc: self, bikes: self.bikes, msg_string: "Restore")
    }
    
    @objc func cancelThisView() {
        dismiss(animated: true, completion: nil)
    }
}
