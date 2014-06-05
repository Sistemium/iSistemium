//
//  STMTracker.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "STMSessionManagement.h"
#import "STMDocument.h"

@interface STMTracker : NSObject

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) id <STMSession> session;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic, strong) NSString *group;
@property (nonatomic) BOOL tracking;
@property (nonatomic) BOOL trackerAutoStart;

- (void)customInit;
- (void)startTracking;
- (void)stopTracking;
- (void)prepareToDestroy;

@end
