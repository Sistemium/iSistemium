//
//  STMShipmentRouteController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 14/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

@interface STMShipmentRouteController : STMController

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

+ (STMShipmentRouteController *)sharedInstance;

+ (NSArray *)routesWithProcessing:(NSString *)processing;


@end
