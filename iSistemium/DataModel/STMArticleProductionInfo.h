//
//  STMArticleProductionInfo.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

@class STMArticle, STMProductionInfoType;

NS_ASSUME_NONNULL_BEGIN

@interface STMArticleProductionInfo : STMDatum

- (NSString *)displayInfo;


@end

NS_ASSUME_NONNULL_END

#import "STMArticleProductionInfo+CoreDataProperties.h"
