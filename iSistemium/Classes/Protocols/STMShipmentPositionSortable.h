//
//  STMShipmentPositionSortable.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STMShipmentPositionSortable <NSObject>

typedef enum NSUInteger {
    STMShipmentPositionSortOrdAsc,
    STMShipmentPositionSortOrdDesc,
    STMShipmentPositionSortNameAsc,
    STMShipmentPositionSortNameDesc,
    STMShipmentPositionSortTsAsc,
    STMShipmentPositionSortTsDesc
} STMShipmentPositionSort;

@property (nonatomic) STMShipmentPositionSort sortOrder;


@end
