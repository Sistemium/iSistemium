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


@implementation STMInventoryBatch

- (NSString *)displayProductionInfo {
    
    NSString *info = nil;
    
    if ([self.article.productionInfoType.datatype isEqualToString:@"date"]) {
        
        NSString *separator = @"/";
        NSArray *infoParts = [self.productionInfo componentsSeparatedByString:separator];
        infoParts = [[infoParts reverseObjectEnumerator] allObjects];
        info = [infoParts componentsJoinedByString:separator];
        
    } else {
        
        info = self.productionInfo;
        
    }
    
    return info;

}


@end
