//
//  STMStockBatchInfoTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMArticleSelecting.h"


@interface STMStockBatchInfoTVC : STMVariableCellsHeightTVC <STMArticleSelecting>

@property (nonatomic, strong) STMStockBatch *stockBatch;


@end
