//
//  Functions.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 1/27/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import Foundation
import UIKit
import Dispatch
import Photos
import Firebase
import DataCache


func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}

var unique_merged:[FB_Bike] = []
var p:[FB_ProjectItem]?
var t:[FB_MaintenanceItem]?

var ub:DatabaseReference?




var bikes:[FB_Bike] = []

let applicationDocumentsDirectory: URL = {
//    print("HERE IS MY PATH:")
    let filepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    print("PATH IS:\(paths)")
    return paths[0]
}()

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(rawValue: "MyManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}

func registerDefaults() {
    let dictionary: [String: Any] = [ "PhotoID": 0, "ProjectPhotoID": 0 ]
    UserDefaults.standard.register(defaults: dictionary)
}


//----------CHECK CONNECTION---------->>>
func checkConnectionForBackup(vc:UIViewController, bikes:[FB_Bike]?,  msg_string:String) {
    var isConnected:Bool?
    let msg = msg_string
    
    print("THIS IS THE MESSAGE STRING \(msg)")
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                    print("Is Connected")
               isConnected = true
            } else {
                    print("Not Connected")
                isConnected = false
            }
            if (!isConnected!) {
                let alert = UIAlertController(title: "Check your connection.", message: "Please make sure you are connected to avoid any interuption.", preferredStyle: .alert)
                alert.view.tintColor = UIColor.mainRed()
                alert.addAction(UIAlertAction(title: "I am connected. \(msg) now", style: .default, handler: {(alertAction) in
                    if (msg == "Backup") {
                        if bikes != nil {

                            doDataBackup(vc: vc, bikes: BikeData.sharedInstance.allBikes)
                        } else {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    } else if (msg == "Restore"){
                        if bikes != nil {
                           // doRestoreData(view: vc, tempBikes: BikeData.sharedInstance.allBikes)
                        } else {
                            alert.dismiss(animated: true, completion: nil)
                        }
//                        if let bikes = bikes {
//                            doRestoreData(view: vc, tempBikes: bikes)
//                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                vc.present(alert, animated: true, completion:nil)
                print("Not connected in Functions")
            } else {
                if (msg == "Backup"){
                    if bikes != nil {
                        //print("\(BikeData.sharedInstance.allBikes[0].projects?.count) COUNTING PROJECTS THAT EXIST LOCALLY - backup")

                        //was bikes!
                    doDataBackup(vc:vc, bikes:BikeData.sharedInstance.allBikes)
                    print("There are ...\(BikeData.sharedInstance.allBikes.count) bikes")
                    print("we are connected, so do backup")
                    }
                }
                else if  (msg == "Restore") {
                    if bikes != nil {
//                    print("\(BikeData.sharedInstance.allBikes[0].projects?.count) COUNTING PROJECTS THAT EXIST LOCALLY - restore")
                        
                // put popup here
                        let alert = UIAlertController(title: "Are you sure you want to RESTORE?", message: "RESTORE will retrieve the latest backup ONLY.\nAny new entries since your last backup will be lost.\nPlease hit cancel and contact us if you have any questions.", preferredStyle: .alert)
                        //alert.view.tintColor = UIColor.mainRed()
                        alert.addAction(UIAlertAction(title: "All good, let's Restore", style: .destructive, handler: {(alertAction) in
                           
                            doRestoreData(view: vc, tempBikes: BikeData.sharedInstance.allBikes)
                            alert.dismiss(animated: true, completion: nil)
                            
                            
                        }))
                         alert.view.tintColor = UIColor.black
                        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction) in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        
                        vc.present(alert, animated: true, completion:nil)
                        
                   // doRestoreData(view: vc, tempBikes: BikeData.sharedInstance.allBikes)
                    print("we are connected, so do restore")
                    }
                }
            }
        })
    }

func doDataBackup(vc:UIViewController, bikes:[FB_Bike]) {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let ref = Database.database().reference(fromURL: "https://motopreserve-ebd6b.firebaseio.com/")
    let bikesRef = ref.child("users").child(uid).child("userBikes")
    bikesRef.removeValue { (error, refer) in
        if error != nil {
            print(error ?? "")
        } else {
           
        }
        putBackupItems(vc:vc, backupBikes:bikes, ref:ref)
    }
}

func putBackupItems(vc:UIViewController, backupBikes:[FB_Bike], ref:DatabaseReference) {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
 
   
    for bike in backupBikes {
        let bikesRef = ref.child("users").child(uid).child("userBikes").child(bike.uniqueID!)
        let values = ["name": bike.name as Any, "make":bike.make as Any, "model": bike.model as Any, "year":bike.year as Any as Any, "imageName":bike.imageName as Any, "uniqueID":bike.uniqueID as Any, "thumbUrl":bike.thumbUrl as Any, "thumbName":bike.thumbName as Any, "timestamp":bike.timestamp as Any,"currentMileageString":bike.currentMileageString as Any, "currentHoursString":bike.currentHoursString as Any, "selectedValue":bike.selectedValue as Any]
        bikesRef.updateChildValues(values, withCompletionBlock: { (error, bikesRef) in
            if error != nil {
                print(error as Any)
                return
            }
             print("successfully added bikes ****!!!!!!*******")
        })
        
        if (bike.projects != nil ){
            print("GIVE ME THE PROJECTS!!!")
            for project in bike.projects! {
                let projectRef = ref.child("users").child(uid).child("userBikes").child(bike.uniqueID!).child("projects").child(project.uniqueID!)
                let values = ["text": project.text as Any, "category":project.category as Any, "notes": project.notes as Any,"imageUrl":project.imageUrl as Any, "thumbUrl":project.thumbUrl as Any, "uniqueID":project.uniqueID as Any, "thumbName":project.thumbName as Any, "imageName":project.imageName as Any, "timestamp":project.timestamp as Any] as [String: Any]
                projectRef.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error ?? " error loading the projects ")
                        return
                    }
                })
                
                if (project.imagesArray != nil ) {
                    
                    for image in project.imagesArray! {
                       // print("number of images in the array \(project.imagesArray?.count)")
                        let iRef = projectRef.child("images").child(image.uniqueID!)
                        let values = ["uniqueID":image.uniqueID as Any, "imageName":image.imageName ,"checked":image.checked as Any, "timestamp":image.timestamp as Any] as [String : Any]
                        iRef.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                            if error != nil {
                                print(error ?? "")
                                return
                            }
                        })
                    }
               }
            }
        }

             if (bike.maintenance != nil ){
                //print(bike.maintenance as Any)
                for mItem in bike.maintenance! {
                    let maintenanceRef = ref.child("users").child(uid).child("userBikes").child(bike.uniqueID!).child("maintenance").child(mItem.uniqueID!)
                    let values = ["title":mItem.title as Any, "category":mItem.category as Any, "notes": mItem.notes, "uniqueID":(mItem ).uniqueID as Any, "shouldRemind":mItem.shouldRemind as Any, "timestamp":mItem.timestamp as Any,  "reminderNumber":mItem.reminderNumber as Any, "mileageTotal":mItem.mileageTotal as Any, "storedMileageRef":mItem.storedMileageRef as Any , "completedAsString":mItem.completedAtString as Any]
                    maintenanceRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                        //"mileage":mItem.mileage as Any]  as [String : Any]
                        if error != nil {
                            print(error ?? "")
                            return
                        }
                        print("successfully created")
                    })
                }
            }
            //end of main for loop
        }
    showBackupSuccessAnimation(view: vc.view, v: vc)
}


