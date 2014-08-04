//
//  STMOutletDebtsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutlet.h"

@interface STMOutletDebtsTVC : UITableViewController

@property (nonatomic, strong) STMOutlet *outlet;

@property (nonatomic, strong) NSDecimalNumber *totalSum;

@end
