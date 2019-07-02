//
//  FB_ProjectItem.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 4/1/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//



import UIKit
import UserNotifications

struct NotesToCategory  {
    let notes:String
    let category:String
}

class FB_MaintenanceItem:NSObject, NSCoding {
    var uniqueID:String?
    var category: String?
    var timestamp:NSNumber?
    var notes:String = "No notes entered."
    var shouldRemind:Bool?
    var bike: FB_Bike?
    var title: String?
    //var reminderDate: NSNumber?
    var reminderNumber: Int?
    var mileageTotal: Int?
    var storedMileageRef: Int?
    var completedAtString: String?
   
    
    //MARK: Types
    
    struct PropertyKey {
        static let uniqueID = "uniqueID"
        static let category = "category"
        static let timestamp = "timestamp"
        static let notes = "notes"
        static let shouldRemind = "shouldRemind"
        static let bike = "bike"
        static let title = "title"
        static let mileageTotal = "mileageTotal"
        static let storedMileageRef = "storedMileageRef"
//        static let reminderDate = "reminderDate"

        static let reminderNumber = "reminderNumber"
        static let completedAtString = "completedAtString"
//
    }
    
    //MARK: Initialization
    init?(title:String?, uniqueID:String,  category:String?, timestamp:NSNumber?, notes:String?, shouldRemind:Bool?, bike:FB_Bike?, reminderNumber:Int?, mileageTotal:Int?, storedMileageRef:Int?, completedAtString:String?) {
        
        //
        // The name must not be empty
        guard !uniqueID.isEmpty else {
            return nil
        }
        // Initialize stored properties.
        self.title = title
        self.uniqueID = uniqueID
        self.category = category
        self.timestamp = timestamp
        self.notes = notes!
        self.shouldRemind = shouldRemind
        self.bike = bike
        self.reminderNumber = reminderNumber
        self.mileageTotal = mileageTotal
        self.storedMileageRef = storedMileageRef
        self.completedAtString = completedAtString
//        self.÷mileage = mileage
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey:PropertyKey.title)
        aCoder.encode(uniqueID, forKey: PropertyKey.uniqueID)
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(timestamp, forKey: PropertyKey.timestamp)
        aCoder.encode(notes, forKey: PropertyKey.notes)
        aCoder.encode(shouldRemind, forKey: PropertyKey.shouldRemind)
        aCoder.encode(bike, forKey: PropertyKey.bike)
        aCoder.encode(reminderNumber, forKey: PropertyKey.reminderNumber)
        aCoder.encode(mileageTotal, forKey: PropertyKey.mileageTotal)
        aCoder.encode(storedMileageRef, forKey: PropertyKey.storedMileageRef)
        aCoder.encode(completedAtString, forKey: PropertyKey.completedAtString)
//        aCoder.encode÷(mileage, forKey: PropertyKey.mileage)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
   
        guard let uniqueID = aDecoder.decodeObject(forKey: PropertyKey.uniqueID) as? String else {
            print("Unable to decode the uniqueID for a Item object.")
            //os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String
       /// let uniqueID = aDecoder.decodeObject(forKey: PropertyKey.uniqueID) as? String
        let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? String
        let timestamp = aDecoder.decodeObject(forKey: PropertyKey.timestamp) as? NSNumber
        let notes = aDecoder.decodeObject(forKey: PropertyKey.notes) as? String
        let shouldRemind = aDecoder.decodeObject(forKey: PropertyKey.shouldRemind) as? Bool
        let bike = aDecoder.decodeObject(forKey: PropertyKey.bike) as? FB_Bike
        let reminderNumber = aDecoder.decodeObject(forKey: PropertyKey.reminderNumber) as? Int
        let mileageTotal = aDecoder.decodeObject(forKey: PropertyKey.mileageTotal) as? Int
        let storedMileageRef = aDecoder.decodeObject(forKey: PropertyKey.storedMileageRef) as? Int
        let completedAtString = aDecoder.decodeObject(forKey: PropertyKey.completedAtString) as? String
//        let mileage = aDecoder.decodeObject(forKey: PropertyKey.mileage) as? String
        
        // Must call designated initializer.
        self.init(title:title, uniqueID:uniqueID, category:category, timestamp:timestamp, notes:notes, shouldRemind:shouldRemind, bike:bike, reminderNumber:reminderNumber, mileageTotal:mileageTotal, storedMileageRef:storedMileageRef, completedAtString:completedAtString)
        
        //
    }
    
   //Notification
    func scheduleNotification(vc:UIViewController, totalNum:Int) {
 
        }

    
 }