//////
 func doRestoreData(view:UIViewController, tempBikes:[FB_Bike]) {
    print("let's restore that data")
    let vc = view
    _ = tempBikes
    
    bikes = []
    
    DispatchQueue.main.async {

          print("DO THIS FIRST")
 
//    print("\(tempBikes[0].projects?.count) THIS IS THE COUNT FOR THE TEMP BIKES INSIDE RESTORE")
    
    var unique_merged:[FB_Bike] = []
    // for projects
    //for tasks
    
    var bikeTasks:[FB_MaintenanceItem] = []
        
    guard let uid = Auth.auth().currentUser?.uid else {return}
    let ref = Database.database().reference(fromURL: "https://motopreserve-ebd6b.firebaseio.com/")
    var userBikesRef = ref.child("users").child(uid).child("userBikes")
        
    ub = userBikesRef
        
    
    
    userBikesRef.queryOrdered(byChild: "uniqueID").observe(.childAdded, with: { (snapshot) in
        //.observeSingleEvent(of: .childAdded, with: { (snapshot) in
        if let bikeDictionary = snapshot.value as? [String: Any] {
            var bikeProjects:[FB_ProjectItem] = []
            let name = bikeDictionary["name"] as! String
            let make = bikeDictionary["make"] as? String
            let model = bikeDictionary["model"] as? String
            let year = bikeDictionary["year"] as? String
            let bikeTimestamp = bikeDictionary["timestamp"] as? NSNumber
            let bikeUniqueID = bikeDictionary["uniqueID"] as? String
            let bikeThumbUrl = bikeDictionary["thumbUrl"] as? String
            let bikeThumbName = bikeDictionary["thumbName"] as? String
            let maintenanceTasks = bikeDictionary["maintenance"] as? NSDictionary as? [String : Any]
            let projects = bikeDictionary["projects"] as? NSDictionary as? [String : Any]
            let bikeImageName = bikeDictionary["imageName"] as? String
            let bikeImageUrl = bikeDictionary["imageURL"] as? String
            let currentMileageString = bikeDictionary["currentMileageString"] as? String
            let currentHoursString = bikeDictionary["currentHoursString"] as? String
            let selectedValue = bikeDictionary["selectedValue"] as? String
            
            
            if projects != nil {
                
                for dict in (projects)! {
                    var projectImages:[PostImage] = []
                    
                    let dv = dict.value
                    let p_uniqueID = (dv as AnyObject).object(forKey:"uniqueID") as? String
                    let p_text = (dv as AnyObject).object(forKey:"text") as? String
                    let p_category = (dv as AnyObject).object(forKey:"category") as? String
                    let p_notes = (dv as AnyObject).object(forKey:"notes") as? String
                    let p_thumbUrl = (dv as AnyObject).object(forKey:"thumbUrl") as? String
                    let p_imageUrl = (dv as AnyObject).object(forKey:"imageUrl") as? String
                    let p_thumbName = (dv as AnyObject).object(forKey:"thumbName") as? String
                    let p_imageName = (dv as AnyObject).object(forKey:"imageName") as? String
                    let p_timestamp = (dv as AnyObject).object(forKey:"timestamp") as? NSNumber
                    let p_images = (dv as AnyObject).object(forKey:"images") as? NSDictionary as? [String: Any]
                    
//                    print("PROJECTS \(projects?.count)")
//                    print("TASKS \(maintenanceTasks?.count)")
//                    print("IMAGES \(projectImages.count)")
//
                    if p_images != nil {
                                                    print("\(p_images?.count) the dictionary of images")
                        for pict in p_images! {
                            let pv = pict.value
                            let i_checked = (pv as AnyObject).object(forKey:"checked") as? Bool
                            let i_name = (pv as AnyObject).object(forKey:"imageName") as? String
                            let i_timestamp = (pv as AnyObject).object(forKey:"timestamp") as? NSNumber
                            let i_uniqueID = (pv as AnyObject).object(forKey:"uniqueID") as? String
//                            print("how many images do I have? \(p_images?.count)")
                            
                          
                            let post = PostImage(imageName: i_name!, uniqueID: i_uniqueID, timestamp: i_timestamp, checked: i_checked)
                            projectImages.append(post!)
                        }
                    }
                    
                    let project = FB_ProjectItem(text: p_text!, uniqueID: p_uniqueID, category: p_category, thumbUrl: p_thumbUrl, imageUrl: p_imageUrl, notes: p_notes, bike: nil, thumbName: p_thumbName, imageName: p_imageName, imagesArray:projectImages, timestamp:p_timestamp)
                    bikeProjects.append(project!)
                }
            }
            print("-------------------------------------------")
            if maintenanceTasks != nil {
                for d in (maintenanceTasks)! {
                    let dv = d.value
                    let m_title = (dv as AnyObject).object(forKey:"title") as? String
                    let m_uniqueID = (dv as AnyObject).object(forKey:"uniqueID") as? String
                    let m_category = (dv as AnyObject).object(forKey:"category") as? String
                    let m_notes = (dv as AnyObject).object(forKey:"notes") as? String
                    let m_shouldRemind = (dv as AnyObject).object(forKey:"shouldRemind") as? Bool
                    let m_timestamp = (dv as AnyObject).object(forKey:"timestamp") as? NSNumber
                    let m_mileageTotal = (dv as AnyObject).object(forKey:"mileageTotal") as? Int
                    let m_reminderNumber = (dv as AnyObject).object(forKey:"reminderNumber") as? Int
                    let m_storedMileageRef = (dv as AnyObject).object(forKey:"storedMileageRef") as? Int
                    let m_completedAtString = (dv as AnyObject).object(forKey:"completedAtString") as? String
                    
                    let task = FB_MaintenanceItem(title: m_title, uniqueID: m_uniqueID!, category: m_category, timestamp: m_timestamp, notes: m_notes, shouldRemind: m_shouldRemind, bike: nil, reminderNumber: m_reminderNumber, mileageTotal: m_mileageTotal, storedMileageRef: m_storedMileageRef, completedAtString: m_completedAtString)
                    
                    bikeTasks.append(task!)
                    
                }
            }
            
            let bike = FB_Bike(name: name, uniqueID: bikeUniqueID, make: make, model: model, year: year, imageUrl: bikeImageUrl, thumbUrl: bikeThumbUrl, timestamp: bikeTimestamp, maintenance: bikeTasks, projects: bikeProjects, imageName: bikeImageName, thumbName: bikeThumbName, currentMileageString: currentMileageString, currentHoursString: currentHoursString, selectedValue: selectedValue)
            
            bikes.append(bike!)
            print(bikes.count)
            
//            print("\(tempBikes[0].projects?.count) TEMP Projects Count")
            
           let unique_backedup = bikes.filterDuplicates { $1.uniqueID == $0.uniqueID }
          // let unique_backedup = bikes

           // print("\(unique_backedup[0].projects?.count) Restored Projects Count")
            let m = tempBikes + unique_backedup
            
           // print("\(m[0].projects?.count) this the the merged bikes")
            unique_merged = m.filterDuplicates { $1.uniqueID == $0.uniqueID }
          //  print(" m value \(m[0].timestamp)")
//            print(" tempbikes value \(tempBikes[0].timestamp)")
           //unique_merged = m.filterDuplicates { $1.uniqueID == $0.uniqueID && $0.timestamp == $1.timestamp }
            unique_merged = bikes
          
            bikeTasks = []
        }
        
        DispatchQueue.main.async {
            
            ub!.removeAllObservers()
            saveRestoredItems(vc:vc,bikes:unique_merged)
            print("THEN DO THIS")
        }
        
        print("\(unique_merged) this is the two arrays merged")
        
        //        print("\(bikeCount) is the bike count")
        
    }) { (err) in
        print(err)
    }
    }
  
    
    //userBikesRef.removeAllObservers()
    
}





