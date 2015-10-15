//
//  STMShipmentRouteController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 14/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRouteController.h"
#import "STMEntityController.h"


@interface STMShipmentRouteController()


@end


@implementation STMShipmentRouteController

+ (STMShipmentRouteController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

+ (NSArray *)routesWithProcessing:(NSString *)processing {

    NSArray *routes = [self sharedInstance].resultsController.fetchedObjects.copy;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"processing == %@", processing];
    NSArray *result = [routes filteredArrayUsingPredicate:predicate];
    
    return result;

}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipmentRoute class])];
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *driverDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"driver.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[dateDescriptor, driverDescriptor, idDescriptor];
        
        request.predicate = [STMPredicate predicateWithNoFantoms];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[STMShipmentRouteController document].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        [_resultsController performFetch:nil];

    }
    return _resultsController;
    
}


@end
