//
//  DisplayViewController.m
//  iOSSamples
//
//  Created by Joohae Kim on 2016. 3. 10..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "DisplayViewController.h"

#import <SNSServices/SNSDeviceBase.h>
#import <SNSServices/SNSDeviceInstagram.h>
#import <SNSServices/SNSDeviceFlickr.h>

#import <SNSServices/AuthenticationWebViewController.h>

// Temporary
#import <SNSServices/AuthenticationWVCInstagram.h>
#import <SNSServices/AuthenticationWVCFlickr.h>
// -- Temporary

#import "ImageCache.h"

#define INSTAGRAM_CLIENT_ID     @"f4a8ac5d3c284448b7db0ad3d6912138"
#define INSTAGRAM_CLIENT_SECRET @"91868ff829874d37a58a9a9319f2c03b"
#define INSTAGRAM_REDIRECT_URL  @"http://www.carrotbooks.kr"

#define FLICKR_CLIENT_KEY       @"3f093987e018fbfbbbe8a4ca87608a2b"
#define FLICKR_CLIENT_SECRET    @"d509f29e4fb1f322"
#define FLICKR_REDIRECT_URL     @"frd509f29e4fb1f322"   // reuse client secret with prefix fr

@interface DisplayViewController ()
{
    NSMutableOrderedSet* _imageList;
    BOOL _slideMode;
    BOOL _holdTimer;
    long _intervalCounter;
    int _retryCount;
    
    SNSServicesType _currentService;
}

@property (weak, nonatomic) IBOutlet UILabel *passedMessage;

@end

@implementation DisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_passedMessage setText:_message];
    _imageList = [[NSMutableOrderedSet alloc] init];
    
    _currentService = [SNSServiceManager getServiceByTitle:_message];
    
    [SNSServiceManager sharedManager].delegate = self;
    _retryCount = 0;
}

-(void)viewDidAppear:(BOOL)animated {
    switch (_currentService) {
        case SNSServiceInstagram:
            if (![[SNSServiceManager sharedManager] hasDevice:_currentService]) {
                SNSDeviceInstagram *instagram = [[SNSDeviceInstagram alloc] init];
                [instagram setClinetID:INSTAGRAM_CLIENT_ID secret:INSTAGRAM_CLIENT_SECRET andCallbackBase:INSTAGRAM_REDIRECT_URL];
                [[SNSServiceManager sharedManager] addDevice:instagram withType:_currentService];
            }
            break;
        case SNSServiceFlickr:
            if (![[SNSServiceManager sharedManager] hasDevice:_currentService]) {
                SNSDeviceFlickr *flickr = [[SNSDeviceFlickr alloc] init];
                [flickr setClinetKey:FLICKR_CLIENT_KEY secret:FLICKR_CLIENT_SECRET andCallbackBase:FLICKR_REDIRECT_URL];
                [[SNSServiceManager sharedManager] addDevice:flickr withType:_currentService];
            }
            break;
        case SNSServiceFacebook:
        case SNSServicePicasa:
            
        case SNSServiceVoid:
        default:
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                       message:@"The service is not implemented or unknown."
                                      delegate:self
                             cancelButtonTitle:@"Cancel" otherButtonTitles: nil]
             show];
            return;
            break;
    }
    
    //  Send the request
    [[SNSServiceManager sharedManager] requestFileListTo:_currentService];
}

-(void)viewDidDisappear:(BOOL)animated {
    _slideMode = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showImageAt:(NSInteger)index {
    if (index >= _imageList.count) {
        return;
    }
    
    SNSImageSource *imageSource = [_imageList objectAtIndex:index];
    _holdTimer = YES;
    [[ImageCache sharedManager] requestImage:imageSource.imageUrl
                                     success:^(UIImage *image) {
                                         _backImageView.image = image;
                                         
                                         [self switchImage];
                                         
                                         NSString *imageText = [imageSource text];
                                         if (!imageText || [imageText isEqual:[NSNull null]]) {
                                             imageText = @"";
                                         }
                                         [_passedMessage setText:imageText];

                                         _holdTimer = NO;
                                     } failure:^(NSError *error) {
                                         NSLog(@"Image download error: %@", error);
                                         _holdTimer = NO;
                                     }];
}

-(void)switchImage {
    _imageView.alpha = 1.0f;
    _backImageView.alpha = 0.0f;
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         _imageView.alpha = 0.0f;
                         _backImageView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {
                         _imageView.image = _backImageView.image;
                         _backImageView.image = nil;
                         
                         _imageView.alpha = 1.0f;
                         _backImageView.alpha = 0.0f;
                     }];
}

#pragma mark - Timers to slide
- (void) createTimer
{
    _slideMode = YES;
    _intervalCounter = 0;
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
}

- (void) timerHandler:(NSTimer *)timer {
    static int index = 1;

    if (!_slideMode) {
        [timer invalidate];
        return;
    }
    
    if (_holdTimer) {
        return;
    }
    
    _intervalCounter++;
    if (_intervalCounter % _interval) {
        return;
    }

    [self showImageAt:index];
    index = (index + 1) % _imageList.count;
}

#pragma mark - SNS Service Delegates

-(void) SNSServiceFileListFetched:(NSArray<SNSImageSource *>*)fileList {
    NSLog(@"File list has fetched: %lu", (unsigned long)fileList.count);
    
    _retryCount = 0;
    
    [_imageList addObjectsFromArray:fileList];
    
    NSLog(@"Number of images in the set: %lu", (unsigned long)_imageList.count);
    [self showImageAt:0];
    [self createTimer];
}

-(void) SNSServiceError:(NSError *)error {
    NSLog(@"SNSPictureFrame-SNSServiceError: %@", error);
    if (error.code == -1011 && _retryCount < 3) { // bad request
        [[SNSServiceManager sharedManager] requestFileListTo:_currentService];
        return;
    }
    [[[UIAlertView alloc] initWithTitle:@"SNSServiceError"
                                message:[NSString stringWithFormat:@"%@", [[error userInfo] valueForKey:NSLocalizedDescriptionKey]]
                               delegate:self
                      cancelButtonTitle:@"Cancel" otherButtonTitles:nil]
     show];
}

-(UIViewController *) SNSWebAuthenticationRequired {
    return self;
}

-(void) SNSWebAuthenticationFailed:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"SNSWebAuthenticationFailed"
                                message:[NSString stringWithFormat:@"%@", [[error userInfo] valueForKey:NSLocalizedDescriptionKey]]
                               delegate:self
                      cancelButtonTitle:@"Cancel" otherButtonTitles:nil]
     show];
    NSLog(@"SNSWebAuthenticationFailed: %@", error);
}

-(void) SNSWebAuthenticationSuccess {
    NSLog(@"SNSWebAuthenticationSuccess");
    //  Send the request
    [[SNSServiceManager sharedManager] requestFileListTo:_currentService];
}

@end
