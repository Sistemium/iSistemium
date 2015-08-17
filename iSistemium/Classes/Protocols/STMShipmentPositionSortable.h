//
//  STMShipmentPositionSortable.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STMShipmentPositionSortable <NSObject>

typedef NS_ENUM (NSUInteger, STMShipmentPositionSort) {
    STMShipmentPositionSortOrdAsc,
    STMShipmentPositionSortOrdDesc,
    STMShipmentPositionSortNameAsc,
    STMShipmentPositionSortNameDesc,
    STMShipmentPositionSortTsAsc,
    STMShipmentPositionSortTsDesc
};

@property (nonatomic) STMShipmentPositionSort sortOrder;


@end
