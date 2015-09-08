//
//  STMShippingVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMDataModel.h"
#import "STMShipmentTVC.h"

#import "STMShipmentPositionSortable.h"

#import "STMShipmentsSVC.h"


@interface STMShippingVC : UIViewController <STMShipmentPositionSortable>

@property (nonatomic, strong) NSArray *shipments;
//@property (nonatomic, strong) STMShipment *shipment;
@property (nonatomic, weak) STMShipmentTVC *parentVC;
@property (nonatomic) STMShipmentPositionSort sortOrder;
@property (nonatomic, strong) NSDictionary *cachedHeights;

@property (nonatomic, strong) STMShipmentsSVC *splitVC;


@end
