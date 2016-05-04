//
//  SNSImageSource.h
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 23..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSImageSource : NSObject
@property (nonatomic,strong) NSString *text;

@property (nonatomic,strong) NSString *thumbnailUrl;
@property (nonatomic,assign) double    thumbnailWidth;
@property (nonatomic,assign) double    thumbnailHeight;

@property (nonatomic,strong) NSString *imageUrl;
@property (nonatomic,assign) double    imageWidth;
@property (nonatomic,assign) double    imageHeight;

@property (nonatomic,assign) NSUInteger createdEpoch;
@end
