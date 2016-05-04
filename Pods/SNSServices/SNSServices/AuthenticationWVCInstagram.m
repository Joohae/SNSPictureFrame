//
//  AuthenticationWVCInstagram.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 13..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "AuthenticationWVCInstagram.h"

@interface AuthenticationWVCInstagram ()

@property (nonatomic) NSString *clientId;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSString *callbackBase;

@end

@implementation AuthenticationWVCInstagram

- (void)viewDidLoad {
    NSString *scopeStr = @"scope=basic+likes+comments+relationships";
    self.targetURL = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&display=touch&%@&redirect_uri=%@&response_type=token",
                     _clientId, scopeStr, _callbackBase];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public methods
- (void) setClinetID:(NSString *)clientId
              secret:(NSString *)clientSecret
     andCallbackBase:(NSString *)callbackBase {
    
    _clientId = clientId;
    _clientSecret = clientSecret;
    _callbackBase = callbackBase;
}

#pragma mark - UIWebView Delegate override
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.webView stopLoading];
    
    if([error code] == -1009)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot open the page because it is not connected to the Internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self.delegate authenticationFailure:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *responseURL = [request.URL absoluteString];
    
    if([responseURL hasPrefix:_callbackBase])
    {
        NSString* pattern = [NSString stringWithFormat:@"%@/", _callbackBase];
        NSString* urlString = [[request URL] absoluteString];
        NSArray * UrlParts = [urlString componentsSeparatedByString:pattern];
        urlString = [UrlParts objectAtIndex:1];
        
        NSRange accessToken = [urlString rangeOfString: @"#access_token="];
        if (accessToken.location != NSNotFound) {
            NSString* strAccessToken = [urlString substringFromIndex: NSMaxRange(accessToken)];
            NSDictionary *response = @{
                                       @"ACCESS_TOKEN": strAccessToken
                                       };
            if (!self.delegate || ![self.delegate respondsToSelector:@selector(authenticationSuccess:)]) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:@"delegate authenticationSuccess not implemented"
                                             userInfo:nil];
                return NO;
            }
            
            [self.delegate authenticationSuccess:response];
            return NO;
        } else {
            NSString *responseQuery = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
            NSMutableDictionary *userInfo = [NSMutableDictionary new];
            for (NSString *anItem in [responseQuery componentsSeparatedByString:@"&"]) {
                NSArray *keyValue = [anItem componentsSeparatedByString:@"="];
                [userInfo setValue:keyValue[1] forKey:keyValue[0]];
            }
            
            NSError *error;
            if ([userInfo valueForKey:@"error_description"]) {
                [userInfo setObject:[userInfo valueForKey:@"error_description"]
                             forKey:NSLocalizedDescriptionKey];
            }
            error = [NSError errorWithDomain:@"kr.carrotbooks.SNSServices"
                                        code:NSURLErrorBadServerResponse
                                    userInfo:userInfo];
            if (self.delegate && [self.delegate respondsToSelector:@selector(authenticationFailure:)]) {
                [self.delegate authenticationFailure:error];
            }
        }
    }
    return YES;
}
@end
