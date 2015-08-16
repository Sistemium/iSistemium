//
//  STMRouteMapVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "STMDataModel.h"


@interface STMRouteMapVC : UIViewController

@property (nonatomic, strong) STMShippingLocation *shippingLocation;
@property (nonatomic, strong) CLLocation *destinationPoint;
@property (nonatomic, strong) CLLocation *startPoint;
@property (nonatomic, strong) NSString *destinationPointName;
@property (nonatomic, strong) NSString *destinationPointAddress;


@end
