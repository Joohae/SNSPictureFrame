//
//  AuthenticationWVCFlickr.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "AuthenticationWVCFlickr.h"
#import "FlickrUtil.h"

@interface AuthenticationWVCFlickr()

@property (nonatomic) NSString *authToken;
@property (nonatomic) NSString *authRequestPerm;
@property (nonatomic) NSString *authGrantedPerm;
@property (nonatomic) NSString *callbackBase;

@end

@implementation AuthenticationWVCFlickr

- (void)viewDidLoad {
    self.targetURL = [NSString stringWithFormat:@"https://www.flickr.com/services/oauth/authorize?oauth_token=%@&perms=%@", _authToken, _authRequestPerm];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods
- (void) setAuthToken:(NSString *)authToken permission:(NSString *)permission andCallbackBase:(NSString *)callbackBase {
    _authToken = authToken;
    _authRequestPerm = permission;
    _callbackBase = callbackBase;
}

#define mark - WebView Delegate Override
-(void) authenticationSuccess:(NSDictionary *)response {
    NSLog(@"Authentication Success");
}

-(void) authenticationFailure:(NSError *)error {
    NSLog(@"AUthentication Failure");
}

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
        NSString* pattern = [NSString stringWithFormat:@"%@?", _callbackBase];
        NSString* urlString = [[request URL] absoluteString];
        NSArray * UrlParts = [urlString componentsSeparatedByString:pattern];
        urlString = [UrlParts objectAtIndex:1];
        
        NSDictionary *response = [FlickrUtil parseURLResponse:urlString];

        if (!self.delegate || ![self.delegate respondsToSelector:@selector(authenticationSuccess:)]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"delegate authenticationSuccess not implemented"
                                         userInfo:nil];
            return NO;
        }

        [self.delegate authenticationSuccess:response];
        return NO;
    }
    return YES;
}
@end
