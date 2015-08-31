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


@interface STMShipmentsSVC : STMSplitViewController

@property (nonatomic, strong) STMShipmentsMasterNC *masterNC;
@property (nonatomic, strong) STMShipmentsDetailNC *detailNC;


@end
