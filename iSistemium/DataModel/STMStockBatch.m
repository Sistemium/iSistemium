//
//  STMStockBatch.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMStockBatch.h"
#import "STMArticle.h"
#import "STMInventoryBatch.h"
#import "STMPickingOrderPositionPicked.h"
#import "STMQualityClass.h"
#import "STMStockBatchBarCode.h"

#import "STMStockBatchOperation.h"
#import "STMProductionInfoType.h"

#import "STMNS.h"
#import "STMSessionManager.h"
#import "STMFunctions.h"


@implementation STMStockBatch

- (NSInteger)localVolume {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed == NO OR isProcessed == nil"];
    
    NSSet *nonProcessedSourceOperations = [self.sourceOperations filteredSetUsingPredicate:predicate];
    NSSet *nonProcessedDestinationOperations = [self.destinationOperations filteredSetUsingPredicate:predicate];
    
    NSInteger volume = self.volume.integerValue;
    
    NSInteger minusVolume = [[nonProcessedSourceOperations valueForKeyPath:@"@sum.volume"] integerValue];
    NSInteger plusVolume = [[nonProcessedDestinationOperations valueForKeyPath:@"@sum.volume"] integerValue];

    volume = volume - minusVolume + plusVolume;
    
//    for (STMStockBatchOperation *operation in nonProcessedSourceOperations) {
//        volume -= operation.volume.integerValue;
//    }
//
//    for (STMStockBatchOperation *operation in nonProcessedDestinationOperations) {
//        volume += operation.volume.integerValue;
//    }
    
    return volume;
    
}

- (NSString *)displayProductionInfo {
    
    NSString *info = nil;
    
    if ([self.article.productionInfoType.datatype isEqualToString:@"date"]) {
        
        info = [STMFunctions displayDateInfo:self.productionInfo];

    } else {
        
        info = self.productionInfo;
        
    }
    
    return info;
    
}


@end
