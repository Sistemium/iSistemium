//
//  STMClientData.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/01/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMClientData : STMComment

@property (nonatomic, retain) NSString * appVersion;
@property (nonatomic, retain) NSString * buildType;
@property (nonatomic, retain) NSString * deviceName;
@property (nonatomic, retain) NSData * deviceToken;
@property (nonatomic, retain) NSDate * lastAuth;
@property (nonatomic, retain) NSString * tokenHash;
@property (nonatomic, retain) NSString * locationServiceStatus;

@end
