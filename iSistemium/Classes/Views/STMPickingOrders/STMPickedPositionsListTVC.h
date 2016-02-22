//
//  STMPickedPositionsListTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMPickingOrderPositionsTVC.h"


@interface STMPickedPositionsListTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMPickingOrder *pickingOrder;
@property (nonatomic, weak) STMPickingOrderPositionsTVC *parentVC;


@end
