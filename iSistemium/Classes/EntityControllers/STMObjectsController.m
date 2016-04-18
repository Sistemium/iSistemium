//
//  STMObjectsController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMObjectsController.h"

@implementation STMObjectsController

+ (void)checkLocation:(STMLocation *)location forAddingTo:(NSMutableSet *)objectsSet {
    
    if (location.photos.count == 0 && location.shippings.count == 0 && location.shipmentRoutePoint == nil) {
        [objectsSet addObject:location];
    } else {
        NSLog(@"location %@ linked with (picture|shipping|routePoint), flush declined", location.xid);
    }
    
}


@end
