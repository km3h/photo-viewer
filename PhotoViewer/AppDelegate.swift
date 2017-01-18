//
//  AppDelegate.swift
//  PhotoViewer
//
//  Created by ASIM27 on 11/16/16.
//  Copyright © 2016 km3h. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate
{
    
    var window: UIWindow?
    let appController = UINavigationController.init()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //setup
        let color = UIColor(red:0.13, green:0.10, blue:0.09, alpha:1.0)
        UINavigationBar.appearance().tintColor = color
        UILabel.appearance().textColor = color
        
        // Per documentation, response must be less than 5% of the size of the cache in order for response to be cached
        let urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        URLCache.shared = urlCache
        
        //root view setup
        let landingViewController = LandingViewController.init();
        self.appController.pushViewController(landingViewController, animated: false);
        
        //set main view path to display in app
        let storyboard = UIStoryboard.init(name: "AlbumsPhotosSplitVC", bundle: nil)
        let splitViewController = storyboard.instantiateInitialViewController() as! AlbumsPhotosSplitVC
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        landingViewController.albumsPhotosSplitVC = splitViewController
        
        //display root view
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.rootViewController = self.appController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - Split view
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool
    {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard (secondaryAsNavController.topViewController as? PhotosViewController) != nil else { return false }
        return true
    }
    
}

