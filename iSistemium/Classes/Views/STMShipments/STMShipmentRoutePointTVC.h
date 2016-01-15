//
//  STMShipmentsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMDataModel.h"
#import "STMUI.h"

#import <MapKit/MapKit.h>

#import "STMShipmentsSVC.h"
#import "STMPicturesViewerDelegate.h"

@interface STMShipmentRoutePointTVC : STMVariableCellsHeightTVC <STMPicturesViewerDelegate>

@property (nonatomic, strong) STMShipmentRoutePoint *point;


- (void)showArriveConfirmationAlert;
- (void)shippingProcessWasInterrupted;
- (void)shippingDidDone;

- (void)photoWasDeleted:(STMShippingLocationPicture *)photo;

- (void)fillCell:(UITableViewCell <STMTDCell> *)cell withShipment:(STMShipment *)shipment;


@end
