//
//  STMPickingOrdersProcessController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrdersProcessController.h"

#import "STMObjectsController.h"


@implementation STMPickingOrdersProcessController

+ (STMPickingOrderPositionPicked *)pickPosition:(STMPickingOrderPosition *)position withVolume:(NSUInteger)volume productionInfo:(NSString *)info article:(STMArticle *)article stockBatch:(STMStockBatch *)stockBatch barcode:(NSString *)barcode save:(BOOL)save {
    
    NSString *entityName = NSStringFromClass([STMPickingOrderPositionPicked class]);
    STMPickingOrderPositionPicked *pickedPosition = (STMPickingOrderPositionPicked *)[STMObjectsController newObjectForEntityName:entityName isFantom:NO];
    
    pickedPosition.pickingOrderPosition = position;
    pickedPosition.volume = @(volume);
    pickedPosition.productionInfo = info;
    pickedPosition.article = article;
    pickedPosition.stockBatch = stockBatch;
    pickedPosition.code = barcode;
    
    if (save) [self.document saveDocument:^(BOOL success) {}];

    return pickedPosition;
    
}

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

+ (void)position:(STMPickingOrderPosition *)position wasPickedWithVolume:(NSUInteger)volume andProductionInfo:(NSString *)info andBarCode:(NSString *)barcode {
    
    [self pickPosition:position
            withVolume:volume
        productionInfo:info
               article:position.article
            stockBatch:nil
               barcode:barcode
                  save:YES];

}

+ (void)pickPosition:(STMPickingOrderPosition *)position fromStockBatch:(STMStockBatch *)stockBatch withBarCode:(NSString *)barcode {
    
    NSInteger volume = ([stockBatch localVolume] > [position nonPickedVolume]) ? [position nonPickedVolume] : [stockBatch localVolume];
    
    STMPickingOrderPositionPicked *pickedPosition = [self pickPosition:position
                                                            withVolume:volume
                                                        productionInfo:nil
                                                               article:stockBatch.article
                                                            stockBatch:stockBatch
                                                               barcode:barcode
                                                                  save:NO];
    
    [self stockBatchOperationWithSource:stockBatch
                            destination:pickedPosition
                                 volume:pickedPosition.volume
                                   save:YES];

}

+ (void)pickedPosition:(STMPickingOrderPositionPicked *)pickedPosition newVolume:(NSUInteger)newVolume andProductionInfo:(NSString *)newInfo {
    
    BOOL volumeIsChanged = ![pickedPosition.volume isEqualToNumber:@(newVolume)];
    
    BOOL infoIsChanged = (pickedPosition.productionInfo || newInfo) && ![pickedPosition.productionInfo isEqualToString:newInfo];
    
    if (volumeIsChanged || infoIsChanged) {

        if (newVolume > 0) {
            
            NSUInteger maxVolume = [pickedPosition.pickingOrderPosition nonPickedVolume] + pickedPosition.volume.integerValue;
            
            if (newVolume > maxVolume) {
                newVolume = maxVolume;
            }
            
            pickedPosition.productionInfo = newInfo;
            
            if (pickedPosition.stockBatch) {
                
                NSInteger diff = newVolume - pickedPosition.volume.integerValue;
                
                pickedPosition.volume = @(newVolume);
                
                STMStockBatchOperation *operation = [self findStockBatchOperationWithSource:pickedPosition.stockBatch andDestination:pickedPosition];
                
                if (operation.sts) {
                    
                    STMStockBatchOperationAgent *source = nil;
                    STMStockBatchOperationAgent *destination = nil;
                    
                    if (diff > 0) {
                        
                        source = pickedPosition.stockBatch;
                        destination = pickedPosition;
                        
                    } else {
                        
                        source = pickedPosition;
                        destination = pickedPosition.stockBatch;
                        
                        diff = -diff;
                        
                    }
                    
                    [self stockBatchOperationWithSource:source
                                            destination:destination
                                                 volume:@(diff)
                                                   save:NO];
                    
                } else {
                    
                    operation.volume = @(newVolume);
                    
                }
                
            } else {
                
                pickedPosition.volume = @(newVolume);
                
            }
            
            [[self document] saveDocument:^(BOOL success) {
                
            }];
            
        } else if (newVolume == 0) {
            
            [self deletePickedPosition:pickedPosition];
            
        }
    
    }

}

+ (void)deletePickedPosition:(STMPickingOrderPositionPicked *)pickedPosition {

    if (pickedPosition.stockBatch) {
        
        STMStockBatchOperation *operation = [self findStockBatchOperationWithSource:pickedPosition.stockBatch andDestination:pickedPosition];
        
        if (operation.sts) {
        
            [self stockBatchOperationWithSource:pickedPosition
                                    destination:pickedPosition.stockBatch
                                         volume:pickedPosition.volume
                                           save:NO];

        } else {
            
            [STMObjectsController removeObject:operation];
            
        }
        
    }
    
    if (pickedPosition.sts) {
        [STMObjectsController createRecordStatusAndRemoveObject:pickedPosition];
    } else {
        [STMObjectsController removeObject:pickedPosition];
    }
    
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