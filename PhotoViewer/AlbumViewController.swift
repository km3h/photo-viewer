//
//  AlbumViewController.swift
//  PhotoViewer
//
//  Created by ASIM27 on 11/16/16.
//  Copyright © 2016 km3h. All rights reserved.
//

import UIKit

class AlbumViewController: UITableViewController
{
    public weak var dataSource : DataSource?
    
    var photosViewController: PhotosViewController? = nil
    var albumIds : [NSNumber]?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        let selector = Selector(("backButtonTapped"))
        let backButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self.splitViewController, action: selector)
        self.navigationItem.leftBarButtonItem = backButtonItem
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let split = self.splitViewController
        {
            let controllers = split.viewControllers
            self.photosViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PhotosViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        self.reloadData()
        super.viewWillAppear(animated)
    }
    
    public func reloadData()
    {
        self.dataSource?.photoDictionary() { json in
            DispatchQueue.main.async() {
                let keys = json?.keys
                let sortedKeys = keys?.sorted() { n1, n2 in
                    n1.intValue < n2.intValue
                }
                self.albumIds = sortedKeys
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! PhotosViewController
                if let albumId = self.albumIds?[indexPath.row] {
                    controller.albumId = albumId
                }
                controller.dataSource = self.dataSource
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - table view delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let albumIds = self.albumIds
        {
            return albumIds.count
        }
        else
        {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AlbumTableViewCell
        
        if let object = self.albumIds?[indexPath.row]
        {
            cell.sideLabel!.text = ("Album \(object.description)")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 200.0
    }
}

