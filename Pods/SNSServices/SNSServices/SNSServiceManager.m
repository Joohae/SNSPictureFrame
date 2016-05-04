//
//  SNSServiceManager.m
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 13..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#import "SNSServiceManager.h"

@interface SNSServiceManager()
{
    NSMutableDictionary *_devices;
    NSDictionary *_services;
    NSArray *_serviceKeys;
}
@end

@implementation SNSServiceManager

#pragma mark - 
-(void)requestFileListTo:(SNSServicesType)deviceType {
    if (![self hasDevice:deviceType]) {
        NSError *error = [NSError errorWithDomain:@"kr.carrotbooks.SNSServices"
                                             code:SNSServiceErrorDeviceNotFound
                                         userInfo:@{NSLocalizedDescriptionKey: @"Service not registerd"}];
        if (_delegate && [_delegate respondsToSelector:@selector(SNSServiceError:)]) {
            [_delegate SNSServiceError:error];
        }
        return;
    }
    
    SNSDeviceBase *theDevice = [_devices objectForKey:@(deviceType)];
    if (!theDevice.delegate && _delegate) {
        theDevice.delegate = _delegate;
    }
    [theDevice requestFileList];
    
}

#pragma mark - Devices
-(BOOL)hasDevice:(SNSServicesType)deviceType {
    SNSDeviceBase * response = [_devices objectForKey:@(deviceType)];
    return (response && ![response isEqual:[NSNull null]]);
}

-(void)addDevice:(SNSDeviceBase *)device withType:(SNSServicesType)deviceType {
    [_devices setObject:device forKey:@(deviceType)];
}

-(void)removeDevice:(SNSServicesType)deviceType {
    [_devices removeObjectForKey:@(deviceType)];
}

-(void)removeAllDevices {
    [_devices removeAllObjects];
}

#pragma mark - Services
+(NSInteger)numberOfServices {
    return SNSServiceManager.sharedManager.numberOfServices;
}

+(NSDictionary *)getServiceAt:(NSInteger)index {
    return [SNSServiceManager.sharedManager getServiceAt:index];
}

+(SNSServicesType)getServiceByTitle:(NSString *)title {
    SNSServicesType response = SNSServiceVoid;
    for (NSNumber *type in [SNSServiceManager.sharedManager getServiceKeys]) {
        if ([title isEqualToString:[SNSServiceManager.sharedManager getServiceAt:[type integerValue]][SNSServiceTitle]]) {
            response = [type integerValue];
            break;
        }
    }
    return response;
}

#pragma mark - Sub-methods
-(NSInteger)numberOfServices {
    return _services.count;
}

-(NSDictionary *)getServiceAt:(NSInteger)index {
    return [_services objectForKey:[_serviceKeys objectAtIndex:index]];
}

-(NSArray *)getServiceKeys {
    return _serviceKeys;
}

#pragma mark - Singleton
-(id)init {
    if (self = [super init]) {
        _devices = [[NSMutableDictionary alloc] init];
        _services = @{
                      @(SNSServiceInstagram): @{ SNSServiceTitle: @"Instagram",
                                                 SNSServiceIcon: @"icon-sns-instagram.png",
                                                 SNSServiceDescription: @"Instagram description" },
                      @(SNSServiceFlickr)   : @{ SNSServiceTitle: @"Flickr",
                                                 SNSServiceIcon: @"icon-sns-flickr.png",
                                                 SNSServiceDescription: @"Flickr description" },
                      @(SNSServicePicasa)   : @{ SNSServiceTitle: @"Picasa",
                                                 SNSServiceIcon: @"icon-sns-picasa.png",
                                                 SNSServiceDescription: @"Picasa description" },
                      /*@(SNSServiceFacebook) : @{ SNSServiceTitle: @"Facebook",
                       SNSServiceIcon: @"icon-sns-facebook.png",
                       SNSServiceDescription: @"Facebook description" }*/
                      };
        _serviceKeys = [_services allKeys];
    };
    
    return self;
}

+(SNSServiceManager *)sharedManager {
    static SNSServiceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}
@end
