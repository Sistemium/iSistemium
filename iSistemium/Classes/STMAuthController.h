//
//  STAuthController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STMAuthController : NSObject

typedef enum STAuthState {
    STAuthEnterPhoneNumber,
    STAuthEnterSMSCode,
    STAuthNewSMSCode,
    STAuthSuccess
} STAuthState;


@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic) STAuthState controllerState;


+ (STMAuthController *)authController;


- (void)sendPhoneNumber:(NSString *)phoneNumber;
- (void)sendSMSCode:(NSString *)SMSCode;
- (void)requestNewSMSCode;
- (void)logout;

@end
