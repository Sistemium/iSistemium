//
//  STMPickingOrderPositionsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMWorkflowable.h"

#import "STMPickedPositionsInfoTVC.h"


@interface STMPickingOrderPositionsTVC : STMVariableCellsHeightTVC <STMWorkflowable>

@property (nonatomic, weak) STMPickingOrder *pickingOrder;

@property (nonatomic, strong) STMPickedPositionsInfoTVC *pickedPositionsInfoTVC;

- (BOOL)orderIsProcessed;

// ---- ?
- (void)position:(STMPickingOrderPosition *)position wasPickedWithVolume:(NSUInteger)volume andProductionInfo:(NSString *)info;
// ---- ?

- (void)positionWasUpdated:(STMPickingOrderPosition *)position;


@end
