//
//  STMInventoryBatch.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryBatch.h"
#import "STMArticle.h"
#import "STMInventoryBatchItem.h"
#import "STMStockBatch.h"

#import "STMProductionInfoType.h"
#import "STMFunctions.h"


@implementation STMInventoryBatch

- (NSString *)displayProductionInfo {
    
    NSString *info = nil;
    
    if ([[self operatingArticle].productionInfoType.datatype isEqualToString:@"date"]) {
        
        info = [STMFunctions displayDateInfo:self.productionInfo];
        
    } else {
        
        info = self.productionInfo;
        
    }
    
    return info;

}

- (STMArticle *)operatingArticle {
    return (self.article) ? (STMArticle * _Nonnull)self.article : self.stockBatch.article;
}


@end
