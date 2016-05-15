//
//  SNSDeviceFlickr.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 4. 7..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

/*!
 You may need to register
    1. an account of Flickr Developer Account: https://www.flickr.com/services/developer
    2. an application: https://www.flickr.com/services/apps/create/apply/
 */

#import "SNSDeviceFlickr.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+Helper.h"
#import "CryptoUtil.h"
#import "FlickrUtil.h"

static NSString *const FLICKR_API_BASE          = @"https://www.flickr.com/services";
static NSString *const KEY_FLICKR_ACCESS_TOKEN  = @"KEY_INSTAGRAM_ACCESS_TOKEN";
static NSString *const KEY_FLICKR_AUTH_TOKEN    = @"KEY_FLICKR_AUTH_TOKEN";
static NSString *const ERROR_DOMAIN             = @"kr.carrotbooks.SNSService.SNSDeviceFlickr";

//  Keys for accessing response data from Flickr
static NSString *const KEY_OAUTH_NONCE          = @"oauth_nonce";
static NSString *const KEY_OAUTH_TIMESTAMP      = @"oauth_timestamp";
static NSString *const KEY_OAUTH_CONSUMER_KEY   = @"oauth_consumer_key";
static NSString *const KEY_OAUTH_SIGNATURE_METHOD = @"oauth_signature_method";
static NSString *const KEY_OAUTH_VERSION        = @"oauth_version";
static NSString *const KEY_OAUTH_CALLBACK       = @"oauth_callback";
static NSString *const KEY_OAUTH_SIGNATURE      = @"oauth_signature";

static NSString *const KEY_OAUTH_TOKEN          = @"oauth_token";
static NSString *const KEY_OAUTH_TOKEN_SECRET   = @"oauth_token_secret";
static NSString *const KEY_OAUTH_CALLBACK_CONFIRMED = @"oauth_callback_confirmed";
static NSString *const KEY_OAUTH_VERIFIER       = @"oauth_verifier";

@interface SNSDeviceFlickr ()
{
    AuthenticationWVCFlickr *_webviewController;
}

@property (nonatomic) NSString *clientKey;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSString *clientCallback;
@property (nonatomic) NSString *clientAuthTokenSecret;
@property (nonatomic) NSString *clientAuthToken;
@property (nonatomic) NSString *accessToken;

@end

@implementation SNSDeviceFlickr
- (void) setClinetKey:(NSString *)clientKey secret:(NSString *)clientSecret andCallbackBase:(NSString *)callbackBase {
    _clientKey = clientKey;
    _clientSecret = clientSecret;
    _clientCallback = [NSString stringWithFormat:@"%@://auth", callbackBase];
    if (!_clientAuthTokenSecret) {
        _clientAuthTokenSecret = @"";
    }
}

- (BOOL) hasAuthentication {
    // Save the access token
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _accessToken = [defaults objectForKey:KEY_FLICKR_ACCESS_TOKEN];
    _clientAuthToken = [defaults objectForKey:KEY_FLICKR_AUTH_TOKEN];
    
    return (_accessToken != nil && _clientAuthToken != nil);
}

/*!
 Request request media file list to SNSService
 */
- (void) requestFileList {
    if (![self hasAuthentication]) {
        // Step 1.
        [self requestRequestToken:^(NSString *response) {
            // Step 2. and 3.
            [self addAuthenticationViews];
        } failure:^(NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(SNSServiceError:)]) {
                [self.delegate SNSServiceError:error];
            }
        }];
        return;
    }
    
    NSLog(@"REQUESTING FILE LIST");
    
    [self doRequestFileList:[NSMutableArray<SNSImageSource *> new] ofPage:1];
}

