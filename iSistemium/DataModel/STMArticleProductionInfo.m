//
//  STMArticleProductionInfo.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleProductionInfo.h"
#import "STMArticle.h"
#import "STMProductionInfoType.h"

@implementation STMArticleProductionInfo

- (NSString *)displayInfo {

    NSString *info = nil;
    
    if ([self.productionInfoType.datatype isEqualToString:@"date"]) {
        
        NSString *separator = @"/";
        NSArray *infoParts = [self.info componentsSeparatedByString:separator];
        infoParts = [[infoParts reverseObjectEnumerator] allObjects];
        info = [infoParts componentsJoinedByString:separator];
        
    } else {
        
        info = self.info;
        
    }
    
    return info;

}


@end
