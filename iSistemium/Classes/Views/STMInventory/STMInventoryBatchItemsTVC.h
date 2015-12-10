//
//  STMInventoryBatchItemsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMInventoryItemsVC.h"


@interface STMInventoryBatchItemsTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMInventoryBatch *batch;

@property (nonatomic, weak) STMInventoryItemsVC *parentVC;


@end
