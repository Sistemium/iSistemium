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

+ (void)position:(STMPickingOrderPosition *)position wasPickedWithVolume:(NSUInteger)volume andProductionInfo:(NSString *)info {
    
    NSString *entityName = NSStringFromClass([STMPickingOrderPositionPicked class]);
    STMPickingOrderPositionPicked *pickedPosition = (STMPickingOrderPositionPicked *)[STMObjectsController newObjectForEntityName:entityName isFantom:NO];
    
    pickedPosition.productionInfo = info;
    pickedPosition.article = position.article;
    pickedPosition.pickingOrderPosition = position;
    pickedPosition.volume = @(volume);
    
    [self.document saveDocument:^(BOOL success) {
        
    }];

}

+ (void)pickPosition:(STMPickingOrderPosition *)position fromStockBatch:(STMStockBatch *)stockBatch withBarCode:(NSString *)barcode {

    NSString *pickedPositionClassName = NSStringFromClass([STMPickingOrderPositionPicked class]);

    STMPickingOrderPositionPicked *pickedPosition = (STMPickingOrderPositionPicked *)[STMObjectsController newObjectForEntityName:pickedPositionClassName
                                                                                                                         isFantom:NO];
    
    pickedPosition.pickingOrderPosition = position;
    pickedPosition.article = stockBatch.article;
    pickedPosition.stockBatch = stockBatch;
    pickedPosition.code = barcode;
    
    if ([stockBatch localVolume] > position.volume.integerValue) {
        
        pickedPosition.volume = position.volume;
        
    } else {
        
        pickedPosition.volume = @([stockBatch localVolume]);
        
    }
    
    NSString *stockBatchOperationClassName = NSStringFromClass([STMStockBatchOperation class]);

    STMStockBatchOperation *stockBatchOperation = (STMStockBatchOperation *)[STMObjectsController newObjectForEntityName:stockBatchOperationClassName
                                                                                                                isFantom:NO];
    
    NSString *stockBatchClassName = NSStringFromClass([STMStockBatch class]);

    stockBatchOperation.sourceEntity = [stockBatchClassName stringByReplacingOccurrencesOfString:ISISTEMIUM_PREFIX withString:@""];
    stockBatchOperation.sourceXid = stockBatch.xid;
    stockBatchOperation.destinationEntity = [pickedPositionClassName stringByReplacingOccurrencesOfString:ISISTEMIUM_PREFIX withString:@""];
    stockBatchOperation.destinationXid = pickedPosition.xid;
    stockBatchOperation.volume = pickedPosition.volume;

    [self.document saveDocument:^(BOOL success) {
        
    }];

}

+ (void)deletePickedPosition:(STMPickingOrderPositionPicked *)pickedPosition {

    if (pickedPosition.stockBatch) {
        
        NSString *stockBatchOperationClassName = NSStringFromClass([STMStockBatchOperation class]);
        
        STMStockBatchOperation *stockBatchOperation = (STMStockBatchOperation *)[STMObjectsController newObjectForEntityName:stockBatchOperationClassName
                                                                                                                    isFantom:NO];

        NSString *pickedPositionClassName = NSStringFromClass([STMPickingOrderPositionPicked class]);
        NSString *stockBatchClassName = NSStringFromClass([STMStockBatch class]);

        stockBatchOperation.sourceEntity = [pickedPositionClassName stringByReplacingOccurrencesOfString:ISISTEMIUM_PREFIX withString:@""];
        stockBatchOperation.sourceXid = pickedPosition.xid;
        stockBatchOperation.destinationEntity = [stockBatchClassName stringByReplacingOccurrencesOfString:ISISTEMIUM_PREFIX withString:@""];
        stockBatchOperation.destinationXid = pickedPosition.stockBatch.xid;
        stockBatchOperation.volume = pickedPosition.volume;
        
    }
    
    [STMObjectsController createRecordStatusAndRemoveObject:pickedPosition];
    
    [self.document saveDocument:^(BOOL success) {
        
    }];

}


@end
