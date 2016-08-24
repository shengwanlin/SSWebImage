//
//  ViewController.swift
//  ImageDownloader
//
//  Created by sunvlink on 16/7/20.
//  Copyright © 2016年 sunvlink. All rights reserved.
//

import UIKit

private let path = "https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png"

private let imagePaths = ["https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1183662833,122272795&fm=80",
                              "https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=2235930430,3727729647&fm=80",
                              "https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=2621263018,1906287545&fm=80",
                              "https://ss0.baidu.com/6ONWsjip0QIZ8tyhnq/it/u=2778625536,151094273&fm=80",
                              "https://ss0.baidu.com/6ONWsjip0QIZ8tyhnq/it/u=1461925647,152905216&fm=80",
                              "https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1271225063,2034082087&fm=80"
]

// https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1271225063,2034082087&fm=80
// https://ss0.baidu.com/6ONWsjip0QIZ8tyhnq/it/u=1461925647,152905216&fm=80
// https://ss0.baidu.com/6ONWsjip0QIZ8tyhnq/it/u=2778625536,151094273&fm=80
// https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=2621263018,1906287545&fm=80
// https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=2235930430,3727729647&fm=80
// https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1183662833,122272795&fm=80

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private let tableView: UITableView = {
        let t = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
//        t.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
//    @IBAction func reload(sender: UIButton) {
//        imageView.ss_setImageWithPath(path, placeHolderImage: nil, completion: nil)
//    }
//    
//    @IBAction func download(sender: UIButton) {
//        downloadAndCacheImage(path) { (image, error, originData) in
//            if let image = image {
//                self.imageView.image = image
//            }
//        }
//    }
//    
//    func downloadAndCacheImage(path: String, completionHandler: ImageDownloaderCompleteBlock?) {
//        
//        let URL = NSURL(string: path)
//        let downloader = ImageDownloader.defaultDownloader
//        downloader.downloadImage(URL!, progressBlock: { (receivedSize, totalSize) in
//            print("\(receivedSize)/\(totalSize)")
//            }) { (image, error, originData) in
//                
//                if let image = image {
//                    ImageCache.defaultCache().storeImage(image, originData: originData, key: path, toDisk: true, complete: nil)
//                    if let completionHandler = completionHandler {
//                        completionHandler(image: image, error: error, originData: originData)
//                    }
//                }
//        }
//        
//    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagePaths.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell.self))
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: NSStringFromClass(UITableViewCell.self))
            let avatar = UIImageView()
            avatar.frame.size = CGSize(width: 100, height: 100)
            cell?.contentView.addSubview(avatar)
            avatar.ss_setImageWithPath(imagePaths[indexPath.row], placeHolderImage: nil, completion: nil)
//            cell?.imageView?.ss_setImageWithPath(imagePaths[indexPath.row], placeHolderImage: nil, completion: { image, error, originData in
//                tableView.reloadData()
//            })
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
}

