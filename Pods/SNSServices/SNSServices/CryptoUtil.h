//
//  CryptoUtil.h
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CryptoUtil : NSObject

+(CryptoUtil *)sharedManager;

/*!
 Generate 32bit Unsigned Integer random value.
 The method using Mersenne Twister
 @param from    a number that start the range
 @param to      a number that end   the range
 */
-(uint32_t)getUint32NonceFrom:(uint32_t)from to:(uint32_t)to;

/*!
 URL Encode method. The method covers some characters which is not covered
 by stringByAddingPercentEncodingWithAllowedCharacters method of NSString object.
 @param souce   a string to convert
 */
-(NSString *)urlEncode:(NSString *) source;

/*!
 Calculate HMC-SHA1 hash with given data and key
 @param data    the data to calculate hash value
 @param key     a key for hash calculation
 */
-(NSString *)hmacsha1:(NSString *)data secret:(NSString *)key;


-(NSTimeInterval)getTimeStamp;
-(NSString *)getTimeStampString;
@end
