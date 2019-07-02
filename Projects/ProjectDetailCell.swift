//
//  ProjectDetailCell.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 3/6/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
//import DataCache

class ProjectDetailCell: UICollectionViewCell, UIScrollViewDelegate {
    
    //var imagesCache:DataCache?
    
    var post:PostImage? {
        didSet {
            guard (post?.imageName) != nil else {return}
            scrollView.delegate = self
            guard post != nil else {return}
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
            //viewForZooming(in: scrollView)
        }
    }
    
    let scrollView: UIScrollView = {
        let iv = UIScrollView()
        return iv
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        addSubview(scrollView)
        scrollView.addSubview(photoImageView)
        
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        //photoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        scrollView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        scrollView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        //scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
}
