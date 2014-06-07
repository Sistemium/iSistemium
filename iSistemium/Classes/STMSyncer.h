//
//  STMSyncer.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMSessionManagement.h"
#import "STMRequestAuthenticatable.h"

@interface STMSyncer : NSObject <STMSyncer>

@property (nonatomic, strong) id <STMSession> session;
@property (nonatomic, strong) id <STMRequestAuthenticatable> authDelegate;

- (void)syncData;
- (void)prepareToDestroy;

@end
