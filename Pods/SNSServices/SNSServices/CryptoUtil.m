//
//  CryptoUtil.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>

#import "CryptoUtil.h"
#import "MTRandom.h"

@interface CryptoUtil()
{
    MTRandom *_mersenne;
}

@end

@implementation NSString (NSString_Extended)
- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end

@implementation CryptoUtil

-(uint32_t)getUint32NonceFrom:(uint32_t)from to:(uint32_t)to {
    if (from < to) {
        return [_mersenne randomUInt32From:from to:to];
    } else {
        return [_mersenne randomUInt32From:to to:from];
    }
}

-(NSString *) urlEncode:(NSString *) source {
    return [source urlencode];
}

-(NSString *)hmacsha1:(NSString *)data secret:(NSString *)key {
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *hash = [HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return hash;
}

-(NSTimeInterval)getTimeStamp {
    return [[NSDate new] timeIntervalSince1970];
}

-(NSString *)getTimeStampString {
    return [NSString stringWithFormat:@"%f", [self getTimeStamp]];
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
