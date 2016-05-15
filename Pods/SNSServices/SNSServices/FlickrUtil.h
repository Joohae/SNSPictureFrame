//
//  FlickrUtil.h
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrUtil : NSObject

/*!
 Generate a nonce
 */
+(NSString *)createNonce;

/*!
 Parse the response of oauth/request_token API.
 @param response the respons from flickr for oauth/request_token
 */
+(NSDictionary *)parseURLResponse:(NSString *)response;

@end
