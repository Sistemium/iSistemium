//
//  STMClientData.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMClientData : STMComment

@property (nonatomic, retain) NSString * appVersion;
@property (nonatomic, retain) NSString * buildType;
@property (nonatomic, retain) NSString * deviceName;
@property (nonatomic, retain) NSString * devicePlatform;
@property (nonatomic, retain) NSData * deviceToken;
@property (nonatomic, retain) NSString * deviceTokenError;
@property (nonatomic, retain) NSDate * lastAuth;
@property (nonatomic, retain) NSString * locationServiceStatus;
@property (nonatomic, retain) NSString * notificationTypes;
@property (nonatomic, retain) NSString * systemVersion;
@property (nonatomic, retain) NSString * tokenHash;
@property (nonatomic, retain) NSData * deviceUUID;

@end
