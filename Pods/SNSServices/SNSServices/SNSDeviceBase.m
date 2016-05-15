//
//  SNSDeviceBase.m
//  iOSSamples
//
//  Created by Joohae Kim on 2016. 3. 10..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "SNSDeviceBase.h"

@implementation SNSDeviceBase

- (BOOL) hasAuthentication {
    NSError *error;

    error = [self getErrorInstanceFor:SNSServiceErrorUnimplemented withMessage:@"Unimplemented method requestFileList"];
    [self invokeErrorDelegation:error];
    return NO;
}

/*!
 Request request media file list to SNSService
 */
- (void) requestFileList {
    NSError *error;
    error = [self getErrorInstanceFor:SNSServiceErrorUnimplemented withMessage:@"Unimplemented method requestFileList"];
    [self invokeErrorDelegation:error];
}

- (NSError *) getErrorInstanceFor:(SNSServiceError)errorCode withMessage:(NSString *)message {
    return [NSError errorWithDomain:@"kr.carrotbooks.SNSServices"
                               code:errorCode
                           userInfo:@{
                                      NSLocalizedDescriptionKey: message
                                      }];
}

#pragma mark - Internal method
- (void) invokeErrorDelegation:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(SNSServiceError:)]) {
        [self.delegate SNSServiceError:error];
    } else {
        NSLog(@"SNSSErvice internal error: %@", [[error userInfo] valueForKey:NSLocalizedDescriptionKey]);
    }
}
@end
