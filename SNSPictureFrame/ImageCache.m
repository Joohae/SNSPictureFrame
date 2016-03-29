//
//  imageCache.m
//  imageCache
//
//  Created by Joohae Kim on 2016. 3. 28..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "ImageCache.h"

#define CACHE_DISK_SIZE (128 * 1024 * 1024)
#define CACHE_DISK_PATH @"imageCache"

@implementation ImageCache

#pragma mark - Singleton
+(ImageCache *) shareManager {
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
        NSURLCache *URLCache = [NSURLCache sharedURLCache];
        NSInteger memoryCapacity = 0;
        NSInteger diskCapacity = 0;

        if (URLCache) {
            memoryCapacity = URLCache.memoryCapacity;
            diskCapacity = URLCache.diskCapacity;
            if (diskCapacity < CACHE_DISK_SIZE) {
                diskCapacity = CACHE_DISK_SIZE;
            }
        }
        
        URLCache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:CACHE_DISK_PATH];
        [NSURLCache setSharedURLCache:URLCache];
    }
    
    return self;

}
@end