-(void) doRequestFileList:(NSMutableArray<SNSImageSource *> *)imageList ofPage:(NSInteger) pageNo
{
    NSMutableDictionary *params = [self createRequestParam];
    [params setObject:@"flickr.photos.search" forKey:@"method"];
    [params setObject:@"me" forKey:@"user_id"];
    // refer https://www.flickr.com/services/api/flickr.photos.search.html for detail search options.
    [params setObject:@"date-posted-desc" forKey:@"sort"];
    [params setObject:@"photos" forKey:@"media"];
    [params setObject:@"url_t,url_o,description,date_upload,date_taken,last_update,media" forKey:@"extras"];
    [params setObject:@(pageNo) forKey:@"page"];
    
    NSString *baseString = [NSString stringWithFormat:@"%@/%@",FLICKR_API_BASE, @"rest"];
    NSString *signature = [self getSignatureOf:baseString params:params withTokenScret:_accessToken];
    
    [params setObject:signature forKey:KEY_OAUTH_SIGNATURE];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", baseString, [self convertDictionaryToUrlString:params withBaseUrl:baseString]];
    NSURL *URL = [NSURL URLWithString:urlString];
    
    [self requestWithURL:URL
          forResponsType:@"text/json"
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     NSDictionary *dict = responseObject;
                     for (NSDictionary *item in [dict objectForKeyPath:@"photos.photo"]) {
                         SNSImageSource *imageSource = [SNSImageSource new];
                         
                         NSMutableString *titleText = [NSMutableString new];
                         [titleText appendFormat:@"%@: ", [item objectForKey:@"title"]];
                         if ([item objectForKeyPath:@"description._content"]) {
                             [titleText appendString:[item objectForKeyPath:@"description._content"]];
                         }
                         imageSource.text = [NSString stringWithString:titleText];
                         
                         @try {
                             imageSource.createdEpoch = [[item objectForKey:@"date_upload"] integerValue];
                         }
                         @catch (NSException *ex){
                             imageSource.createdEpoch = [[NSDate new] timeIntervalSince1970];
                         }
                         
                         imageSource.imageUrl        = [item objectForKeyPath:@"url_o"];
                         imageSource.imageWidth      = [[item objectForKeyPath:@"width_o"] doubleValue];
                         imageSource.imageHeight     = [[item objectForKeyPath:@"height_o"] doubleValue];;
                         
                         imageSource.thumbnailUrl    = [item objectForKeyPath:@"url_t"];
                         imageSource.thumbnailWidth  = [[item objectForKeyPath:@"width_t"] doubleValue];
                         imageSource.thumbnailHeight = [[item objectForKeyPath:@"height_t"] doubleValue];;
                         
                         [imageList addObject:imageSource];
                     }
                     
                     NSInteger lastPage = [[dict objectForKeyPath:@"photos.pages"] integerValue];
                     if (pageNo < lastPage) {
                         [self doRequestFileList:imageList ofPage:pageNo+1];
                     } else {
                         if (self.delegate && [self.delegate respondsToSelector:@selector(SNSServiceFileListFetched:)]) {
                             [self.delegate SNSServiceFileListFetched:imageList];
                         }
                     }
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     if (imageList.count > 0) {
                         // Send collected image list
                         if (self.delegate && [self.delegate respondsToSelector:@selector(SNSServiceFileListFetched:)]) {
                             [self.delegate SNSServiceFileListFetched:imageList];
                         }
                     }
                     if (self.delegate && [self.delegate respondsToSelector:@selector(SNSServiceError:)]) {
                         [self.delegate SNSServiceError:error];
                     }
                     NSLog(@"Fetch file list failed: %@", error);
                 }];
}

-(void)requestWithURL:(NSURL *)URL
       forResponsType:(NSString *)responseType
              success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)) success
              failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)) failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if ([responseType isEqualToString:@"text/json"]) {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    } else {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        if ([responseType isEqualToString:@"text/xml"]) {
            manager.responseSerializer.acceptableContentTypes =  [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/xml"];
        } else {
            // else text/plain
        }
    }
    
    [manager GET:URL.absoluteString
      parameters:@{}
        progress:nil
         success:success
         failure:failure];
}

#pragma mark - Authentication
/*!
 Step 1. Signing Requests and Getting a Request Token
 */
