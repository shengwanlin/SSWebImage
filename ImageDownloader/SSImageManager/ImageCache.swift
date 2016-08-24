//
//  ImageCache.swift
//  ImageDownloader
//
//  Created by sunvlink on 16/7/21.
//  Copyright © 2016年 sunvlink. All rights reserved.
//

import UIKit

private let defaultCacheName = "default"
private let cachePath = "com.sunvlink.ImageCache."
private let ioQueueName = "com.sunvlink.ImageCache.ioQueue"

private let instance = ImageCache(cacheName: defaultCacheName)

public enum  CacheType {
    case None, Memory, Disk
}

public class ImageCache: NSObject {
    
    // Memory
    private let memoryCache = NSCache()
    
    // Disk
    private let fileManager: NSFileManager!
    private let ioQueue: dispatch_queue_t
    private let diskCachePath: String

    public class func defaultCache() -> ImageCache {
        return instance
    }
    
    public init(cacheName: String) {
        
        if cacheName.isEmpty {
            fatalError("you must specify a cache name")
        }
        
        let cache = cachePath + cacheName
        memoryCache.name = cache
        
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        diskCachePath = (path as NSString).stringByAppendingString(cache)
        
        ioQueue = dispatch_queue_create(ioQueueName, DISPATCH_QUEUE_SERIAL)
        self.fileManager = NSFileManager()
        
    }
    
}

// MARK: Retrive Image Data
extension ImageCache {
    
    public func retriveImage(key: String, completionHandler:((UIImage?, CacheType) -> Void)?) {
        guard let completionHandler = completionHandler else { return}
        
        if let image = retriveImageFromMemory(key) {
            
            dispatch_async(dispatch_get_main_queue(), { 
                completionHandler(image, .Memory)
            })
        } else {
            let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, { 
                if let image = self.retriveImageFromDisk(key) {
                    self.storeImage(image, originData: nil, key: key, toDisk: false, complete: nil)
                    dispatch_async(dispatch_get_main_queue(), { 
                        completionHandler(image, .Disk)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(nil, .None)
                    })
                }
            })
            
            dispatch_async(ioQueue, block!)
        }
    }
    
    public func retriveImageFromMemory(key: String) -> UIImage? {
        return memoryCache.objectForKey(key) as? UIImage
    }
    
    public func retriveImageFromDisk(key: String) -> UIImage? {
        let filePath = (diskCachePath as NSString).stringByAppendingString(key)
        if let data = NSData(contentsOfFile: filePath) {
            return UIImage(data: data)
        }
        return nil
    }
}

// MARK: Store&Remove
extension ImageCache {
    
    public func storeImage(image: UIImage, originData: NSData? = nil, key: String, toDisk: Bool, complete:(Void -> Void)?) {
        memoryCache.setObject(image, forKey: key)
        
        func callHandlerInMainQueue() {
            if let handler = complete {
                dispatch_async(dispatch_get_main_queue(), {
                    handler()
                })
            }
        }
        
        if toDisk {
            
            dispatch_async(ioQueue, {
                let data: NSData?
                if let originData = originData {
                    data = originData
                } else {
                    data = UIImagePNGRepresentation(image)
                }
                
                if let data = data {
                    if !self.fileManager.fileExistsAtPath(self.diskCachePath) {
                        do {
                            try self.fileManager.createDirectoryAtPath(self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                        } catch {}
                    }
                    let filePath = (self.diskCachePath as NSString).stringByAppendingString(key)
                    self.fileManager.createFileAtPath(filePath, contents: data, attributes: nil)
                }
                callHandlerInMainQueue()
                
            })
            
        } else {
            callHandlerInMainQueue()
        }
    }
    
    
    public func removeImageForKey(key: String, fromDisk: Bool, complete:(Void -> Void)?) {
        memoryCache.removeObjectForKey(key)
        
        func callHandlerInMainQueue() {
            if let handler = complete {
                dispatch_async(dispatch_get_main_queue(), {
                    handler()
                })
            }
        }
        
        if fromDisk {
            dispatch_async(ioQueue, {
                do {
                    try self.fileManager.removeItemAtPath((self.diskCachePath as NSString).stringByAppendingString(key))
                } catch _ {}
                callHandlerInMainQueue()
            })
        } else {
            callHandlerInMainQueue()
        }
        
        
    }
}
