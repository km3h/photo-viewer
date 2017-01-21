//
//  PhotoViewController.h
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"

@interface PhotoViewController : UIViewController
@property (strong, nonatomic) DataSource *dataSource;
@property (strong, nonatomic) NSDictionary *photo;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
