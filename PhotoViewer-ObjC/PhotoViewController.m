//
//  PhotoViewController.m
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataSource photo:DataSourcePhotoTypeFullPhoto photo:self.photo handler:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

@end
