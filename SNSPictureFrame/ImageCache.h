//
//  imageCache.h
//  imageCache
//
//  Created by Joohae Kim on 2016. 3. 28..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

+(ImageCache *) sharedManager;

/*!
 Requesting image.
 */
-(void)requestImage:(NSString *)downUrlString
            success:(void (^)(UIImage *image)) success
            failure:(void (^)(NSError *error)) failure;

@end
