//
//  UIImage+manager.swift
//  ImageDownloader
//
//  Created by sunvlink on 16/8/24.
//  Copyright © 2016年 sunvlink. All rights reserved.
//

import UIKit

extension UIImageView {
    
    public func ss_setImageWithPath(path: String, placeHolderImage: UIImage?, completion:ImageDownloaderCompleteBlock?) {
        image = image ?? placeHolderImage
        
        let cache = ImageCache.defaultCache()
        
        cache.retriveImage(path) { (image, cacheType) in
            if let image = image {
                self.image = image
                switch cacheType {
                case .Memory: print("stored in Memory")
                case .Disk: print("stored in Disk")
                case .None: print("no Cache")
                }
            } else {
                
                let URL = NSURL(string: path)
                let downloader = ImageDownloader.defaultDownloader
                downloader.downloadImage(URL!, progressBlock: { (receivedSize, totalSize) in
                    print("\(receivedSize)/\(totalSize)")
                }) { image, error, originData in
                    print("finished")
                    if let image = image {
                        UIView.transitionWithView(self, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                            self.image = image
                            }, completion: { finished in
                                
                                ImageCache.defaultCache().storeImage(image, originData: originData, key: path, toDisk: true, complete: nil)
                                if let completionHandler = completion {
                                    completionHandler(image: image, error: error, originData: originData)
                                }
                        })
                        
                        
                    }
                }
                
            }
        }
        
    }
    
    
    private func downloadImage(path: String, completion:ImageDownloaderCompleteBlock?) {
        
    }
}

