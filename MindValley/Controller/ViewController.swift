//
//  ViewController.swift
//  MindValley
//
//  Created by Kelvin Tan on 7/25/18.
//  Copyright © 2018 Kelvin Tan. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imageList: Image!
    var imagesArray = [String]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setupDelegate()
        setupCache()
        setupHeight()
        
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching data...", attributes: nil)
        tableView.refreshControl = refreshControl
    }
    
    func setupHeight(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableView.rowHeight = 500
        } else {
            tableView.rowHeight = 250
        }
    }
    
    
    func setupCache(){
        // Set at 50 MB
        ImageCache.default.maxDiskCacheSize = 50 * 1024 * 1024
        // Set at 7 days duration of cache stored
        ImageCache.default.maxCachePeriodInSecond =  60 * 60 * 24 * 7
        ImageCache.default.calculateDiskCacheSize { (size) in
            print("Used size by bytes", size)
        }
    }
    
    func setupDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    // MARK: Bar Button Item
    @IBAction func clearMemoryButton(_ sender: Any) {
        
        ImageCache.default.clearMemoryCache()
    }
    
    @IBAction func clearCacheButton(_ sender: UIBarButtonItem) {
        let cache = KingfisherManager.shared.cache
        cache.clearDiskCache()
        
        ImageCache.default.calculateDiskCacheSize { (size) in
            print("Used size by bytes", size)
        }
    }
    // MARK: Fetch Data
    @objc func fetchData(){
        downloadDetails {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - TABLE VIEW
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ImagesTableViewCell
//        cell?.textLabel?.text = imagesArray[indexPath.row]
        
        let placeholder = UIImage(named: "not-found")
        var url = URL(string: imagesArray[indexPath.row])
        
        let resource = ImageResource(downloadURL: url!, cacheKey: "image-cache")
        
        ImageDownloader.default.downloadImage(with: url!, retrieveImageTask: nil, options: [.cacheMemoryOnly], progressBlock: nil) { (image, error, url, data) in
//            print("Downloaded image: \(url!)")
            if let image = image, let url = url {
                ImageCache.default.store(image, forKey: "image-cache")
//                print(ImageCache.default.store(image, forKey: "image-cache"))
            }
        }
        cell?.listImages.kf.indicatorType = .activity
        cell?.listImages.kf.setImage(with: url, placeholder: placeholder)
        
        
        cell?.listImages.kf.setImage(with: url, placeholder: placeholder, options: [.cacheMemoryOnly], progressBlock: nil, completionHandler: { (image, error, cacheType, imageUrl) in
//            print(cacheType)
        })
        
        cell?.contentView.alpha = 0
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 2, animations: {
            cell.contentView.alpha = 1
        }, completion: nil)
    }
    
    // MARK: JSON
    func downloadDetails(completed: @escaping DownloadComplete){
        Alamofire.request(API_URL).responseJSON { (response) in
            let result = response.result
            let json = JSON(result.value!).array
            let jsonCount = json?.count
            let count = jsonCount!
            
            for i in 0..<(count){
                let image = json![i]["urls"]["raw"].stringValue
                self.imagesArray.append(image)
            }
            completed()
        }
    }
}