/////

func addProjectImages(project:FB_ProjectItem, bike:FB_Bike) {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    if (project.imagesArray != nil) {
        for image in project.imagesArray! {
            print(image.imageName)
            let ref = Database.database().reference().child("users").child(uid).child("userBikes").child(bike.uniqueID!).child("projects").child(project.uniqueID!).child("images").child(image.uniqueID!)
            let values = ["uniqueID":image.uniqueID as Any, "imageName":image.imageName ,"checked":image.checked as Any, "timestamp":image.timestamp as Any] as [String : Any]
            ref.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error ?? "")
                    return
                }
                print("successfully added projects and images ****!!!!!!*******")
            })
        }
    }
}



    //END PROJECT BLOCK
        func restoreProjectImages(view:UIViewController, bike:FB_Bike, projects:[FB_ProjectItem]) {
            let projects = projects
            guard let uid = Auth.auth().currentUser?.uid else {return}
            var images:[PostImage] = []
            for project in projects {
            
                let iRef = Database.database().reference().child("users").child(uid).child("userBikes").child(bike.uniqueID!).child("projects").child(project.uniqueID!).child("images")
                
                iRef.queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) in
                    if let imagesDictionary = snapshot.value as? [String: Any] {
                        let uniqueID = imagesDictionary["uniqueID"] as? String
                        let imageName = imagesDictionary["imageName"] as? String
                        let checked = imagesDictionary["checked"] as? Bool
                        let timestamp = imagesDictionary["timestamp"] as? NSNumber
                        let post = PostImage(imageName: imageName!, uniqueID: uniqueID, timestamp: timestamp, checked: checked)
                        images.append(post!)
                    }
                    project.imagesArray = images
                  
                }, withCancel: nil)
            }
        }

        func saveRestoredItems(vc:UIViewController, bikes:[FB_Bike]) {
            
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes, toFile: FB_Bike.ArchiveURL.path)
            if isSuccessfulSave {
                BikeData.sharedInstance.allBikes = bikes
                print("\(bikes.count) the ones that were supposedlly saved")
                print("successfully restored")
                    showRefreshSuccessAnimation(vc:vc)
                } else {
                    print("un-successfully restored")
                }
        }

        func showRefreshSuccessAnimation(vc:UIViewController) {
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Data Restore Sucessfull"
                savedLabel.font = UIFont(name: "Avenir-Medium", size: 20)
                savedLabel.numberOfLines = 0
                savedLabel.textColor = .white
                savedLabel.textAlignment = .center
                savedLabel.backgroundColor = UIColor(white:0, alpha:1.0)
                savedLabel.layer.cornerRadius = 5
                savedLabel.layer.masksToBounds = true
                savedLabel.frame = CGRect(x:0, y:0, width:180, height:90)
                
                savedLabel.center = vc.view.center
                vc.view.addSubview(savedLabel)
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                }, completion: { (completed) in
                    //completed
                    UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                    }, completion: { (_) in
                        savedLabel.removeFromSuperview()
                        
                        vc.dismiss(animated: true, completion: nil)
                        //                if isCameraView {
                        //                    view.removeFromSuperview()
                        //                }
                    })
                })
            }
            
        }

