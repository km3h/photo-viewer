//
//  PhotosViewController.h
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"

typedef struct
{
    CGFloat approximateCellWidth;
     CGFloat cellMargin;
} PhotosViewControllerConstants;

@interface PhotosViewController : UIViewController
@property (strong, nonatomic) NSNumber *albumId;
@property (strong, nonatomic) DataSource *dataSource;
@property (strong, nonatomic) NSArray *photos;
@end
