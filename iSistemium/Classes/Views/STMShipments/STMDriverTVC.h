//
//  STMShipmentRoutesTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMDataModel.h"


@interface STMDriverTVC : STMFetchedResultsControllerTVC

@property (nonatomic, strong) STMDriver *driver;

- (void)fillCell:(UITableViewCell *)cell withRoute:(STMShipmentRoute *)route;


@end