func showBackupSuccessAnimation(view:UIView, v:UIViewController) {
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Data Backup Sucessfull"
                savedLabel.font = UIFont(name: "Avenir-Medium", size: 20)
                savedLabel.numberOfLines = 0
                savedLabel.textColor = .white
                savedLabel.textAlignment = .center
                savedLabel.backgroundColor = UIColor(white:0, alpha:1)
                savedLabel.layer.cornerRadius = 5
                savedLabel.layer.masksToBounds = true
                savedLabel.frame = CGRect(x:0, y:0, width:180, height:90)
                
                savedLabel.center = view.center
                view.addSubview(savedLabel)
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                }, completion: { (completed) in
                    //completed
                    UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                    }, completion: { (_) in
                        savedLabel.removeFromSuperview()
                        v.dismiss(animated: true, completion: nil)
        //                if isCameraView {
        //                    view.removeFromSuperview()
        //                }
                    })
                })
            }
        }

        func showSavedSuccessAnimation(view:UIView, isCameraView:Bool = false) {
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Image Saved Sucessfully"
                savedLabel.font = UIFont(name: "Avenir-Medium", size: 20)
                savedLabel.numberOfLines = 0
                savedLabel.textColor = .white
                savedLabel.textAlignment = .center
                savedLabel.backgroundColor = UIColor(white:0, alpha:1)
                savedLabel.frame = CGRect(x:0, y:0, width:180, height:90)
               
                savedLabel.center = view.center
                view.addSubview(savedLabel)
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                }, completion: { (completed) in
                    //completed
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                    }, completion: { (_) in
                            savedLabel.removeFromSuperview()
                        if isCameraView {
                            view.removeFromSuperview()
                        }
                    })
                })
            }
        }


