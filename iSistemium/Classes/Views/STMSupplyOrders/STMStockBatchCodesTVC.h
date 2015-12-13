//
//  STMStockBatchCodesTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

@interface STMStockBatchCodesTVC : STMVariableCellsHeightTVC

- (void)addStockBatchCode:(NSString *)code;

@property (nonatomic, strong) NSMutableArray *stockBatchCodes;


@end
