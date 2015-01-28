//
//  STAuthController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMRequestAuthenticatable.h"

@interface STMAuthController : NSObject <STMRequestAuthenticatable>

typedef enum STMAuthState {
    STMAuthEnterPhoneNumber,
    STMAuthEnterSMSCode,
    STMAuthNewSMSCode,
    STMAuthSuccess
} STMAuthState;


@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *tokenHash;
@property (nonatomic, strong) NSDate *lastAuth;
@property (nonatomic) STMAuthState controllerState;


+ (STMAuthController *)authController;


- (void)sendPhoneNumber:(NSString *)phoneNumber;
- (void)sendSMSCode:(NSString *)SMSCode;
- (void)requestNewSMSCode;
- (void)logout;

- (NSURLRequest *)authenticateRequest:(NSURLRequest *)request;

@end
