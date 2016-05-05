//
//  SNSServiceManager.h
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 13..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SNSDeviceBase.h>

#define SNSServiceTitle         @"TITLE"
#define SNSServiceIcon          @"ICON"
#define SNSServiceDescription   @"DESCRIPTION"

typedef NS_ENUM(NSInteger, SNSServicesType) {
    SNSServiceVoid = -1,
    SNSServiceInstagram = 0,
    SNSServiceFlickr = 1,
    SNSServicePicasa = 2,
    SNSServiceFacebook = 3
};

@interface SNSServiceManager : NSObject

@property (nonatomic,weak) id<SNSServiceDelegate> delegate;

+(SNSServiceManager *)sharedManager;

-(void)requestFileListTo:(SNSServicesType)deviceType;

-(BOOL)hasDevice:(SNSServicesType)deviceType;
-(void)addDevice:(SNSDeviceBase *)device withType:(SNSServicesType)deviceType;
-(void)removeDevice:(SNSServicesType)deviceType;
-(void)removeAllDevices;

+(NSInteger)numberOfServices;
+(NSDictionary *)getServiceAt:(NSInteger)index;
+(SNSServicesType)getServiceByTitle:(NSString *)title;

@end
