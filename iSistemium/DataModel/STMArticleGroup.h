//
//  STMArticleGroup.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

@class STMArticle;

NS_ASSUME_NONNULL_BEGIN

@interface STMArticleGroup : STMDatum

@property (nonatomic) NSInteger articlesStockVolume;
@property (nonatomic) NSInteger articlesPicturesCount;
@property (nonatomic, strong) NSSet *articlesPriceTypes;


@end

NS_ASSUME_NONNULL_END

#import "STMArticleGroup+CoreDataProperties.h"
