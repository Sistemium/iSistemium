//
//  STMPickingOrderPositionsPickedTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 21/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMPickingOrderPositionsTVC.h"


@interface STMPickingOrderPositionsPickedTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMPickingOrder *pickingOrder;
@property (nonatomic, weak) STMPickingOrderPositionsTVC *positionsTVC;

- (void)pickedPosition:(STMPickingOrderPositionPicked *)pickedPosition newVolume:(NSUInteger)volume andProductionInfo:(NSString *)info;
- (void)deletePickedPosition:(STMPickingOrderPositionPicked *)pickedPosition;

@end
