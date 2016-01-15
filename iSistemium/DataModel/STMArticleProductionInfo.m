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

#import "STMFunctions.h"


@implementation STMArticleProductionInfo

- (NSString *)displayInfo {

    NSString *info = nil;
    
    if ([self.productionInfoType.datatype isEqualToString:@"date"]) {
        
        info = [STMFunctions displayDateInfo:self.info];
        
    } else {
        
        info = self.info;
        
    }
    
    return info;

}


@end
