//
//  STMRouteMapVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface STMRouteMapVC : UIViewController

@property (nonatomic, strong) CLLocation *destinationPoint;
@property (nonatomic, strong) CLLocation *startPoint;


@end
