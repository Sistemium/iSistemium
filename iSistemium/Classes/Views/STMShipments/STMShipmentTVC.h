//
//  STMShipmentPositionsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMDataModel.h"
#import "STMUI.h"

#import "STMShipmentRoutePointTVC.h"
#import "STMShipmentPositionSortable.h"


@interface STMShipmentTVC : STMVariableCellsHeightTVC <STMShipmentPositionSortable>

@property (nonatomic, strong) STMShipment *shipment;
@property (nonatomic, strong) STMShipmentRoutePoint *point;

@property (nonatomic, weak) STMShipmentRoutePointTVC *parentVC;

@property (nonatomic) STMShipmentPositionSort sortOrder;

- (NSSortDescriptor *)currentSortDescriptor;
- (NSSortDescriptor *)sortDescriptorForSortOrder:(STMShipmentPositionSort)sortOrder;

- (void)fillCell:(UITableViewCell <STMTDICell> *)cell withShipmentPosition:(STMShipmentPosition *)position;


@end
