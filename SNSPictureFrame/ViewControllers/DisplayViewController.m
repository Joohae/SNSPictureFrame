//
//  DisplayViewController.m
//  iOSSamples
//
//  Created by Joohae Kim on 2016. 3. 10..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "DisplayViewController.h"
#import <SNSServices/SNSDeviceInstagram.h>
#import <SNSServices/AuthenticationWVCInstagram.h>

#import "ImageCache.h"

#define INSTAGRAM_CLIENT_ID     @"f4a8ac5d3c284448b7db0ad3d6912138"
#define INSTAGRAM_CLIENT_SECRET @"91868ff829874d37a58a9a9319f2c03b"
#define INSTAGRAM_REDIRECT_URL  @"http://www.carrotbooks.kr"

@interface DisplayViewController ()
{
    NSMutableOrderedSet* _imageList;
    BOOL _slideMode;
    BOOL _holdTimer;
    long _intervalCounter;
}

@property (weak, nonatomic) IBOutlet UILabel *passedMessage;

@end

@implementation DisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_passedMessage setText:_message];
    _imageList = [[NSMutableOrderedSet alloc] init];
    
}

-(void)viewDidAppear:(BOOL)animated {
    SNSDeviceInstagram *instagram = [[SNSDeviceInstagram alloc] init];
    [instagram setClinetID:INSTAGRAM_CLIENT_ID secret:INSTAGRAM_CLIENT_SECRET andCallbackBase:INSTAGRAM_REDIRECT_URL];
    [instagram setDelegate:self];
    [instagram requestFileList];
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
                                         _imageView.image = image;
                                         
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
    /*
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageSource.imageUrl]];
    if (!imageData || [imageData isEqual:[NSNull null]]) {
        return;
    }
    _imageView.image = [UIImage imageWithData:imageData];
    
    NSString *imageText = [imageSource text];
    if (!imageText || [imageText isEqual:[NSNull null]]) {
        imageText = @"";
    }
    [_passedMessage setText:imageText];
     */
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
    [_imageList addObjectsFromArray:fileList];
    
    NSLog(@"Number of images in the set: %lu", (unsigned long)_imageList.count);
    [self showImageAt:0];
    [self createTimer];
}

-(void) SNSServiceError:(NSError *)error {
    NSLog(@"Error: %@", [[error userInfo] valueForKey:NSLocalizedDescriptionKey]);
}

-(UIViewController *) SNSWebAuthenticationRequired {
    return self;
}

-(void) SNSWebAuthenticationFailed:(NSError *)error {
    NSLog(@"SNSWebAuthenticationFailed: %@", error);
}

-(void) SNSWebAuthenticationSuccess {
    NSLog(@"SNSWebAuthenticationSuccess");
}

@end
