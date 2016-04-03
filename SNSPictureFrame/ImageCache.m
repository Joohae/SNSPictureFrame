//
//  imageCache.m
//  imageCache
//
//  Created by Joohae Kim on 2016. 3. 28..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ImageCache.h"

#define CACHE_DISK_SIZE (128 * 1024 * 1024)
#define CACHE_DISK_PATH @"imageCache"

NS_ASSUME_NONNULL_BEGIN
@implementation ImageCache

-(void)requestImage:(NSString *)downloadUrlString
            success:(void (^)(UIImage *image)) success
            failure:(void (^)(NSError *error)) failure {
    NSURL *url = [NSURL URLWithString:downloadUrlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:30.0f];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               
                               NSLog(@"Async Complete with %@", response);
                               if (connectionError) {
                                   failure(connectionError);
                                   return;
                               }
                               
                               success([UIImage imageWithData:data]);
                               NSLog(@"[[NSURLCache sharedURLCache] currentDiskUsage]: %lu", (unsigned long)[[NSURLCache sharedURLCache] currentDiskUsage]);
                           }];
}

#pragma mark - Singleton
+(ImageCache *) sharedManager {
    static ImageCache *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ImageCache alloc] init];
    });
    return instance;
}

-(ImageCache *) init {
    if (self = [super init]) {
        //  Set URL Cache Capacities
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:CACHE_DISK_SIZE diskPath:CACHE_DISK_PATH];
        [NSURLCache setSharedURLCache:sharedCache];
    }
    
    return self;

}
@end
NS_ASSUME_NONNULL_END