//
//  ProjectPhotCell.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 6/8/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit

class ProjectPhotoCell: UICollectionViewCell {
        
    let helper = MRPhotosHelper()
    
    var checked:Bool? = false
   
    let photoImageView:CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let selectMarker: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "selected_marker")
        return iv
    }()
    
    var post:PostImage? {
      
        didSet {
            //guard let imageUrl = post?.thumbUrl else {return}
            // guard let thumbName = post?.thumbName else {return}
            guard let imageName = post?.imageName else {return}
            print("\(imageName) imageName from inside the photo cell")
            // photoImageView.loadImage(imageName:imageName, cache: cache)
            //self.photoImageView.loadImage(imageName:identifier, cache: cache)
            //guard let thumbName = bike.thumbName else {return}
            //guard let thumbUrl = bike.thumbUrl else {return}
            //self.photoImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
            //guard let cache = post?.imagesCache else {return}
            if (post?.imageName) != nil {
                helper.retrieveImageWithIdentifer(localIdentifier:imageName, completion: { (image) -> Void in
                    self.photoImageView.image = image
                    //print(imageName)
                })
                }
            }
        }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        addSubview(selectMarker)
        
        selectMarker.isHidden = checked!
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        selectMarker.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 20, height: 20)
    }
    
    func toggleChecked() {
        checked = !checked!
        self.selectMarker.isHidden = checked!
        //print("toggled from item \(checked)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
