//
//  DataSource.m
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import "DataSource.h"
#import "SessionDelegate.h"

@interface DataSource ()
@property (strong, nonatomic) NSURLRequest *urlRequest;
@property (strong, nonatomic) NSURLRequest *urlRequestOffline;
@property (weak, nonatomic) NSURLSession *urlSession;
@property (nonatomic, copy, nullable) void (^photoDictionaryCompletionHandler) (NSDictionary *);
@property (nonatomic, copy, nullable) void (^taskCompletionHandler) (NSData*, NSURLResponse*, NSError*);
@property (nonatomic, copy, nullable) void (^taskOfflineCompletionHandler) (NSData*, NSURLResponse*, NSError*);

@end

@implementation DataSource

-(instancetype)init
{
    self = [super init];
    [self createPhotoDirectory];
    
    __weak DataSource *weakSelf = self;
    self.taskCompletionHandler = ^(NSData *data, NSURLResponse *response, NSError *error) {
        [weakSelf taskProcessor:data response:response error:error];
    };
    
    self.taskOfflineCompletionHandler = ^(NSData *data, NSURLResponse *response, NSError *error) {
        [weakSelf taskProcessorOffline:data response:response error:error];
    };
    
    return self;
}

-(void)setUrlString:(NSString *)urlString
{
    self->_urlString = urlString;
    NSURL *url = [NSURL URLWithString:urlString];
    self.urlRequest = [NSURLRequest requestWithURL:url];
    self.urlRequestOffline = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
}

-(void)createPhotoDirectory
{
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *dataPath = [documentsURL URLByAppendingPathComponent:@"images"].path;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        return;
    }
    else
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
}

-(void)genericTaskProcessor:(NSData*)data response:(NSURLResponse*)urlResponse error:(NSError*)error
{
    if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSInteger statusCode = ((NSHTTPURLResponse*)urlResponse).statusCode;
        if (statusCode == 200 || statusCode == 304)
        {
            if (data == nil)
            {
                return;
            }
            NSArray *json = [self serializeJson:data];
            self.photoDictionaryCompletionHandler([self transformData:json]);
        }
    }
}

-(void)taskProcessor:(NSData*)data response:(NSURLResponse*)urlResponse error:(NSError*)error
{
    if (error)
    {
        NSLog(@"error %@", error);
    }
    
    if (urlResponse != nil )
    {
        [self genericTaskProcessor:data response: urlResponse error: error];
    }
    else
    {
        NSURLSessionDataTask *dataTask;
        switch (self.urlSessionType)
        {
            case URLSessionTypeDefault:
            case URLSessionTypeDelegate:
                dataTask = [[self getSessionWithCompletionHandler:self.taskOfflineCompletionHandler] dataTaskWithRequest:self.urlRequestOffline];
                break;
            case URLSessionTypeCompletionHandler:
                dataTask = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]  dataTaskWithRequest:self.urlRequestOffline completionHandler:self.taskOfflineCompletionHandler];
                break;
            default:
                break;
        }
        [dataTask resume];
    }
}

-(void)taskProcessorOffline:(NSData*)data response:(NSURLResponse*)urlResponse error:(NSError*)error
{
    if (error)
    {
        NSLog(@"error %@", error);
    }
    
    if (urlResponse != nil )
    {
        [self genericTaskProcessor:data response: urlResponse error: error];
    }
}

-(void)photoDictionary:(void (^) (NSDictionary *)) completionHandler
{
    NSURLSessionDataTask *dataTask;
    self.photoDictionaryCompletionHandler = completionHandler;
    
    switch (self.urlSessionType)
    {
        case URLSessionTypeDefault:
        case URLSessionTypeDelegate:
            dataTask = [[self getSessionWithCompletionHandler:self.taskCompletionHandler] dataTaskWithRequest:self.urlRequest];
            break;
        case URLSessionTypeCompletionHandler:
            dataTask = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]  dataTaskWithRequest:self.urlRequest completionHandler:self.taskCompletionHandler];
            break;
        default:
            break;
    }
    
    [dataTask resume];
}
-(NSURLSession*)getSessionWithCompletionHandler:(void (^) (NSData*, NSURLResponse*, NSError*))completionHandler
{
    SessionDelegate *delegate = [[SessionDelegate alloc] initWithCompletionHandler:completionHandler];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:delegate delegateQueue:nil];
    return session;
}

-(NSArray*)serializeJson:(NSData*)data
{
    if (data != nil)
    {
        NSArray *json = (NSArray*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
        return json;
    }
    return nil;
}

-(NSDictionary*)transformData:(NSArray*)json
{
    NSMutableDictionary *transformedData = [NSMutableDictionary dictionaryWithCapacity:json.count];
    
    for (NSDictionary *photo in json)
    {
        NSNumber *albumName = photo[@"albumId"];
        NSMutableArray *photoArray = transformedData[albumName];
        
        if (photoArray == nil)
        {
            photoArray = [NSMutableArray array];
            transformedData[albumName] = photoArray;
        }
        [photoArray addObject:photo];
    }
    return transformedData;
}

-(void)photo:(DataSourcePhotoType)photoType photo:(NSDictionary*)photo completionHandler: (void (^) (UIImage*)) completionHandler
{
    NSString *photoName = photo[@"id"];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    
    NSString *filePath;
    NSString *photoPath;
    NSString *photoSize;
    
    if  (photoType == DataSourcePhotoTypeThumnail)
    {
        photoSize = @"thumbnail";
        photoPath = photo[@"thumbnailUrl"];
    }
    else
    {
        photoSize = @"fullPhoto";
        photoPath = photo[@"url"];
    }
    
    NSString *pathComponent = [NSString stringWithFormat:@"images/%@_%@.png", photoName, photoSize];
    filePath = [documentsURL URLByAppendingPathComponent:pathComponent].path;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        completionHandler([UIImage imageWithContentsOfFile:filePath]);
    }
    else
    {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),  ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoPath]];
            UIImage *getImage = [UIImage imageWithData:data];
            [data writeToURL:fileURL atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(getImage);
            });
        });
    }
}

@end
