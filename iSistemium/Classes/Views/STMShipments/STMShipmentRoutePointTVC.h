//
//  STMShipmentsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMDataModel.h"


@interface STMShipmentRoutePointTVC : UITableViewController

@property (nonatomic, strong) STMShipmentRoutePoint *point;

- (void)showArriveConfirmationAlert;
- (void)shippingProcessWasInterrupted;

- (void)photoWasDeleted:(STMShippingLocationPicture *)photo;


@end
