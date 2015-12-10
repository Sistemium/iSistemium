//
//  STMClientData+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMClientData.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMClientData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *appVersion;
@property (nullable, nonatomic, retain) NSString *buildType;
@property (nullable, nonatomic, retain) NSString *bundleVersion;
@property (nullable, nonatomic, retain) NSString *deviceName;
@property (nullable, nonatomic, retain) NSString *devicePlatform;
@property (nullable, nonatomic, retain) NSData *deviceToken;
@property (nullable, nonatomic, retain) NSString *deviceTokenError;
@property (nullable, nonatomic, retain) NSData *deviceUUID;
@property (nullable, nonatomic, retain) NSDate *lastAuth;
@property (nullable, nonatomic, retain) NSString *locationServiceStatus;
@property (nullable, nonatomic, retain) NSString *notificationTypes;
@property (nullable, nonatomic, retain) NSString *systemVersion;
@property (nullable, nonatomic, retain) NSString *tokenHash;
@property (nullable, nonatomic, retain) NSNumber *freeDiskSpace;

@end

NS_ASSUME_NONNULL_END