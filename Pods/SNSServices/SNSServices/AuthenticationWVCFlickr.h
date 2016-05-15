//
//  AuthenticationWVCFlickr.h
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <SNSServices/SNSServices.h>

#define FLICKR_PERMISSION_READ @"read"
#define FLICKR_PERMISSION_WRITE @"write"
#define FLICKR_PERMISSION_DELETE @"delete"

@interface AuthenticationWVCFlickr : AuthenticationWebViewController

/*!
 Set parameters to authenticate Flickr
 
 To use the method, developer has to register an application on Flickr
 developer site:
 Developer Account: https://www.flickr.com/services/developer
 Application      : https://www.flickr.com/services/apps/create/apply/
 
 You could get parameter values when register a client.
 @param authToken       authentication token which obtained by oauth/request_token
 @param permission      requesting permission FLICKR_PERMISSION_READ, FLICKR_PERMISSION_WRITE and FLICKR_PERMISSION_DELETE. FLICKR_PERMISSION_WRITE includes FLICKR_PERMISSION_READ. FLICKR_PERMISSION_DELETE includes both FLICKR_PERMISSION_READ and FLICKR_PERMISSION_WRITE
 @param callbackBase    Registered redirect url
 */
- (void) setAuthToken:(NSString *)authToken permission:(NSString *)permission andCallbackBase:(NSString *)callbackBase;

@end
