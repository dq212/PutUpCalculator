//
//  FullViewPhotoViewController.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 6/23/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
//import DataCache

class FullViewPhotoViewController: UIViewController, UIScrollViewDelegate {
    
    let scrollView: UIScrollView = {
        let iv = UIScrollView()
        return iv
    }()
    
    //var imagesCache:DataCache?
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFit
        //iv.clipsToBounds = true
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(photoImageView)
       
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        //scrollView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        //scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        photoImageView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    var post:PostImage? {
        didSet {
            guard (post?.imageName) != nil else {return}
            scrollView.delegate = self
            let helper = MRPhotosHelper()
            if let identifier = post?.imageName {
                helper.retrieveImageWithIdentifer(localIdentifier: identifier, completion: { (image) -> Void in
                    self.photoImageView.image = image
                })
            }

            photoImageView.contentMode = .scaleAspectFill
            //photoImageView.clipsToBounds = true
            scrollView.minimumZoomScale = 0.25
            scrollView.maximumZoomScale = 10.0
            scrollView.zoomScale = 0.5
            photoImageView.contentMode = .scaleAspectFit
            
            //viewForZooming(in: scrollView)
            //self.photoImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
        }
    }
    

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }

    
    

}
