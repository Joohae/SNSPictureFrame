//
//  AuthenticationWebViewController.h
//  iOSSamples
//
//  Created by Joohae Kim on 2016. 3. 13..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthenticationDelegate.h"

@interface AuthenticationWebViewController : UIViewController <AuthenticationDelegate, UIWebViewDelegate>

@property (nonatomic) id<AuthenticationDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) NSString *targetURL;

@end
