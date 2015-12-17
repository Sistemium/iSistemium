//
//  STMInventoryItemsVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STMDataModel.h"


@interface STMInventoryItemsVC : UIViewController

@property (nonatomic, weak) STMInventoryBatch *inventoryBatch;
@property (nonatomic, weak) NSString *productionInfo;


@end