func showLegalAgreementSuccessAnimation(vc:UIViewController, v:UIView) {
    DispatchQueue.main.async {
        let savedLabel = UITextView()
        //savedLabel.text = "Four wheels move the body,\n\ntwo wheels move the soul. \n\n - Anonymous"
        //saveLabel.text = "Most motorcycle problems are caused by the nut that connects the handlebars to the saddle."
         savedLabel.text = "\"A motorcycle functions entirely in accordance with the laws of reason, and a study of the art of motorcycle maintenance is really a miniature study of the art of rationality itself.\"\n\n ― Robert M. Pirsig"
       // savedLabel.text = "Thank you. \n\n \"Projects we have completed demonstrate what we know - future projects decide what we will learn.\"\n\n – Dr Mohsin Tiwana"
        savedLabel.font = UIFont(name: "Avenir-Medium", size: 20)
        //savedLabel.numberOfLines = 0
        savedLabel.textColor = .white
        savedLabel.isEditable = false
        savedLabel.isSelectable = false
        savedLabel.textAlignment = .center
        savedLabel.backgroundColor = UIColor(white:0, alpha:0.9)
        savedLabel.textContainerInset = UIEdgeInsets.init(top: 40, left: 10, bottom: 20, right: 10);
       // savedLabel.backgroundColor = UIColor.mainRed()
        savedLabel.layer.cornerRadius = 5
        savedLabel.layer.masksToBounds = true
        savedLabel.frame = CGRect(x:0, y:0, width:320, height:380)
        
        savedLabel.center = vc.view.center
        vc.view.addSubview(savedLabel)
        
        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: { (completed) in
            //completed
            UIView.animate(withDuration: 0.6, delay: 7.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
                savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                savedLabel.alpha = 0
                v.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                v.alpha = 0
            }, completion: { (_) in
                savedLabel.removeFromSuperview()
                v.removeFromSuperview()
              
                //vc.dismiss(animated: true, completion: nil)
                //                if isCameraView {
                //                    view.removeFromSuperview()
                //                }
            })
        })
    }
}

