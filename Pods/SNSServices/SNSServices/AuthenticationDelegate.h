//
//  AuthenticationDelegate.h
//  SNSServices
//
//  Created by Joohae Kim on 2016. 3. 14..
//  Copyright © 2016년 Joohae Kim. All rights reserved.
//

#ifndef AuthenticationDelegate_h
#define AuthenticationDelegate_h

@protocol AuthenticationDelegate <NSObject>

- (void) authenticationSuccess:(NSDictionary *)response;
- (void) authenticationFailure:(NSError *)error;

@end

#endif /* AuthenticationDelegate_h */
