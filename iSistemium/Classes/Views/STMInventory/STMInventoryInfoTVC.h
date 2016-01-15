//
//  STMInventoryInfoTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMInventoryItemsVC.h"


@interface STMInventoryInfoTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMInventoryItemsVC *parentVC;

@property (nonatomic, strong) STMInventoryBatch *inventoryBatch;
@property (nonatomic, strong) NSString *productionInfo;


- (void)refreshInfo;


@end
