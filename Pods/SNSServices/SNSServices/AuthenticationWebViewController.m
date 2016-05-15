//
//  AuthenticationWebViewController.m
//  iOSSamples
//
//  Created by Joohae Kim on 2016. 3. 13..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "AuthenticationWebViewController.h"

@interface AuthenticationWebViewController ()

@end

@implementation AuthenticationWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_targetURL) {
        NSString *frameworkBundleID = @"kr.carrotbooks.SNSServices";
        NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
        if (! frameworkBundle) {
            frameworkBundle = [NSBundle mainBundle];
        }
        _targetURL = [frameworkBundle pathForResource:@"defaultpage" ofType:@"html"];
        NSLog(@"Target URL: %@", _targetURL);
    }
    // Do any additional setup after loading the view from its nib.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_targetURL]];
    _webView.delegate = self;
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) authenticationSuccess:(NSDictionary *)response {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Method authenticationSuccess is not implemented"
                                 userInfo:nil];
}

-(void) authenticationFailure:(NSError *)error {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Method authenticationSuccess is not implemented"
                                 userInfo:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Method authenticationSuccess is not implemented"
                                 userInfo:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Method authenticationSuccess is not implemented"
                                 userInfo:nil];
}

@end
