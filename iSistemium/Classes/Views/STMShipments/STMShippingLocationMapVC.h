//
//  STMLocationMapVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "STMDataModel.h"

#import "STMShipmentsSVC.h"


@interface STMShippingLocationMapVC : UIViewController

@property (nonatomic, strong) STMShipmentRoutePoint *point;

@property (nonatomic ,strong) STMShipmentsSVC *splitVC;

@property (nonatomic, strong) STMShippingLocation *shippingLocation;


@end