func showLegalDisgreementSuccessAnimation(vc:UIViewController) {
//    let closeBtn:UIButton = {
//        let button = UIButton()
//        button.setTitle("Close", for: .normal)
//        button.titleLabel?.textColor = .white
//        button.backgroundColor = UIColor.mainRed()
//        return button
//    }()
    
    DispatchQueue.main.async {
        let savedLabel = UITextView()
            savedLabel.text = "Unfortunately each user must accept the Terms & Conditions in order to use the MotoPreserve App.\nWe hope you'll reconsider."
        savedLabel.font = UIFont(name: "Avenir-Medium", size: 20)
       // savedLabel.numberOfLines = 0
        savedLabel.textColor = .white
        savedLabel.textAlignment = .center
        savedLabel.backgroundColor = UIColor(white:0, alpha:0.9)
        savedLabel.layer.cornerRadius = 5
        savedLabel.textContainerInset = UIEdgeInsets.init(top: 40, left: 10, bottom: 20, right: 10);
        savedLabel.layer.masksToBounds = true
        savedLabel.frame = CGRect(x:0, y:0, width:320, height:400)
        
        
   
//        savedLabel.action(savedLabel, action: #selector(didTapDisagreeWindow(_:)), for: .touchUpInside)
        
        savedLabel.center = vc.view.center
        vc.view.addSubview(savedLabel)
        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: { (completed) in
            //completed
            UIView.animate(withDuration: 0.5, delay: 6.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
                savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                savedLabel.alpha = 0
            }, completion: { (_) in
                savedLabel.removeFromSuperview()
                
                
                //vc.dismiss(animated: true, completion: nil)
                //                if isCameraView {
                //                    view.removeFromSuperview()
                //                }
            })
        })
    }
    
}





