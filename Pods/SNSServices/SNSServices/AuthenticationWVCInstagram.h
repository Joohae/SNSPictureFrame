//
//  AuthenticationWVCInstagram.h
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 13..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <SNSServices/SNSServices.h>

@interface AuthenticationWVCInstagram : AuthenticationWebViewController

/*!
 Set parameters to authenticate Instagram.
 
 To use the method, developer has to register an application on Instagram developer site: https://www.instagram.com/developer/
 
 You could get parameter values when register a client.
 @param clientId        Client ID
 @param clientSecret    Client Secret
 @param callbackBase    Registered redirect url
 */
- (void) setClinetID:(NSString *)clientId secret:(NSString *)clientSecret andCallbackBase:(NSString *)callbackBase;

@end