- (void) requestRequestToken:(void (^)(NSString *)) success
                     failure:(void (^)(NSError *)) failure
{
    NSMutableDictionary *params = [self createBaseParam];
    [params setObject:[[CryptoUtil sharedManager] urlEncode:_clientCallback] forKey:KEY_OAUTH_CALLBACK];
    
    NSString *baseString = [NSString stringWithFormat:@"%@/%@",FLICKR_API_BASE, @"oauth/request_token"];
    NSString *signature = [self getSignatureOf:baseString params:params withTokenScret:@""];
    
    [params setObject:signature forKey:KEY_OAUTH_SIGNATURE];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", baseString, [self convertDictionaryToUrlString:params withBaseUrl:baseString]];
    NSURL *URL = [NSURL URLWithString:urlString];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    [manager GET:URL.absoluteString
      parameters:param progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             NSError *error = nil;
             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             NSDictionary *params = [FlickrUtil parseURLResponse:responseString];
             if ([params count] < 1) {
                 error = [NSError errorWithDomain:ERROR_DOMAIN
                                             code:kCFErrorHTTPParseFailure
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Unable to parse response",
                                                    @"response": responseString
                                                    }];
                 failure(error);
                 return;
             }
             
             if (params[KEY_OAUTH_CALLBACK_CONFIRMED]
                 && [params[KEY_OAUTH_CALLBACK_CONFIRMED] isEqualToString:@"true"]
                 && params[KEY_OAUTH_TOKEN]) {
                 _clientAuthToken = params[KEY_OAUTH_TOKEN];
                 _clientAuthTokenSecret = params[KEY_OAUTH_TOKEN_SECRET];
                 success(_clientAuthToken);
             } else {
                 error = [NSError errorWithDomain:ERROR_DOMAIN
                                             code:kCFErrorHTTPParseFailure
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Unable to fetch oauth_token",
                                                    @"response": responseString
                                                    }];
                 failure(error);
             }
             
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             failure(error);
         }];
}

// TODO: This method could be refactoring, all the same methods SNSDevice* have the common codes.
/*!
 Step 2. Getting the User Authorization using web view
        The web view using delegates authenticationSuccess: and authenticationFailure:
 */
- (void) addAuthenticationViews {
    UIViewController *parentVC = [self.delegate SNSWebAuthenticationRequired];
    
    NSString *frameworkBundleID = @"kr.carrotbooks.SNSServices";
    NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
    
    _webviewController = [[AuthenticationWVCFlickr alloc]
                          initWithNibName:@"AuthenticationWebViewController"
                          bundle:frameworkBundle];
    [_webviewController setDelegate:self];
    [_webviewController setAuthToken:_clientAuthToken permission:FLICKR_PERMISSION_WRITE andCallbackBase:_clientCallback];
    
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

/*!
 Step 3. Exchanging the Request Token for an Access Token
 NOTE: Step 2. is done in webview. refer addAuthenticationViews
 */
-(void) requestAccessTokenWith:(NSString *)requestToken
                      verifier:(NSString *)oauthVerifier
                       success:(void (^)(NSDictionary *)) success
                       failure:(void (^)(NSError *)) failure
{
    NSMutableDictionary *params = [self createBaseParam];
    [params setObject:oauthVerifier forKey:KEY_OAUTH_VERIFIER];
    [params setObject:_clientAuthToken forKey:KEY_OAUTH_TOKEN];
    
    NSString *baseString = [NSString stringWithFormat:@"%@/%@",FLICKR_API_BASE, @"oauth/access_token"];
    NSString *signature = [self getSignatureOf:baseString params:params withTokenScret:_clientAuthTokenSecret];
    
    NSLog(@"Client auth token secret: %@", _clientAuthTokenSecret);
    [params setObject:signature forKey:KEY_OAUTH_SIGNATURE];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", baseString, [self convertDictionaryToUrlString:params withBaseUrl:baseString]];
    NSURL *URL = [NSURL URLWithString:urlString];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    [manager GET:URL.absoluteString
      parameters:param progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             NSError *error = nil;
             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             NSDictionary *params = [FlickrUtil parseURLResponse:responseString];
             
             NSLog(@"Response of access_token: %@", responseString);
             
             if ([params count] < 1) {
                 error = [NSError errorWithDomain:ERROR_DOMAIN
                                             code:kCFErrorHTTPParseFailure
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Unable to parse response",
                                                    @"response": responseString
                                                    }];
                 failure(error);
                 return;
             }
             success(params);
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             failure(error);
         }];
}

