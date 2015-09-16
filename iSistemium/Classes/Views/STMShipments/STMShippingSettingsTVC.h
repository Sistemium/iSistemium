//
//  STMShippingSettingsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMShipmentPositionSortable.h"
#import "STMConstants.h"


@interface STMShippingSettingsTVC : UITableViewController

@property (nonatomic, weak) UIViewController <STMShipmentPositionSortable> *parentVC;


@end
