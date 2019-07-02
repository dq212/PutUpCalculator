//
//  RefreshStockData.swift
//  MotoPreserve-App
//
//  Created by Daniel I Quintero on 11/27/17.
//  Copyright © 2017 DANIEL I QUINTERO. All rights reserved.
//



import UIKit
import FirebaseAuth
import Firebase
import DataCache
import FirebaseDatabase

class RefreshViewController: UIViewController {
    
    var makeArray = [String]()
    var modelArray = [String]()
    var yearArray = [String]()
    var makeModelYearCache:DataCache?
    var isConnected:Bool = false
    var ref: DatabaseReference?
    
    var backBarButton:UIBarButtonItem?
    var bikes = BikeData.sharedInstance.allBikes
    var senderView:UIView?
    
    let refreshView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return view
    }()
    
    let refreshText:UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: "Avenir-Medium", size: 14)
        tv.textAlignment = .left
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.isSelectable = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor(white: 0, alpha: 0.0)
        tv.text = "Touch the Refreh button to update/sync your Stock Data with out database.\n\nDoing this will add New Videos and Bike Model options to your local database.\n\nWe are constantly trying to to make sure you have everything you need to keep everything up to date, accurate, and fresh to keep you moving."
        return tv
    }()
    
    let refreshDataButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 17)
        button.setTitle("Refresh", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainRed()
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancelThisView))
        navigationItem.leftBarButtonItem?.tintColor = .mainRed()
        
        view.backgroundColor = .white
        view.addSubview(refreshView)
        refreshView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        refreshView.addSubview(refreshText)
        refreshText.anchor(top: refreshView.topAnchor, left: refreshView.leftAnchor, bottom: nil, right: refreshView.rightAnchor, paddingTop: 90, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height:0)
        
        refreshView.addSubview(refreshDataButton)
        refreshDataButton.anchor(top: refreshText.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 160, height: 0)
        refreshDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        refreshDataButton.addTarget(self, action: #selector(refreshDataButtonHandler), for: .touchUpInside)
    }
    
    func loadUserBikes() -> [FB_Bike]?  {
        //self.checkCoachMark()
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }
    
    @objc func refreshDataButtonHandler() {
        
        
        checkConnectionForRefresh(vc: self, bikes: BikeData.sharedInstance.allBikes)
    }
    
    @objc func cancelThisView() {
        //self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    //
    
    func checkConnectionForRefresh(vc:UIViewController, bikes:[FB_Bike]?) {
        let msg:String = "Refresh"
        //let userLastOnlineRef = FIRDatabase.database().reference(withPath: "users/\(uid)/lastOnline")
        //userLastOnlineRef.onDisconnectSetValue(FIRServerValue.timestamp())
        //print("last time online \(userLastOnlineRef.onDisconnectSetValue(FIRServerValue.timestamp()))")
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
//                print("Is Connected")
                self.isConnected = true
                 self.getMakes()
            } else {
//                print("Not Connected")
                self.isConnected = false
            }
            if (!self.isConnected) {
                let alert = UIAlertController(title: "Check your connection.", message: "Please make sure you are connected to avoid any interuption.", preferredStyle: .alert)
                alert.view.tintColor = UIColor.mainRed()
                alert.addAction(UIAlertAction(title: "I am connected. \(msg) now", style: .default, handler: {(alertAction) in
                    self.getMakes()

                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                // vc.present(alert, animated: true, completion:nil)
            }
        })
    }
    //
    
    func getYearForModel(mk: String, mdl:String) {
        if isConnected == true {
            ref?.child("bikes").child(mk).child(mdl).queryOrderedByKey().observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dictionary = snapshot.value as? NSDictionary else {return}
                //print(dictionary)
                let sortedKeys = (dictionary.allKeys as! [String]).sorted(by: <)
                self.yearArray = sortedKeys
                
                self.makeModelYearCache?.write(object: self.yearArray as NSCoding, forKey: "years")
            })
        } else {
//            print("we have no connection, now we need to parse the json object for the year")
            self.yearArray = self.makeModelYearCache?.readObject(forKey: "years") as! [String]
        }
    }
    
    func getModelsForMake(mk:String) {
        if isConnected == true {
            ref?.child("bikes").child(mk).queryOrderedByKey().observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dictionary = snapshot.value as? NSDictionary else {return}
                let sortedKeys = (dictionary.allKeys as! [String]).sorted(by: <)
                self.modelArray = sortedKeys
                self.makeModelYearCache?.write(object: self.modelArray as NSCoding, forKey: "models")
            })
        } else {
//            print("we have no connection, now we need to parse the json for the models")
            self.modelArray = self.makeModelYearCache?.readObject(forKey: "models") as! [String]
        }
    }
    
    func getMakes() {
//        print("\(isConnected) check the connection again inside of getMakes")
        if isConnected == true {
            self.makeArray = [" "]
            self.modelArray = [" "]
            self.yearArray = [" "]
            ref = Database.database().reference()
            ref?.child("make").queryOrderedByKey().observeSingleEvent(of: .value, with: {
                (snapshot) in
                
                guard let mk = snapshot.value as? NSArray else {return}
                for i in 0..<mk.count {
                    self.makeArray.append((mk[i] as AnyObject).value(forKey:"make") as! String)
                }
                
                self.makeArray.sort { $0 < $1 }
                self.makeModelYearCache?.write(object: mk as NSCoding, forKey: "makes")
                showRefreshSuccessAnimation(vc:self)

            })
        }
    }
    //
}

