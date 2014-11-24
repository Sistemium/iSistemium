//
//  STMUncashingProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSingleton.h"

@interface STMUncashingProcessController : STMSingleton

+ (STMUncashingProcessController *)sharedInstance;

@property (nonatomic, strong) NSString *stringProperty;

@end
