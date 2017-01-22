//
//  SessionDelegate.m
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import "SessionDelegate.h"

@interface SessionDelegate ()
@property (strong, nonatomic) NSMutableData *dataReceived;
@property (nonatomic, copy, nullable) void (^completionHandler) (NSData*, NSURLResponse*, NSError*);
@end

@implementation SessionDelegate

-(instancetype)initWithCompletionHandler:(void (^) (NSData*, NSURLResponse*, NSError*)) completionHandler
{
    self = [super init];
    self.completionHandler = completionHandler;
    self.dataReceived = [[NSMutableData alloc] init];
    return self;
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.dataReceived appendData:data];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    self.completionHandler(self.dataReceived, task.response, nil);
}

@end
