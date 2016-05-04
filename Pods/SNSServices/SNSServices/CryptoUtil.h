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

-(uint32_t)getUint32NonceFrom:(uint32_t)from to:(uint32_t)to;

@end
