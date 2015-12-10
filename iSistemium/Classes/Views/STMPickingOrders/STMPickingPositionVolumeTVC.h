//
//  STMPickingPositionVolumeTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMDataModel.h"
#import "STMPickingOrderPositionsTVC.h"
#import "STMPickingOrderPositionsPickedTVC.h"


@interface STMPickingPositionVolumeTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMPickingOrderPosition *position;
@property (nonatomic, weak) STMPickingOrderPositionsTVC *positionsTVC;

@property (nonatomic, weak) STMPickingOrderPositionPicked *pickedPosition;
@property (nonatomic, weak) STMPickingOrderPositionsPickedTVC *pickedPositionsTVC;


@end
