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

+ (STMStockBatchOperation *)stockBatchOperationWithSource:(NSManagedObject *)source destination:(NSManagedObject *)destination volume:(NSNumber *)volume save:(BOOL)save {
    
    NSString *stockBatchOperationClassName = NSStringFromClass([STMStockBatchOperation class]);
    
    STMStockBatchOperation *stockBatchOperation = (STMStockBatchOperation *)[STMObjectsController newObjectForEntityName:stockBatchOperationClassName
                                                                                                                isFantom:NO];
    
    NSString *sourceEntity = [NSStringFromClass([source class]) stringByReplacingOccurrencesOfString:ISISTEMIUM_PREFIX withString:@""];
    NSString *destinationEntity= [NSStringFromClass([destination class]) stringByReplacingOccurrencesOfString:ISISTEMIUM_PREFIX withString:@""];
    
    stockBatchOperation.sourceEntity = sourceEntity;
    stockBatchOperation.sourceXid = [source valueForKey:@"xid"];
    stockBatchOperation.destinationEntity = destinationEntity;
    stockBatchOperation.destinationXid = [destination valueForKey:@"xid"];
    stockBatchOperation.volume = volume;

    if (save) [self.document saveDocument:^(BOOL success) {}];

    return stockBatchOperation;
    
}

+ (void)position:(STMPickingOrderPosition *)position wasPickedWithVolume:(NSUInteger)volume andProductionInfo:(NSString *)info {
    
    [self pickPosition:position
            withVolume:volume
        productionInfo:info
               article:position.article
            stockBatch:nil
               barcode:nil
                  save:YES];

}

+ (void)pickPosition:(STMPickingOrderPosition *)position fromStockBatch:(STMStockBatch *)stockBatch withBarCode:(NSString *)barcode {
    
    NSInteger volume = ([stockBatch localVolume] > position.volume.integerValue) ? position.volume.integerValue : [stockBatch localVolume];
    
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

+ (void)deletePickedPosition:(STMPickingOrderPositionPicked *)pickedPosition {

    if (pickedPosition.stockBatch) {
        
        if (pickedPosition.stockBatch.sts) {
        
            [self stockBatchOperationWithSource:pickedPosition
                                    destination:pickedPosition.stockBatch
                                         volume:pickedPosition.volume
                                           save:NO];

        } else {
            
            [STMObjectsController removeObject:pickedPosition.stockBatch];
            
        }
        
    }
    
    if (pickedPosition.sts) {
        [STMObjectsController createRecordStatusAndRemoveObject:pickedPosition];
    } else {
        [STMObjectsController removeObject:pickedPosition];
    }
    
}


@end
