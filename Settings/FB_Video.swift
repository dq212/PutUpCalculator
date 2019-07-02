//
//  FB_Video.swift
//  MotoPreserve-App
//
//  Created by DANIEL I QUINTERO on 12/5/17.
//  Copyright © 2017 DANIEL I QUINTERO. All rights reserved.
//


import UIKit

class FB_Video:NSObject, NSCoding {
    var title: String?
//    var uniqueID:String?
    var category: String?
    var thumbUrl:String?
    var videoUrl:String?
    var desc:String?
//    var bike: FB_Bike?
//    var timestamp:NSNumber?
    
    //MARK: Types
    
    struct PropertyKey {
        static let title = "title"
//        static let uniqueID = "uniqueID"
        static let category = "category"
        static let thumbUrl = "thumbUrl"
        static let videoUrl = "videoUrl"
        static let desc = "desc"
//        static let bike = "bike"
//        static let timestamp = "timestamp"
    }
    
    //MARK: Initialization
    
    init?(title: String, category:String?, thumbUrl:String?, videoUrl:String?, desc:String?) {
        
        // The name must not be empty
        guard !title.isEmpty else {
            return nil
        }
        // Initialize stored properties.
        self.title = title
//      self.uniqueID = uniqueID
        self.category = category
        self.thumbUrl = thumbUrl
        self.videoUrl = videoUrl
        self.desc = desc
//      self.bike = bike
//        self.timestamp = timestamp
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.title)
//      aCoder.encode(uniqueID, forKey: PropertyKey.uniqueID)
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(thumbUrl, forKey: PropertyKey.thumbUrl)
        aCoder.encode(videoUrl, forKey: PropertyKey.videoUrl)
        aCoder.encode(desc, forKey: PropertyKey.desc)
//      aCoder.encode(bike, forKey: PropertyKey.bike)
//        aCoder.encode(timestamp, forKey: PropertyKey.timestamp)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            print("Unable to decode the text for a Item object.")
            //os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
//      let uniqueID = aDecoder.decodeObject(forKey: PropertyKey.uniqueID) as? String
        let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? String
        let thumbUrl = aDecoder.decodeObject(forKey: PropertyKey.thumbUrl) as? String
        let videoUrl = aDecoder.decodeObject(forKey: PropertyKey.videoUrl) as? String
        let desc = aDecoder.decodeObject(forKey: PropertyKey.desc) as? String
//      let bike = aDecoder.decodeObject(forKey: PropertyKey.bike) as? FB_Bike
//        let timestamp = aDecoder.decodeObject(forKey: PropertyKey.timestamp) as? NSNumber
        
        // Must call designated initializer.
        self.init(title:title, category:category, thumbUrl:thumbUrl, videoUrl:videoUrl, desc:desc)
    }
    
    
    
}




