//
//  TitleBar.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 6/28/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit

class TitleBar: UIView {
    
    var title:String = ""
    var htl:UILabel?
    var newPage:UIView?
    var headerTitleBar:UIView?
    
    func addTitleBarAndLabel(page:UIView, initialTitle:String, ypos:CGFloat, color:UIColor = .black) -> UIView {
        
        
        
        headerTitleBar = {
            let tb = UIView()
            tb.backgroundColor = color
            return tb
        }()
        self.title = initialTitle
        
      //self.title = title
        
        let headerTitleLabel:UILabel = {
            let label = UILabel()
            //label.textAlignment = .left
            label.font = UIFont(name: "Avenir-Medium", size: 14)
            label.textColor = UIColor.white
            label.numberOfLines = 0
            //label.text = self.title
            return label
        }()
        
        htl = headerTitleLabel
        
        page.addSubview(headerTitleBar!)
        updateTitle(newTitle: title)
        headerTitleBar?.insertSubview(headerTitleLabel, at: 44)
        headerTitleBar?.anchor(top: page.topAnchor, left: page.leftAnchor, bottom: nil, right: page.rightAnchor, paddingTop: CGFloat(ypos), paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: page.frame.width, height:25)
        
        headerTitleLabel.anchor(top: headerTitleBar?.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: (headerTitleBar?.frame.width)!, height: 0)
        headerTitleLabel.centerXAnchor.constraint(equalTo: page.centerXAnchor).isActive = true
        headerTitleLabel.centerYAnchor.constraint(equalTo: (headerTitleBar?.centerYAnchor)!).isActive = true
        newPage = page
        return newPage!
    }
    
    func updateTitle(newTitle:String) {
        self.htl?.text = newTitle
    }
    

    
}
