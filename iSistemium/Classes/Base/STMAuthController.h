//
//  STAuthController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMRequestAuthenticatable.h"
#import "STMUserDefaults.h"


@interface STMAuthController : NSObject <STMRequestAuthenticatable>

typedef NS_ENUM(NSUInteger, STMAuthState) {
    STMAuthStarted,
    STMAuthEnterPhoneNumber,
    STMAuthEnterSMSCode,
    STMAuthNewSMSCode,
    STMAuthRequestRoles,
    STMAuthSuccess
};

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *tokenHash;
@property (nonatomic, strong) NSDate *lastAuth;
@property (nonatomic, strong) NSArray *stcTabs;
@property (nonatomic, strong) NSString *iSisDB;

@property (nonatomic) STMAuthState controllerState;


+ (STMAuthController *)authController;


- (BOOL)sendPhoneNumber:(NSString *)phoneNumber;
- (BOOL)sendSMSCode:(NSString *)SMSCode;
- (BOOL)requestNewSMSCode;
- (BOOL)requestRoles;
- (void)checkPhoneNumber;

- (void)logout;

- (NSURLRequest *)authenticateRequest:(NSURLRequest *)request;

@end
