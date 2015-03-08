//
//  STMOrderInfoNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOrdersSVC.h"

@interface STMOrderInfoNC : UINavigationController

@property (nonatomic, weak) STMOrdersDetailTVC *parentVC;
@property (nonatomic, strong) STMSaleOrder *saleOrder;

- (void)cancelButtonPressed;

@end
