//
//  STMSupplyOrdersProcessController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrdersProcessController.h"

#import "STMObjectsController.h"
#import "STMStockBatchOperationController.h"


@implementation STMSupplyOrdersProcessController

+ (void)createOperationForSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)supplyOrderArticleDoc withCodes:(NSArray *)codes andVolume:(NSInteger)volume {
    
    STMStockBatch *stockBatch = (STMStockBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMStockBatch class])
                                                                                     isFantom:NO];
    
    stockBatch.article = [supplyOrderArticleDoc operatingArticle];
    
    for (NSString *code in codes) {
        
        STMStockBatchBarCode *barCode = (STMStockBatchBarCode *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMStockBatchBarCode class])
                                                                                                    isFantom:NO];
        barCode.code = code;
        barCode.stockBatch = stockBatch;
        
    }
    
    [STMStockBatchOperationController stockBatchOperationWithSource:supplyOrderArticleDoc
                                                        destination:stockBatch
                                                             volume:@(volume)
                                                               save:YES];

}

+ (void)changeOperation:(STMStockBatchOperation *)operation newVolume:(NSInteger)newVolume {

    BOOL volumeIsChanged = ![operation.volume isEqualToNumber:@(newVolume)];

    if (volumeIsChanged) {
        
        operation.volume = @(newVolume);
        
        [[self document] saveDocument:^(BOOL success) {
            
        }];
        
    }
    
}

+ (void)removeOperation:(STMStockBatchOperation *)operation {

    [STMObjectsController createRecordStatusAndRemoveObject:operation.destinationAgent];
    [STMObjectsController createRecordStatusAndRemoveObject:operation];
    
}


@end
