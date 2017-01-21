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
@property (nonatomic, copy, nullable) void (^handler) (NSData*, NSURLResponse*, NSError*);
@end

@implementation SessionDelegate

-(instancetype)initWithHandler:(void (^) (NSData*, NSURLResponse*, NSError*)) handler
{
    self = [super init];
    self.handler = handler;
    self.dataReceived = [[NSMutableData alloc] init];
    return self;
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.dataReceived appendData:data];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    self.handler(self.dataReceived, task.response, nil);
}

@end
