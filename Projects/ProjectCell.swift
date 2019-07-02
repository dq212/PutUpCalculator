//
//  ProjectCell.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 1/31/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {
    
//    // MARK: - IBOutlets
//    @IBOutlet weak var projectLabel: UILabel!
//   // @IBOutlet weak var scoreLabel: UILabel!
//    @IBOutlet weak var thumbImage: UIImageView!
//    
//    @IBOutlet weak var notesTextView: UITextView!
//    // MARK: - View Life Cycle
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        projectLabel.text = nil
//        notesTextView.text = nil
//        thumbImage.image = nil
//    }
  
    let thumbNailImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFill
       // iv.layer.cornerRadius = (iv.frame.width) / 2
       // iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let projectLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Medium", size: 17)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .veryLightGray()
        return view
    }()
    
    let notesTextView: UITextView = {
        let tv = UITextView()
        tv.textAlignment = .left
        tv.font = UIFont(name: "Avenir", size: 12)
        tv.textColor = UIColor.darkGray
        //tv.numberOfLines = 0
        tv.text = ""
        return tv
    }()
    
    let tasksLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: .default, reuseIdentifier: reuseIdentifier)
        
        addSubview(thumbNailImageView)
        addSubview(divider)
        thumbNailImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 20, paddingBottom: 10, paddingRight: 0, width: 60 , height: 60 )
        
        setupLabels()
        
        divider.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        thumbNailImageView.contentMode = .scaleAspectFill
        thumbNailImageView.layer.cornerRadius = 30
        thumbNailImageView.clipsToBounds = true
    }
    
    fileprivate func setupLabels() {
        let stackView = UIStackView(arrangedSubviews: [projectLabel])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.distribution = UIStackView.Distribution(rawValue: Int(1.0))!
        addSubview(stackView)
        
        stackView.anchor(top: topAnchor, left: thumbNailImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: (frame.height/2) - 5, paddingLeft: 20, paddingBottom: 0, paddingRight: 10, width: 0, height: 40)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}

