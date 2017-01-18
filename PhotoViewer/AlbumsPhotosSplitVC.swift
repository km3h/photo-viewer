//
//  AlbumsPhotosSplitVC.swift
//  PhotoViewer
//
//  Created by ASIM27 on 11/16/16.
//  Copyright © 2016 km3h. All rights reserved.
//

import UIKit

class AlbumsPhotosSplitVC: UISplitViewController
{
    var taskOnline : URLSessionDataTask?
    var taskOffline : URLSessionDataTask?
    public var dataSource : DataSource?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let navigationController = self.viewControllers[0] as! UINavigationController
        let albumViewController = navigationController.topViewController as! AlbumViewController
        albumViewController.dataSource = self.dataSource
    }
    
    public func backButtonTapped()
    {
        self.preferredDisplayMode = .primaryHidden
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
