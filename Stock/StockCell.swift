//
//  StockCell.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 6/23/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit

class StockCell: UITableViewCell {
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let itemLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Helvetica Bold", size: 14)
        label.textColor = UIColor.black
        label.numberOfLines = 3
        label.text = ""
        return label
    }()
    
    let dataLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Helvetica", size: 14)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 3
        label.text = ""
        return label
    }()

    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setupLabels()
    }
    
    fileprivate func setupLabels() {
        
        addSubview(itemLabel)
        addSubview(divider)
        itemLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(dataLabel)
        dataLabel.anchor(top: topAnchor, left: itemLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        divider.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
//        let stackView = UIStackView(arrangedSubviews: [itemLabel, dataLabel])
//        
//        
//        stackView.distribution = .fill
//        stackView.axis = .horizontal
//        stackView.distribution = UIStackViewDistribution(rawValue: Int(1.0))!
//        addSubview(stackView)
//        
//        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 10, width: 0, height: 25)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


