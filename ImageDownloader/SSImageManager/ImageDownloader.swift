//
//  ImageDownloader.swift
//  ImageDownloader
//
//  Created by sunvlink on 16/7/20.
//  Copyright © 2016年 sunvlink. All rights reserved.
//

import UIKit

public typealias ImageDownloaderProgressBlock = (receivedSize: Int64, totalSize: Int64) -> ()
public typealias ImageDownloaderCompleteBlock = (image: UIImage?, error: NSError?, originData: NSData?) -> ()

private let instance = ImageDownloader()

public class ImageDownloader: NSObject {
    
    typealias callbackPair = (progressBlock: ImageDownloaderProgressBlock?, completeBlock: ImageDownloaderCompleteBlock?)
    
    class ImageFetchLoad {
        var callbacks = [callbackPair]()
        var responseData = NSMutableData()
    }
    
    var fetchLoads = [NSURL: ImageFetchLoad]()
    
    private let sessionHandler: ImageDownloaderSessionHandler
    
    private let session: NSURLSession?
    
    public class var defaultDownloader: ImageDownloader {
        return instance
    }
    
    override init() {
        sessionHandler = ImageDownloaderSessionHandler()
        session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: sessionHandler, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    public func downloadImage(URL: NSURL,
                              progressBlock: ImageDownloaderProgressBlock?,
                              completeBlock: ImageDownloaderCompleteBlock?) -> Void {
        guard !URL.absoluteString.isEmpty else {return }
        
        setupAllCallbacks(URL, progressBlock: progressBlock, completeBlock: completeBlock)
        if let session = session {
            let dataTask = session.dataTaskWithURL(URL)
            dataTask.resume()
            sessionHandler.downloader = self
        }
    }
    
    internal func setupAllCallbacks(URL: NSURL,
                                    progressBlock: ImageDownloaderProgressBlock?,
                                    completeBlock: ImageDownloaderCompleteBlock?) {
        let fetchLoad = self.fetchLoads[URL] ?? ImageFetchLoad()
        
        let callbackPair = (progressBlock: progressBlock, completeBlock: completeBlock)
        
        fetchLoad.callbacks.append(callbackPair)
        
        self.fetchLoads[URL] = fetchLoad
    }
}

class ImageDownloaderSessionHandler: NSObject, NSURLSessionDataDelegate {
    
    var downloader: ImageDownloader?
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        guard let downloader = downloader else {return }
        
        if let URL = dataTask.originalRequest?.URL, let fetchLoad = downloader.fetchLoads[URL] {
            fetchLoad.responseData.appendData(data)
            
            for callback in fetchLoad.callbacks {
                callback.progressBlock?(receivedSize: Int64(fetchLoad.responseData.length), totalSize: dataTask.response!.expectedContentLength)
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        guard let downloader = downloader else {return }
        
        if let URL = task.originalRequest?.URL, let fetchLoad = downloader.fetchLoads[URL] {
            if let image = UIImage(data: fetchLoad.responseData) {
                for callback in fetchLoad.callbacks {
                    callback.completeBlock?(image: image, error: nil, originData: fetchLoad.responseData)
                }
            }
        }
    }
    
}


