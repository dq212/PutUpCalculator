//
//  MRPhotosHelper.swift
//  MotoPreserve
//
//  Created by DANIEL I QUINTERO on 9/1/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import Photos

class MRPhotosHelper {
    
    var manager = PHImageManager.default()
    
    func saveImageAsAsset(image: UIImage, completion: @escaping (_ localIdentifier:String?) -> Void) {
        
        var imageIdentifier: String?
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "MotoPreserve")
        let fetchResult : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else { return }

        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let placeHolder = changeRequest.placeholderForCreatedAsset
            imageIdentifier = placeHolder?.localIdentifier
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: photoAlbum)
                    let fastEnumeration = NSArray(array:[placeHolder!] as [PHObjectPlaceholder])
                    albumChangeRequest?.addAssets(fastEnumeration)
                //})
//            { (success, err) in
            //        if let err = err {
            //            print("There was an error saving the image")
            //            return
            //        }

        }, completionHandler: { (success, error) -> Void in
            if success {
                completion(imageIdentifier)
            } else {
                completion(nil)
            }
        })
       
    }
    
    func retrieveImageWithIdentifer(localIdentifier:String, completion: @escaping (_ image:UIImage?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let fetchResults = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: fetchOptions)
        
        if fetchResults.count > 0 {
            if let imageAsset = fetchResults.object(at: 0) as? PHAsset {
                let requestOptions = PHImageRequestOptions()
                requestOptions.deliveryMode = .highQualityFormat
                manager.requestImage(for: imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) -> Void in
                    completion(image)
                })
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
}
