//
//  STMStockBatchOperationController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMStockBatchOperationController.h"

#import "STMObjectsController.h"


@implementation STMStockBatchOperationController

+ (STMStockBatchOperation *)stockBatchOperationWithSource:(STMStockBatchOperationAgent *)source destination:(STMStockBatchOperationAgent *)destination volume:(NSNumber *)volume save:(BOOL)save {
    
    NSString *stockBatchOperationClassName = NSStringFromClass([STMStockBatchOperation class]);
    
    STMStockBatchOperation *stockBatchOperation = (STMStockBatchOperation *)[STMObjectsController newObjectForEntityName:stockBatchOperationClassName
                                                                                                                isFantom:NO];
    
    NSString *sourceEntity = [NSStringFromClass([source class]) stringByReplacingOccurrencesOfString:ISISTEMIUM_PREFIX withString:@""];
    NSString *destinationEntity= [NSStringFromClass([destination class]) stringByReplacingOccurrencesOfString:ISISTEMIUM_PREFIX withString:@""];
    
    stockBatchOperation.sourceEntity = sourceEntity;
    stockBatchOperation.sourceXid = [source valueForKey:@"xid"];
    stockBatchOperation.sourceAgent = source;
    
    stockBatchOperation.destinationEntity = destinationEntity;
    stockBatchOperation.destinationXid = [destination valueForKey:@"xid"];
    stockBatchOperation.destinationAgent = destination;
    
    stockBatchOperation.volume = volume;
    
    if (save) [self.document saveDocument:^(BOOL success) {}];
    
    return stockBatchOperation;

}

+ (STMStockBatchOperation *)findStockBatchOperationWithSource:(STMStockBatchOperationAgent *)source andDestination:(STMStockBatchOperationAgent *)destination {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"destinationAgent == %@", destination];
    
    NSArray *result = [source.sourceOperations filteredSetUsingPredicate:predicate].allObjects;
    
    if (result.count == 0) {
        
        //        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMStockBatchOperation class])];
        //
        //        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        //        request.predicate = [NSPredicate predicateWithFormat:@"sourceXid == %@ AND destinationXid == %@", [source valueForKey:@"xid"], [destination valueForKey:@"xid"]];
        //
        //        result = [[self document].managedObjectContext executeFetchRequest:request error:nil];
        
    }
    
    if (result.count > 1) {
        NSLog(@"Something wrong, stockBatchOperation not unique, return first one");
    }
    
    return result.firstObject;
    
}


@end
