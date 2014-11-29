//
//  STMClientData.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMClientData : STMComment

@property (nonatomic, retain) NSString * appVersion;
@property (nonatomic, retain) NSString * buildType;
@property (nonatomic, retain) NSData * deviceToken;
@property (nonatomic, retain) NSDate * lastAuth;
@property (nonatomic, retain) NSString * tokenHash;

@end