#pragma mark Authentication Delegate Methods
- (void) authenticationSuccess:(NSDictionary *)response {
    NSLog(@"Authentication succeeded: %@", response);
    
    [self removeAuthenticationViews];
    
    if (response.count < 1
        || !response[KEY_OAUTH_TOKEN]
        || !response[KEY_OAUTH_VERIFIER]) {
        NSError *error;
        error = [NSError errorWithDomain:ERROR_DOMAIN
                                    code:kCFURLErrorCannotParseResponse
                                userInfo:@{
                                           NSLocalizedDescriptionKey: @"Unable to fetch oauth_token",
                                           @"response": @""
                                           }];
        return;
    }
    
    [self requestAccessTokenWith:response[KEY_OAUTH_TOKEN]
                        verifier:response[KEY_OAUTH_VERIFIER]
                         success:^(NSDictionary *response) {
                             NSLog(@"Got access token: %@", response);
                             /* A sample response
                             {
                                 fullname = "Joohae%20Kim";
                                 "oauth_token" = "00000000000000000-0000000000000000";
                                 "oauth_token_secret" = 00000000000000000;
                                 "user_nsid" = "00000000000";
                                 username = "Joohae%20Kim";
                             }
                              
                              Note: You may need to unescape
                              */
                             _accessToken = response[KEY_OAUTH_TOKEN_SECRET]; // access token for the case
                             _clientAuthToken = response[KEY_OAUTH_TOKEN];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (_accessToken) {
                                     // Save the access token
                                     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                                     [defaults setObject:_accessToken forKey:KEY_FLICKR_ACCESS_TOKEN];
                                     [defaults setObject:_clientAuthToken forKey:KEY_FLICKR_AUTH_TOKEN];
                                     
                                     // Call the delegate method
                                     [self.delegate SNSWebAuthenticationSuccess];
                                 }
                             });
                         } failure:^(NSError *error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (self.delegate && [self.delegate respondsToSelector:@selector(SNSWebAuthenticationFailed:)]) {
                                     [self.delegate SNSWebAuthenticationFailed:error];
                                 } else {
                                     @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                                                    reason:@"Delegation undefined and an error raised"
                                                                  userInfo:@{
                                                                             NSLocalizedDescriptionKey: error.localizedDescription
                                                                             }];
                                 }
                             });
                             return;
                         }];
}

- (void) authenticationFailure:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeAuthenticationViews];
        [self.delegate SNSWebAuthenticationFailed:error];
    });
}

#pragma mark Private methods
/*!
 Create a NSMutableDictionary of common parameters for request
 */
- (NSMutableDictionary *) createBaseParam {
    NSMutableDictionary *response = [NSMutableDictionary new];
    [response setObject:[FlickrUtil createNonce] forKey:KEY_OAUTH_NONCE];
    [response setObject:[[CryptoUtil sharedManager] getTimeStampString] forKey:KEY_OAUTH_TIMESTAMP];
    [response setObject:_clientKey forKey:KEY_OAUTH_CONSUMER_KEY];
    [response setObject:@"HMAC-SHA1" forKey:KEY_OAUTH_SIGNATURE_METHOD];
    [response setObject:@"1.0" forKey:KEY_OAUTH_VERSION];
    return response;
}

- (NSMutableDictionary *) createRequestParam {
    NSMutableDictionary *response = [self createBaseParam];
    [response setObject:_clientAuthToken forKey:KEY_OAUTH_TOKEN];
    [response setObject:@"1" forKey:@"nojsoncallback"];
    [response setObject:@"json" forKey:@"format"];
    return response;
}

/*!
 Convert Dictionary to URL String
 @param params      parameter dictionary
 @param baseUrl     url as a prefix of URL string
 */
- (NSString *) convertDictionaryToUrlString:(NSDictionary *)params withBaseUrl:(NSString *)baseUrl {
    NSString *response;
    NSMutableString *baseString = [NSMutableString new];
    
    NSArray *keys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        [baseString appendFormat:@"%@=%@&", key, [params objectForKey:key]];
    }
    
    if ([baseString length] > 0) {
        response = [baseString substringToIndex:[baseString length] - 1];
    }
    
    return response;
}

/*!
 Calculate Flickr signature
 @param baseUrl     url as a prefix of URL string
 @param params      parameter dictionary
 @param tokenSecret token secret
 */
- (NSString *) getSignatureOf:(NSString *)baseUrl params:(NSDictionary *)params withTokenScret:(NSString *)tokenSecret {
    NSString *response;
    
    NSString *encodedUrl = [[CryptoUtil sharedManager] urlEncode:baseUrl];
    NSString *baseData   = [[CryptoUtil sharedManager] urlEncode:[self convertDictionaryToUrlString:params withBaseUrl:baseUrl]];
    
    response = [NSString stringWithFormat:@"GET&%@&%@", encodedUrl, baseData];
    response = [[CryptoUtil sharedManager] hmacsha1:response secret:[NSString stringWithFormat:@"%@&%@", _clientSecret, tokenSecret]];
    response = [[CryptoUtil sharedManager] urlEncode:response];
    
    return response;
}
@end
