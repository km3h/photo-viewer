//
//  AlbumViewController.h
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"

@interface AlbumViewController : UITableViewController
@property (strong, nonatomic) DataSource *dataSource;
@end
