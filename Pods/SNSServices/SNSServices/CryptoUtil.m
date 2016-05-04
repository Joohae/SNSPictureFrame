//
//  CryptoUtil.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "CryptoUtil.h"
#import "MTRandom.h"

@interface CryptoUtil()
{
    MTRandom *_mersenne;
}

@end

@implementation CryptoUtil

-(uint32_t)getUint32NonceFrom:(uint32_t)from to:(uint32_t)to {
    
    return [_mersenne randomUInt32From:from to:to];
}

#pragma mark - Singleton
-(CryptoUtil *)init {
    if (self = [super init]) {
        _mersenne = [[MTRandom alloc] init];
    }
    return self;
}

+(CryptoUtil *)sharedManager {
    static CryptoUtil *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[CryptoUtil alloc] init];
    });
    
    return instance;
}

@end
