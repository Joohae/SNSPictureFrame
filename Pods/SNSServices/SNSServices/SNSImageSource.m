//
//  SNSImageSource.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 23..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "SNSImageSource.h"

@implementation SNSImageSource
-(BOOL)isEqual:(SNSImageSource *)object {
    if (!self.imageUrl) {
        return NO;
    }

    return [self.imageUrl isEqualToString:object.imageUrl];
}

-(NSUInteger) hash {
    return [self.imageUrl hash];
}
@end
