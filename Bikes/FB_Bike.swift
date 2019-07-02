//
//  FB_Bike.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 3/29/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import os.log

class FB_Bike:NSObject, NSCoding {

    //MARK: Properties
    var name: String?
    var uniqueID: String?
    var make: String?
    var model: String?
    var imageUrl:String?
    var thumbUrl: String?
    var year: String?
    var timestamp: NSNumber?
    var maintenance: [FB_MaintenanceItem]?
    var projects: [FB_ProjectItem]?
    var imageName:String?
    var thumbName:String?
    var currentMileageString:String?
    var currentHoursString:String?
    var selectedValue:String?
    
    //MARK: Types
    struct PropertyKey {
        
        static let name = "name"
        static let uniqueID = "uniqueID"
        static let make = "make"
        static let model = "model"
        static let year = "year"
        
        static let imageUrl = "imageUrl"
        static let thumbUrl = "thumbUrl"
      
        static let timestamp = "timestamp"
        static let maintenance = "maintenance"
        static let projects = "projects"
        static let tasks = "tasks"
        static let imageName = "imageName"
        static let thumbName = "thumbName"
        static let currentMileageString = "currentMilegeString"
        static let currentHoursString = "currentHoursString"
        static let selectedValue = "selectedValue"
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("bikes")
    
    //MARK: Initialization
//
    init?(name:String, uniqueID:String?, make:String?, model:String?, year:String?, imageUrl:String?, thumbUrl:String?, timestamp:NSNumber?, maintenance:[FB_MaintenanceItem]?, projects:[FB_ProjectItem]?, imageName:String?, thumbName:String?, currentMileageString:String?, currentHoursString:String?, selectedValue:String?) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            //print("\(name) at least we have a name")
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.uniqueID = uniqueID
        self.make = make
        self.model = model
        self.year = year
        self.imageUrl = imageUrl
        self.thumbUrl = thumbUrl
        self.timestamp = timestamp
        self.maintenance = maintenance
        self.projects = projects
        self.imageName = imageName
        self.thumbName = thumbName
        self.currentMileageString = currentMileageString
        self.currentHoursString = currentHoursString
        self.selectedValue = selectedValue
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(make, forKey: PropertyKey.make)
        aCoder.encode(year, forKey: PropertyKey.year)
        aCoder.encode(model, forKey: PropertyKey.model)
        
        aCoder.encode(uniqueID, forKey: PropertyKey.uniqueID)
        aCoder.encode(imageUrl, forKey: PropertyKey.imageUrl)
        aCoder.encode(thumbUrl, forKey: PropertyKey.thumbUrl)
        
        aCoder.encode(projects, forKey:PropertyKey.projects)
        aCoder.encode(maintenance, forKey: PropertyKey.maintenance)
        
        aCoder.encode(timestamp, forKey: PropertyKey.timestamp)
        aCoder.encode(thumbName, forKey: PropertyKey.thumbName)
        aCoder.encode(imageName, forKey: PropertyKey.imageName)
        aCoder.encode(currentMileageString, forKey: PropertyKey.currentMileageString)
        aCoder.encode(currentHoursString, forKey: PropertyKey.currentHoursString)
        aCoder.encode(selectedValue, forKey: PropertyKey.selectedValue)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a FB_Bike object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because uniqueID is an optional property of Bike, just use conditional cast.
        let uniqueID = aDecoder.decodeObject(forKey: PropertyKey.uniqueID) as? String
        let make = aDecoder.decodeObject(forKey: PropertyKey.make) as? String
        let model = aDecoder.decodeObject(forKey: PropertyKey.model) as? String
        let year = aDecoder.decodeObject(forKey: PropertyKey.year) as? String
        let imageUrl = aDecoder.decodeObject(forKey: PropertyKey.imageUrl) as? String
        let thumbUrl = aDecoder.decodeObject(forKey: PropertyKey.thumbUrl) as? String
        let timestamp = aDecoder.decodeObject(forKey: PropertyKey.timestamp) as? NSNumber
        let maintenance = aDecoder.decodeObject(forKey: PropertyKey.maintenance) as? [FB_MaintenanceItem]
        let projects = aDecoder.decodeObject(forKey: PropertyKey.projects) as? [FB_ProjectItem]
        let imageName = aDecoder.decodeObject(forKey: PropertyKey.imageName) as? String
        let thumbName = aDecoder.decodeObject(forKey: PropertyKey.thumbName) as? String
        let currentMileageString = aDecoder.decodeObject(forKey: PropertyKey.currentMileageString) as? String
        let currentHoursString = aDecoder.decodeObject(forKey: PropertyKey.currentHoursString) as? String
        let selectedValue = aDecoder.decodeObject(forKey: PropertyKey.selectedValue) as? String
        
        self.init(name:name, uniqueID:uniqueID, make:make, model:model, year:year, imageUrl:imageUrl, thumbUrl:thumbUrl, timestamp:timestamp, maintenance:maintenance, projects:projects, imageName:imageName, thumbName:thumbName, currentMileageString:currentMileageString, currentHoursString:currentHoursString, selectedValue:selectedValue)
     
    }
    
  
    
}
