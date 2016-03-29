//
//  DisplayViewController.h
//  iOSSamples
//
//  Created by Joohae Kim on 2016. 3. 10..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SNSServices/SNSServiceDelegate.h>

@interface DisplayViewController : UIViewController <SNSServiceDelegate>

// Segue parameters
@property (strong, nonatomic) NSString *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
