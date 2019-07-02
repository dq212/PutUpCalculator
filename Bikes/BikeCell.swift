//
//  BikeCell.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 2/6/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit

class BikeCell: UITableViewCell {
    
    var indexPath:IndexPath!
    var bike:FB_Bike!
    
    let thumbNailImageView: CustomImageView = {
        let iv = CustomImageView()
        //iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
       // iv.backgroundColor = .black
       // iv.layer.borderColor = UIColor.lightGray.cgColor
       // iv.layer.borderWidth = 0
        return iv
    }()
    
    // first create UIImageView
    let acc:UIImageView = {
       // let img = UIImageView()
       let img = UIImageView(frame:CGRect(x: 10, y: 10, width: 25, height: 12))
           img.image = #imageLiteral(resourceName: "swipeArrows")
        return img
    }()
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Medium", size: 15)
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        label.text = ""
        return label
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .veryLightGray()
        return view
    }()
    let divider2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.veryLightGray()
        return view
    }()
    let divider3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.veryLightGray()
        return view
    }()
    
    let makeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let modelLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let yearLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let unitsLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
    
        label.text = "Current Mileage"
        return label
    }()
    
    let mileageButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 10)
        button.setTitle("Enter Mileage", for: .normal)
        button.setTitleColor(.white, for: .normal)
//        button.backgroundColor = .lightGray
        button.backgroundColor = UIColor.mainRed()
        
        button.layer.cornerRadius = 2
        return button
    }()
    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubview(thumbNailImageView)
        addSubview(divider)
        addSubview(unitsLabel)
        addSubview(titleLabel)
       // self.accessoryView = acc
        addSubview(divider2)
        addSubview(divider3)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop:15, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width:frame.width, height:20)
        thumbNailImageView.anchor(top: titleLabel.bottomAnchor , left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: (280) )
        setupLabels()
        //divider2.anchor(top: divider.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0.5)
        //thumbNailImageView.contentMode = .scaleAspectFill
        //thumbNailImageView.layer.cornerRadius = (self.frame.width/3.5) / 2
       // thumbNailImageView.clipsToBounds = true
    }
    
    fileprivate func setupLabels() {
//        let stackView = UIStackView(arrangedSubviews: [ makeLabel, modelLabel, yearLabel, unitsLabel])
//        stackView.distribution = .fillEqually
//        stackView.axis = .vertical
//        stackView.alignment = .top
//       // stackView.spacing = 1.0
//        //stackView.distribution = UIStackViewDistribution(rawValue: Int(1.0))!
//        addSubview(stackView)
        addSubview(makeLabel)
        addSubview(modelLabel)
        addSubview(yearLabel)
        addSubview(mileageButton)
     
      
        makeLabel.anchor(top: thumbNailImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop:8, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width:0, height: 0)

        modelLabel.anchor(top: thumbNailImageView.bottomAnchor, left: makeLabel.rightAnchor, bottom: nil, right: nil, paddingTop:8, paddingLeft: 5, paddingBottom: 0, paddingRight: 10, width:0, height: 0)
        yearLabel.anchor(top: thumbNailImageView.bottomAnchor, left: modelLabel.rightAnchor, bottom: nil, right: nil, paddingTop:8, paddingLeft: 5, paddingBottom: 0, paddingRight: 10, width:0, height: 0)
        unitsLabel.anchor(top: makeLabel.bottomAnchor, left:leftAnchor, bottom: nil, right: nil, paddingTop:7, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width:0, height: 0)
        
        divider3.anchor(top:thumbNailImageView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom:-1 , paddingRight: 0, width: 0, height: 0.5)

        divider2.anchor(top:thumbNailImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom:0 , paddingRight: 0, width: 0, height: 0.5)
        
        divider.anchor(top: unitsLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)

            
        

//        stackView.anchor(top: titleLabel.bottomAnchor, left: thumbNailImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 14, paddingBottom: 0, paddingRight: 10, width:130, height: 70)
        //unitsLabel.anchor(top:stackView.bottomAnchor, left: stackView.leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 7, paddingRight: 20, width: 0, height: 20)
        mileageButton.anchor(top: unitsLabel.topAnchor, left:nil, bottom: nil, right: rightAnchor, paddingTop: -4, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 80, height: 18)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

