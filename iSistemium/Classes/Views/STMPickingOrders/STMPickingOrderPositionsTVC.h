//
//  STMPickingOrderPositionsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMWorkflowable.h"


@interface STMPickingOrderPositionsTVC : STMVariableCellsHeightTVC <STMWorkflowable>

@property (nonatomic, weak) STMPickingOrder *pickingOrder;


- (BOOL)orderIsProcessed;

- (void)positionWasUpdated:(STMPickingOrderPosition *)position;


#pragma mark - first version of picking process
// ---- ?
- (void)position:(STMPickingOrderPosition *)position wasPickedWithVolume:(NSUInteger)volume andProductionInfo:(NSString *)info;
// ---- ?



@end
