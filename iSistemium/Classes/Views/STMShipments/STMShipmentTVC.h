//
//  STMShipmentPositionsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMDataModel.h"
#import "STMShipmentRoutePointTVC.h"

typedef enum NSUInteger {
    STMShipmentPositionSortNameAsc = 0,
    STMShipmentPositionSortNameDesc = 1,
    STMShipmentPositionSortTsAsc = 2,
    STMShipmentPositionSortTsDesc = 3
} STMShipmentPositionSort;


@interface STMShipmentTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) STMShipment *shipment;
@property (nonatomic, strong) STMShipmentRoutePoint *point;

@property (nonatomic, weak) STMShipmentRoutePointTVC *parentVC;

@property (nonatomic) STMShipmentPositionSort sortOrder;

- (NSSortDescriptor *)currentSortDescriptor;
- (NSSortDescriptor *)sortDescriptorForSortOrder:(STMShipmentPositionSort)sortOrder;

@end
