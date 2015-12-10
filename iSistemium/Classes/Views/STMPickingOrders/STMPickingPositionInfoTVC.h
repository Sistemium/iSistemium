//
//  STMPickingPositionInfoTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 20/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMPickingOrderPositionsTVC.h"
#import "STMPickingOrderPositionsPickedTVC.h"


@interface STMPickingPositionInfoTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMPickingOrderPosition *position;
@property (nonatomic, weak) STMPickingOrderPositionsTVC *positionsTVC;
@property (nonatomic) NSInteger selectedVolume;
@property (nonatomic, strong) STMArticleProductionInfo *selectedProductionInfo;

@property (nonatomic, weak) STMPickingOrderPositionPicked *pickedPosition;
@property (nonatomic, weak) STMPickingOrderPositionsPickedTVC *pickedPositionsTVC;

- (void)positionDidPicked;


@end
