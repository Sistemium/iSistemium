//
//  STMStockBatchInfoTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMArticleSelecting.h"
#import "STMProductionInfoSelecting.h"

#import "STMInventoryItemsVC.h"


@interface STMStockBatchInfoTVC : STMVariableCellsHeightTVC <STMArticleSelecting, STMProductionInfoSelecting>

@property (nonatomic, strong) STMStockBatch *stockBatch;

@property (nonatomic, weak) STMInventoryItemsVC *parentVC;


@end
