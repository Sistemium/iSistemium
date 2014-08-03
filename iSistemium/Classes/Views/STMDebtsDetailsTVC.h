//
//  STMDebtsDetailsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutlet.h"


@interface STMDebtsDetailsTVC : UITableViewController

@property (nonatomic, strong) STMOutlet *outlet;
@property (nonatomic) NSUInteger index;

@end
