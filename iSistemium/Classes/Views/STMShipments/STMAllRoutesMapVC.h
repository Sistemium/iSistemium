//
//  STMAllRoutesMapVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface STMAllRoutesMapVC : UIViewController

@property (nonatomic, strong) CLLocation *startPoint;
@property (nonatomic, strong) NSArray *points;


@end
