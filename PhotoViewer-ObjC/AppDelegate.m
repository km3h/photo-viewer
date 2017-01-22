//
//  AppDelegate.m
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import "AppDelegate.h"
#import "LandingViewController.h"
#import "AlbumsPhotosSplitVC.h"
#import "PhotosViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>
@property (strong, nonatomic) UINavigationController *appController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //setup
    UIColor *color = [UIColor colorWithRed:0.13 green:0.10 blue:0.09 alpha:1.0];
    [UINavigationBar appearance].tintColor = color;
    [UILabel appearance].textColor = color;
    
    // Per documentation, response must be less than 5% of the size of the cache in order for response to be cached
    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:urlCache];
    
    //root view setup
    self.appController = [[UINavigationController alloc] init];
    LandingViewController *landingViewController = [[LandingViewController alloc] init];
    [self.appController pushViewController:landingViewController animated:false];
    
    //set main view path to display in app
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"AlbumsPhotosSplitVC" bundle:nil];
    AlbumsPhotosSplitVC *splitViewController = (AlbumsPhotosSplitVC *)[storyBoard instantiateInitialViewController];
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    landingViewController.albumsPhotosSplitVC = splitViewController;
    
    //display root view
    UIScreen *screen = [UIScreen mainScreen];
    self.window = [[UIWindow alloc] initWithFrame:screen.bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.appController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Split view

-(BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[PhotosViewController class]]
        && (PhotosViewController *)[(UINavigationController *)secondaryViewController topViewController]) {
        return YES;
    } else {
        return NO;
    }
}

@end
