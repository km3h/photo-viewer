//
//  DataSource.h
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum  DataSourcePhotoType
{
    DataSourcePhotoTypeThumnail,
    DataSourcePhotoTypeFullPhoto
} DataSourcePhotoType;

typedef enum URLSessionType
{
    URLSessionTypeDelegate,
    URLSessionTypeCompletionHandler,
    URLSessionTypeDefault
} URLSessionType;


@interface DataSource : NSObject
@property (strong, nonatomic) NSString *urlString;
@property enum URLSessionType urlSessionType;
-(void)dataHandler:(void (^) (NSDictionary *)) handler;
-(void)photo:(DataSourcePhotoType)photoType photo:(NSDictionary*)photo handler: (void (^) (UIImage*)) handler;
@end
