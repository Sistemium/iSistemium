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
+ (NSString *)processingForLabel:(NSString *)label;

+ (UIColor *)colorForProcessing:(NSString *)processing;

+ (NSArray *)availableRoutesForProcessing:(NSString *)processing;

+ (NSArray *)editablesPropertiesForProcessing:(NSString *)processing;
+ (NSString *)labelForEditableProperty:(NSString *)editableProperty;

+ (void)setProcessing:(NSString *)processing forSaleOrder:(STMSaleOrder *)saleOrder;
+ (void)setProcessing:(NSString *)processing forSaleOrder:(STMSaleOrder *)saleOrder withFields:(NSDictionary *)fields;

@end
