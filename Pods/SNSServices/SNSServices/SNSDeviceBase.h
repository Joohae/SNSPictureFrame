//
//  SNSDeviceBase.h
//  iOSSamples
//
//  Created by Joohae Kim on 2016. 3. 10..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSServiceDelegate.h"

typedef NS_ENUM(NSInteger, SNSServiceError) {
    SNSServiceErrorOkay,                // No error
    SNSServiceErrorUnimplemented,       // Unimplemented method error
    SNSServiceErrorDeviceNotFound       // Requested device is not registered
};

@interface SNSDeviceBase : NSObject

@property (nonatomic,weak) id<SNSServiceDelegate> delegate;

/*!
 Check if the device has authentication to request
 */
- (BOOL) hasAuthentication;

/*!
 Request request media file list to SNSService
 */
- (void) requestFileList;

/*!
 For internal use, get error instance for the case.
 */
- (NSError *) getErrorInstanceFor:(SNSServiceError)errorCode withMessage:(NSString *)message;
@end
