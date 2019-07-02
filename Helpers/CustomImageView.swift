//
//  CustomImageView.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 5/17/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
//import DataCache


var imagePostCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    //var imagesCache:DataCache?
    
func loadImage(urlString: String) {
//    func loadImage(imageName: String, cache:DataCache) {
        print("loading....")
        if let cachedImage = imagePostCache[urlString] {
            self.image = cachedImage
            return
        }

        lastURLUsedToLoadImage = urlString

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print ("Failed to fetch post image: ", err)
                return
            }

            if url.absoluteString != self.lastURLUsedToLoadImage { return }

            guard let imageData = data else {return}

            let photoImage = UIImage(data: imageData)

            imagePostCache[url.absoluteString] = photoImage
//
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()

    }

}
    


