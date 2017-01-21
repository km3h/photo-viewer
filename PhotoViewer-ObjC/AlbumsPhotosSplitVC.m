//
//  AlbumsPhotosSplitVC.m
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import "AlbumsPhotosSplitVC.h"
#import "AlbumViewController.h"

@interface AlbumsPhotosSplitVC ()

@end

@implementation AlbumsPhotosSplitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationController *navigationController = (UINavigationController*)self.viewControllers[0];
    AlbumViewController *albumViewController = (AlbumViewController*)navigationController.topViewController;
    albumViewController.dataSource = self.dataSource;
}

-(void)backButtonTapped
{
    self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
