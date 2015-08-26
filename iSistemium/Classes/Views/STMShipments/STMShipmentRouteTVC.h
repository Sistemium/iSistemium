//
//  STMShipmentRoutePointsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMDataModel.h"

@interface STMShipmentRouteTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) STMShipmentRoute *route;

- (NSArray *)shipmentRoutePointsSortDescriptors;


@end
