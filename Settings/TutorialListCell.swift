//
//  TutorialListCell.swift
//  MotoPreserve-App
//
//  Created by Daniel I Quintero on 11/25/17.
//  Copyright © 2017 DANIEL I QUINTERO. All rights reserved.
//

import UIKit

class TutorialListCell: UITableViewCell {
    
    let thumbNailImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .black
        iv.contentMode = .scaleAspectFill
        iv.layer.borderColor = UIColor.darkGray.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Medium", size: 16)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.text = ""
        return label
    }()
    
    let descLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.gray
        label.numberOfLines = 2
        label.text = "Description goes here"
        return label
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.tableViewBgGray()
        addSubview(thumbNailImageView)
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(divider)
        thumbNailImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 80, height: 45)
         //thumbNailImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        titleLabel.anchor(top: topAnchor, left: thumbNailImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        //titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        descLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 3, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)

        divider.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
