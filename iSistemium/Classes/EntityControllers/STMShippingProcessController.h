//
//  STMShippingProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

typedef NS_ENUM(NSInteger, STMShippingProcessState) {
    STMShippingProcessIdle,
    STMShippingProcessRunning
};


@interface STMShippingProcessController : STMController

@property (nonatomic) STMShippingProcessState state;


+ (STMShippingProcessController *)sharedInstance;


@end
