//
//  Extensions.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 3/30/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import Photos
import Foundation
//import DataCache

//let imagesCache = DataCache(name: "imagesCache")
extension UIApplication {
     func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

public protocol DataConvertible {
    associatedtype Result
    static func convertFromData(data:NSData) -> Result?
}

public protocol DataRepresentable {
    func asData() -> NSData!
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension Array {
    
    func filterDuplicates( includeElement: @escaping (_ lhs:Element, _ rhs:Element) -> Bool) -> [Element]{
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension NSDictionary : DataConvertible, DataRepresentable {
    
    public typealias Result = NSDictionary
    
    public class func convertFromData(data:NSData) -> Result? {
        return NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? NSDictionary
    }
    
    public func asData() -> NSData! {
        return NSKeyedArchiver.archivedData(withRootObject: self) as NSData
    }
    
}


extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}


extension Dictionary {
    init(keys: [Key], values: [Value]) {
        self.init()
        
        for (key, value) in zip(keys, values) {
            self[key] = value
        }
    }
}

extension Array where Element:Equatable {
    
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}


public extension Sequence where Iterator.Element: Hashable {
    var uniqueElements: [Iterator.Element] {
        return Array( Set(self) )
    }
}
public extension Sequence where Iterator.Element: Equatable {
    var uniqueElements: [Iterator.Element] {
        return self.reduce([]){
            uniqueElements, element in
            
            uniqueElements.contains(element)
                ? uniqueElements
                : uniqueElements + [element]
        }
    }
}

extension UIViewController {
    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UIViewController.keyboardWillShowForResizing),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UIViewController.keyboardWillHideForResizing),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShowForResizing(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }
    
    @objc func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }
}

extension UITraitCollection {
    
    var isIpad: Bool {
        return horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var isIphoneLandscape: Bool {
        return verticalSizeClass == .compact
    }
    
    var isIphonePortrait: Bool {
        return horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    var isIphone: Bool {
        return isIphoneLandscape || isIphonePortrait
    }
}



extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat)  -> UIColor   {
       return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static func mainRed() -> UIColor {
        return UIColor.rgb(r: 164, g: 8, b: 0)
    }
    
    static func veryLightGray() -> UIColor {
        return UIColor.rgb(r: 200 , g: 200, b: 200)
    }
    
    static func tvPlaceholderGray() -> UIColor {
        return UIColor.rgb(r: 220 , g: 220, b: 220)
    }
    
    static func tableViewBgGray() -> UIColor {
        return UIColor.rgb(r: 240 , g: 240, b: 240)
    }
    
    static func tableHeaderBG() -> UIColor {
        return UIColor.rgb(r: 75 , g: 75, b: 75)
    }
    
    static func tableHeaderBGLight() -> UIColor {
        return UIColor.rgb(r: 100 , g: 100, b: 100)
    }
    
    
    static func coachTipGray() -> UIColor {
        return UIColor.rgb(r: 100 , g: 100, b: 100)
    }
    
    static func nearlyBlack() -> UIColor {
        return UIColor.rgb(r: 50, g: 50, b: 50)
    }
    
    static func britishGreen() -> UIColor {
        return UIColor.rgb(r: 35, g: 79, b: 3)
    }
    
}

extension UIView {
    
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
            ///CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}


extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right:NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {

        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }

        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

    }
}









////MARK: - Navigation bar height
//extension UINavigationBar {
//    
//    //    var screenWidth: CGFloat {
//    //        if UIInterfaceOrientationIsPortrait() {
//    //            return UIScreen.main.bounds.size.width
//    //        } else {
//    //            return UIScreen.main.bounds.size.height
//    //        }
////    //    }
//    class CustomNavigationBar: UINavigationBar  {
//        override open func sizeThatFits(_ size: CGSize) -> CGSize {
//             print("this does get called")
//            let newSize :CGSize = CGSize(width: UIScreen.main.bounds.size.width, height: 80)
//            return newSize
//        }
//    }
//}
