//
//  SessionDelegate.h
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionDelegate : NSObject <NSURLSessionDataDelegate>
-(instancetype)initWithCompletionHandler:(void (^) (NSData*, NSURLResponse*, NSError*)) handler;
@end
