//
//  STMPickingOrderPositionPicked.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrderPositionPicked.h"
#import "STMArticle.h"
#import "STMPickingOrderPosition.h"
#import "STMStockBatch.h"

#import "STMProductionInfoType.h"
#import "STMFunctions.h"


@implementation STMPickingOrderPositionPicked

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
