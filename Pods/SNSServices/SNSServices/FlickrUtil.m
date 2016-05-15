//
//  FlickrUtil.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "FlickrUtil.h"
#import "CryptoUtil.h"

@interface FlickrUtil()
{
}
@end

@implementation FlickrUtil

+(NSString *)createNonce {
    NSString *response = nil;
    response = [NSString stringWithFormat:@"%08u", [[CryptoUtil sharedManager] getUint32NonceFrom:10000000 to:99999999]];
    
    return response;
}

+(NSDictionary *)parseURLResponse:(NSString *)response {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *items = [response componentsSeparatedByString:@"&"];
    for (NSString *item in items) {
        NSArray *keyValue = [item componentsSeparatedByString:@"="];
        if (keyValue.count < 2) continue;
        [dict setObject:keyValue[1] forKey:keyValue[0]];
    }
    
    return dict;
}
@end
		