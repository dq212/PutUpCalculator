//
//  PhotoAlbumHeader.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 4/14/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import Firebase
//import DataCache

protocol PhotoAlbumHeaderDelegate {
    func didSelectionView()
    func didDeleteView()
    func didSelectCameraView()
}

class PhotoAlbumHeader: UICollectionViewCell {
    
    var delegate: PhotoAlbumHeaderDelegate?
    
    var isSelectionView:Bool = false
    
    var titleBar = TitleBar()
   // var imagesCache:DataCache?
    

    
    
    var bike: FB_Bike? {
        didSet {
            guard let bike = bike else {return}
            bikeNameLabel.text = bike.name
            //self.backgroundColor = UIColor.tableViewBgGray()
            self.backgroundColor = UIColor.nearlyBlack()
        }
    }
    
    var project: FB_ProjectItem? {
        didSet {
            guard let project = project else {return}
            guard let projectName = project.text else {return}
            projectLabel.text = projectName
            categoryLabel.text = project.category
            //dateLabel.text = "Start date:\(project.date"
        }
    }
    
    var thumbnailImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "camera_pressed2"), for: .normal)
        button.tintColor = .mainRed()
        button.addTarget(self, action: #selector(handleCameraView), for: .touchUpInside)
        return button
    }()
    
    lazy var emptyView:UIView = {
        let ev = UIView()
        return ev
    }()
    
    let bikeNameLabel: UILabel = {
        let label = UILabel()
       // label.font = UIFont.systemFont(ofSize: 12)
        label.font = UIFont(name: "Avenir-Medium", size: 14)
       // label.textColor = .lightGray
         label.textColor = UIColor.veryLightGray()
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 12)
        //label.textColor = .lightGray
        label.textColor = UIColor.veryLightGray()
        return label
    }()
    
    var tasksLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 14)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Tasks go here."
        return label
    }()
    
    let topDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let middleDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.veryLightGray()
        return view
    }()
    
    let bottomDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var projectLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 17)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .white
        return label
    }()
    var categoryLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 12)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .white
        return label
    
    }()
    
    //Toolbar buttons
    func handleSelectBarButton(sender: UISegmentedControl) {
        toggleSelectionView()
    }
    
    func handleDeleteView() {
        delegate?.didDeleteView()
    }
    
    func handleSelectionView() {
        toggleSelectionView()
        delegate?.didSelectionView()
    }
    
    @objc func handleCameraView() {
        delegate?.didSelectCameraView()
    }
    
    func toggleSelectionView() {
        isSelectionView = !isSelectionView
        }

    
    override init(frame: CGRect) {
        super.init(frame:frame)
        thumbnailImageView.layer.cornerRadius = 30
        addSubview(thumbnailImageView)
        thumbnailImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60 , height: 60 )
        setupListToolbar()
       setupProjectStats()
    }
    
    fileprivate func setupProjectStats() {
        let stackView = UIStackView(arrangedSubviews: [bikeNameLabel, projectLabel, categoryLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.distribution = UIStackView.Distribution(rawValue: Int(1.0))!
        addSubview(stackView)
        
        stackView.anchor(top:thumbnailImageView.topAnchor, left: thumbnailImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    }
    
    fileprivate func setupListToolbar() {
        
        addSubview(self.topDividerView)
        //addSubview(self.bottomDividerView)
        //addSubview(self.middleDividerView)

        self.topDividerView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height:1)
         //self.middleDividerView.anchor(top: topDividerView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        //self.bottomDividerView.anchor(top: topDividerView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 2)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
