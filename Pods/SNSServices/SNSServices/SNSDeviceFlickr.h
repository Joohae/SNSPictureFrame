//
//  SNSDeviceFlickr.h
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <SNSServices/SNSServices.h>
#import "AuthenticationDelegate.h"

@interface SNSDeviceFlickr : SNSDeviceBase <AuthenticationDelegate>

/*!
 Set parameters to authenticate Flickr
 
 To use the method, developer has to register an application on Flickr
 developer site: 
    Developer Account: https://www.flickr.com/services/developer
    Application      : https://www.flickr.com/services/apps/create/apply/
 
 You could get parameter values when register a client.
 @param clientKey       Client Key
 @param clientSecret    Client Secret
 @param callbackBase    Registered redirect url
 */
- (void) setClinetKey:(NSString *)clientKey secret:(NSString *)clientSecret andCallbackBase:(NSString *)callbackBase;

@end
