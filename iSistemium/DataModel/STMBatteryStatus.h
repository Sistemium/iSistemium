//
//  STMBatteryStatus.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMBatteryStatus : STMComment

@property (nonatomic, retain) NSNumber * batteryLevel;
@property (nonatomic, retain) NSString * batteryState;

@end
