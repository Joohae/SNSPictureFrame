//
//  NSDictionary+Helper.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 23..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "NSDictionary+Helper.h"

@implementation NSDictionary(Helper)

-(id)objectForKeyPath:(NSString *)keyPath {
    id response = self;
    NSArray *parts = [keyPath componentsSeparatedByString:@"."];
    for (NSString *aKey in parts) {
        response = [response objectForKey:aKey];
        if (!response || [response isEqual:[NSNull null]]) {
            break;
        }
    }
    
    return response;
}

@end
