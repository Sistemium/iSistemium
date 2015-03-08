//
//  STMSaleOrderController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"
#import "STMSaleOrder.h"

@interface STMSaleOrderController : STMController

+ (STMSaleOrderController *)sharedInstance;

+ (NSString *)labelForProcessing:(NSString *)processing;
+ (UIColor *)colorForProcessing:(NSString *)processing;

@end
