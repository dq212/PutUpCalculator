//
//  PostImage.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 6/8/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import Foundation
//import DataCache

class PostImage:NSObject, NSCoding {
    var uniqueID:String?
    let imageName:String
    var checked:Bool? = false
    var timestamp:NSNumber?
    //var imagesCache:DataCache?
    
    //MARK: Types
    
    struct PropertyKey {
        static let uniqueID = "uniqueID"
        static let imageName = "imageName"
        static let timestamp = "dateEntered"
        static let checked = "checked"
    }
    init?(imageName:String, uniqueID:String?, timestamp:NSNumber?, checked:Bool? ) {
//        self.uniqueID = dictionary["uniqueID"] as? String ?? ""
//        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
//        self.imageName = dictionary["imageName"] as? String ?? ""
//        self.dateEntered = dictionary["dateEntered"] as? Date
        
        // The name must not be empty
        guard !imageName.isEmpty else {
            return nil
        }
        self.imageName = imageName
        self.uniqueID = uniqueID
        self.timestamp = timestamp
        self.checked = checked
        
       // print("\(imageName) from inside the post object")
    }
    
    func toggleChecked() {
        checked = !checked!
        //print("toggled from item \(checked)")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uniqueID, forKey: PropertyKey.uniqueID)
        aCoder.encode(imageName, forKey: PropertyKey.imageName)
        aCoder.encode(timestamp, forKey: PropertyKey.timestamp)
        aCoder.encode(checked, forKey: PropertyKey.checked)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let imageName = aDecoder.decodeObject(forKey: PropertyKey.imageName) as? String else {
            //print("Unable to decode the text for a Item object.")
            //os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let uniqueID = aDecoder.decodeObject(forKey: PropertyKey.uniqueID) as? String
        let timestamp = aDecoder.decodeObject(forKey: PropertyKey.timestamp) as? NSNumber
        let checked = aDecoder.decodeObject(forKey: PropertyKey.checked) as? Bool
        
        // Must call designated initializer.
        self.init(imageName:imageName, uniqueID:uniqueID, timestamp:timestamp, checked:checked)
    }

    
}
