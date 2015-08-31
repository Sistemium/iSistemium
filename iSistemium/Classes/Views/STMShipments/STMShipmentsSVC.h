//
//  STMShipmentsSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSplitViewController.h"
#import "STMShipmentsMasterNC.h"
#import "STMShipmentsDetailNC.h"

#import "STMDataModel.h"


@interface STMShipmentsSVC : STMSplitViewController

@property (nonatomic, strong) STMShipmentsMasterNC *masterNC;
@property (nonatomic, strong) STMShipmentsDetailNC *detailNC;

@property (nonatomic, strong) STMShipmentRoute *selectedRoute;
@property (nonatomic, strong) STMShipmentRoutePoint *selectedPoint;


- (BOOL)isMasterNCForViewController:(UIViewController *)vc;
- (BOOL)isDetailNCForViewController:(UIViewController *)vc;

- (void)backButtonPressed;

- (void)didSelectPoint:(STMShipmentRoutePoint *)point byDetailController:(BOOL)byDC;


@end
