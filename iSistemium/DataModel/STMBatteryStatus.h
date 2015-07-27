//
//  STMBatteryStatus.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 20/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMBatteryStatus : STMComment

@property (nonatomic, retain) NSDecimalNumber * batteryLevel;
@property (nonatomic, retain) NSString * batteryState;

@end
