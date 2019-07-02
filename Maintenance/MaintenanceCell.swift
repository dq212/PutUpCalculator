//
//  MaintenanceCell.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 2/1/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit

class MaintenanceCell: UITableViewCell {
    

    let maintenanceNotes: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.gray
        //label.keyboardAppearance = .dark
        label.text = ""
        label.backgroundColor = .white
        //todo max character length
       // tf.isScrollEnabled = false
        return label
        
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 14)
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.text = ""
        return label
    }()
    
    let mileageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.text = ""
        return label
    }()
    
    let completedAtLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.text = ""
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 10)
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.text = ""
        return label
    }()
    
    let reminderDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont(name: "Avenir", size: 10)
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.text = ""
        return label
    }()
    
    let overdueLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        label.textColor = UIColor.mainRed()
        label.numberOfLines = 0
        label.text = "OVERDUE"
        return label
    }()
    
    let alarm: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "alarm_clock")
        return iv
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: .default, reuseIdentifier: reuseIdentifier)
        setupLabels()
    }
    

    fileprivate func setupLabels() {
        addSubview(nameLabel)
        addSubview(maintenanceNotes)
        addSubview(divider)
        addSubview(reminderDateLabel)
        addSubview(overdueLabel)
        addSubview(completedAtLabel)
        //addSubview(mileageLabel)
        addSubview(alarm)
        overdueLabel.isHidden = true
        completedAtLabel.isHidden = false
        
        //addSubview(dateLabel)
//        maintenanceNotes.layer.masksToBounds = true
//        maintenanceNotes.frame.width = 100

        nameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 15, paddingBottom: 0, paddingRight: 20, width: 0, height:0)
        maintenanceNotes.anchor(top: nameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 240, height: 0)
        
        alarm.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width:15, height: 15)
        reminderDateLabel.anchor(top: alarm.topAnchor, left: nil, bottom: nil, right: alarm.leftAnchor, paddingTop: 3, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width:0, height: 0)
        completedAtLabel.anchor(top: alarm.topAnchor, left: nil, bottom: nil, right: alarm.leftAnchor, paddingTop: 3, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width:0, height: 0)
        overdueLabel.anchor(top: maintenanceNotes.topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)

       // mileageLabel.anchor(top: maintenanceNotes.topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        //reminderDateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        divider.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 2, width: 0, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

