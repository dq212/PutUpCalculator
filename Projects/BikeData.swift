//
//  CurrentBikeData.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 6/23/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import Foundation
//import DataCache


final class BikeData {
    
    // reachable from other classes
    static let sharedInstance: BikeData = BikeData()
    
    // properties
    var bike : FB_Bike?
    var selectedIndexPath : IndexPath?
    var allBikes : [FB_Bike] = []
 
    // not reachable from other classes
    private init() { }
    
}
