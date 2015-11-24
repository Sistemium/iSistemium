//
//  STMStockBatch.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMStockBatch.h"
#import "STMArticle.h"
#import "STMPickingOrderPositionPicked.h"
#import "STMQualityClass.h"
#import "STMStockBatchBarCode.h"

#import "STMStockBatchOperation.h"

#import "STMNS.h"
#import "STMSessionManager.h"


@implementation STMStockBatch

- (NSInteger)localVolume {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMStockBatchOperation class])];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"(isProcessed == NO OR isProcessed == nil) AND (sourceXid == %@ OR destinationXid == %@)", self.xid, self.xid];
    
    NSArray *result = [[[STMSessionManager sharedManager].currentSession document].managedObjectContext executeFetchRequest:request error:nil];
    
    NSInteger volume = self.volume.integerValue;
    
    for (STMStockBatchOperation *operation in result) {
        
        if ([operation.sourceXid isEqualToData:self.xid]) {
            
            volume -= operation.volume.integerValue;
        
        }

        if ([operation.destinationXid isEqualToData:self.xid]) {
            
            volume += operation.volume.integerValue;
            
        }

    }
    
    return volume;
    
}


@end
