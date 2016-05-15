//
//  SNSDeviceInstagram.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 13..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "SNSDeviceInstagram.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+Helper.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const INSTAGRAM_API_BASE = @"https://api.instagram.com/v1";
static NSString *const KEY_INSTAGRAM_ACCESS_TOKEN = @"KEY_INSTAGRAM_ACCESS_TOKEN";
#define INSTAGRAM_NUMBER_OF_ITEMS_PER_PAGE (@"2")  // 33 is the maximum numer of item limits

@interface SNSDeviceInstagram ()
{
    AuthenticationWVCInstagram *_webviewController;
    NSString *_accessToken;
}

@property (nonatomic) NSString *clientId;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSString *callbackBase;

@end

@implementation SNSDeviceInstagram

- (void) setClinetID:(NSString *)clientId
              secret:(NSString *)clientSecret
     andCallbackBase:(NSString *)callbackBase {
    _clientId = clientId;
    _clientSecret = clientSecret;
    _callbackBase = callbackBase;
}

- (BOOL) hasAuthentication {
    if (!_accessToken) {
        _accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_INSTAGRAM_ACCESS_TOKEN];
    }
    return (_accessToken != nil);
}

- (void) requestFileList {
//    NSError *error;
    if (![self hasAuthentication]) {
        [self addAuthenticationViews];
        return;
    }
    
    [self doRequestFileList:[NSMutableArray new]
                   forMaxID:nil];
}

- (void) doRequestFileList:(NSMutableArray *)imageList
                  forMaxID:(NSString * _Nullable)max_id {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", INSTAGRAM_API_BASE, @"users/self/media/recent"];
    NSURL *URL = [NSURL URLWithString:urlString];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    [param setObject:_accessToken forKey:@"access_token"];
    [param setObject:INSTAGRAM_NUMBER_OF_ITEMS_PER_PAGE forKey:@"count"];
    if (max_id) {
        [param setObject:max_id forKey:@"max_id"];
    }

    [manager GET:URL.absoluteString
      parameters:param progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             for (NSDictionary *item in responseObject[@"data"]) {
                 SNSImageSource *imageSource = [SNSImageSource new];
                 imageSource.text = [item objectForKeyPath:@"caption.text"];
                 @try {
                     imageSource.createdEpoch = [[item objectForKey:@"created_time"] integerValue];
                 }
                 @catch (NSException *ex){
                     imageSource.createdEpoch = [[NSDate new] timeIntervalSince1970];
                 }
                 
                 imageSource.imageUrl        = [item objectForKeyPath:@"images.standard_resolution.url"];
                 imageSource.imageWidth      = [[item objectForKeyPath:@"images.standard_resolution.width"] doubleValue];
                 imageSource.imageHeight     = [[item objectForKeyPath:@"images.standard_resolution.height"] doubleValue];;

                 imageSource.thumbnailUrl    = [item objectForKeyPath:@"images.thumbnail.url"];
                 imageSource.thumbnailWidth  = [[item objectForKeyPath:@"images.thumbnail.width"] doubleValue];
                 imageSource.thumbnailHeight = [[item objectForKeyPath:@"images.thumbnail.height"] doubleValue];;
                 
                 [imageList addObject:imageSource];
             }

             if (![responseObject objectForKeyPath:@"pagination.next_max_id"]) {
                 if (self.delegate && [self.delegate respondsToSelector:@selector(SNSServiceFileListFetched:)]) {
                     [self.delegate SNSServiceFileListFetched:imageList];
                 }
             } else {
                 [self doRequestFileList:imageList
                                forMaxID:[responseObject objectForKeyPath:@"pagination.next_max_id"]];
             }
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             NSLog(@"Error code: %d", error.code);
             if (error.code == -1011) {
                 _accessToken = nil;
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_INSTAGRAM_ACCESS_TOKEN];
             }
             if (self.delegate && [self.delegate respondsToSelector:@selector(SNSServiceError:)]) {
                 [self.delegate SNSServiceError:error];
             }
             NSLog(@"Error: %@", error);
         }];
}



/// Internal Methods
#pragma mark - Authentication
- (void) addAuthenticationViews {
    UIViewController *parentVC = [self.delegate SNSWebAuthenticationRequired];

    NSString *frameworkBundleID = @"kr.carrotbooks.SNSServices";
    NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
    
    _webviewController = [[AuthenticationWVCInstagram alloc]
                          initWithNibName:@"AuthenticationWebViewController"
                          bundle:frameworkBundle];
    [_webviewController setDelegate:self];
    [_webviewController setClinetID:_clientId secret:_clientSecret andCallbackBase:_callbackBase];
    
    [parentVC addChildViewController:_webviewController];
    _webviewController.view.frame = parentVC.view.frame;

    [parentVC.view addSubview:_webviewController.view];
    [_webviewController didMoveToParentViewController:parentVC];
}

- (void) removeAuthenticationViews {
    [_webviewController.view removeFromSuperview];
    [_webviewController removeFromParentViewController];
    _webviewController = nil;
}

#pragma mark Authentication Delegate Methods
- (void) authenticationSuccess:(NSDictionary *)response {
    _accessToken = response[@"ACCESS_TOKEN"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_accessToken) {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_accessToken forKey:KEY_INSTAGRAM_ACCESS_TOKEN];
            
            [self removeAuthenticationViews];
            [self.delegate SNSWebAuthenticationSuccess];
        }
    });
}

- (void) authenticationFailure:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeAuthenticationViews];
        [self.delegate SNSWebAuthenticationFailed:error];
    });
}
@end
NS_ASSUME_NONNULL_END
