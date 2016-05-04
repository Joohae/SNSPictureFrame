//
//  SNSServiceDelegate.h
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 13..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#ifndef SNSServiceDelegate_h
#define SNSServiceDelegate_h

#import <UIKit/UIKit.h>
#import "SNSImageSource.h"

@protocol SNSServiceDelegate <NSObject>

/*!
 SNS Service Error
 @param error   Reason of failure
 */
-(void) SNSServiceError:(NSError *)error;

#pragma mark - Service Delegates
/*!
 Fetch file list succeeded.
 @param fileList    An array of SNSImageSource
 */
-(void) SNSServiceFileListFetched:(NSArray<SNSImageSource *>*)fileList;

#pragma mark - Authentication Delegates
/*!
 Authentication required.
 @return reference of ViewController which WebView to authenticate will be inserted.
 */
-(UIViewController *) SNSWebAuthenticationRequired;

/*!
 Authentication failed.
 @param error   Reason of failure
 */
-(void) SNSWebAuthenticationFailed:(NSError *)error;


/*!
 Authentication succeeded.
 */
-(void) SNSWebAuthenticationSuccess;
@end

#endif /* SNSServiceDelegate_h */
