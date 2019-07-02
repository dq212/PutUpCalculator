//
//  FB_ProjectItem.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 3/31/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit

class FB_ProjectItem:NSObject, NSCoding {
    var text: String?
    var uniqueID:String?
    var category: String?
    var thumbUrl:String?
    var imageUrl:String?
    var imagesArray:[PostImage]?
    var notes: String?
    var bike: FB_Bike?
    var thumbName: String?
    var imageName: String?
    var timestamp:NSNumber?
    
    //MARK: Types
    
    struct PropertyKey {
        static let text = "text"
        static let uniqueID = "uniqueID"
        static let category = "category"
        static let thumbUrl = "thumbUrl"
        static let imageUrl = "imageUrl"
        static let notes = "notes"
        static let bike = "bike"
        static let thumbName = "thumbName"
        static let imageName = "imageName"
        static let imagesArray = "imagesArray"
        static let timestamp = "timestamp"
    }
    
    //MARK: Initialization
    
    init?(text: String, uniqueID:String?, category:String?, thumbUrl:String?, imageUrl:String?, notes:String?, bike:FB_Bike?, thumbName:String?, imageName:String?, imagesArray:[PostImage]?, timestamp:NSNumber?) {
        
        // The name must not be empty
        guard !text.isEmpty else {
            return nil
        }
        // Initialize stored properties.
        self.text = text
        self.uniqueID = uniqueID
        self.category = category
        self.thumbUrl = thumbUrl
        self.imageUrl = imageUrl
        self.notes = notes
        self.bike = bike
        self.thumbName = thumbName
        self.imageName = imageName
        self.imagesArray = imagesArray
        self.timestamp = timestamp
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: PropertyKey.text)
        aCoder.encode(uniqueID, forKey: PropertyKey.uniqueID)
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(thumbUrl, forKey: PropertyKey.thumbUrl)
        aCoder.encode(imageUrl, forKey: PropertyKey.imageUrl)
        aCoder.encode(notes, forKey: PropertyKey.notes)
        aCoder.encode(bike, forKey: PropertyKey.bike)
        aCoder.encode(thumbName, forKey: PropertyKey.thumbName)
        aCoder.encode(imageName, forKey: PropertyKey.imageName)
        aCoder.encode(imagesArray, forKey: PropertyKey.imagesArray)
        aCoder.encode(timestamp, forKey: PropertyKey.timestamp)

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let text = aDecoder.decodeObject(forKey: PropertyKey.text) as? String else {
            print("Unable to decode the text for a Item object.")
            //os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
            let uniqueID = aDecoder.decodeObject(forKey: PropertyKey.uniqueID) as? String
            let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? String
            let thumbUrl = aDecoder.decodeObject(forKey: PropertyKey.thumbUrl) as? String
            let imageUrl = aDecoder.decodeObject(forKey: PropertyKey.imageUrl) as? String
            let notes = aDecoder.decodeObject(forKey: PropertyKey.notes) as? String
            let bike = aDecoder.decodeObject(forKey: PropertyKey.bike) as? FB_Bike
            let thumbName = aDecoder.decodeObject(forKey: PropertyKey.thumbName) as? String
            let imageName = aDecoder.decodeObject(forKey: PropertyKey.imageName) as? String
            let imagesArray = aDecoder.decodeObject(forKey: PropertyKey.imagesArray) as? [PostImage]
            let timestamp = aDecoder.decodeObject(forKey: PropertyKey.timestamp) as? NSNumber

        
        // Must call designated initializer.
        self.init(text:text, uniqueID:uniqueID, category:category, thumbUrl:thumbUrl, imageUrl:imageUrl, notes:notes, bike:bike, thumbName:thumbName, imageName:imageName, imagesArray:imagesArray, timestamp:timestamp)
    }
    
 

}


 
