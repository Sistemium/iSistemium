//
//  STMShipmentRoutePointsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMDataModel.h"
#import "STMShipmentsSVC.h"

#import "STMWorkflowable.h"


@interface STMShipmentRouteTVC : STMVariableCellsHeightTVC <STMWorkflowable>

@property (nonatomic, strong) STMShipmentRoute *route;

- (NSArray *)shipmentRoutePointsSortDescriptors;

- (void)showShipments;

@end
