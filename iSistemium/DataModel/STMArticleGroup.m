//
//  STMArticleGroup.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMArticleGroup.h"
#import "STMArticle.h"

@implementation STMArticleGroup

@dynamic articlesStockVolume;
@dynamic articlesPicturesCount;
@dynamic articlesPriceTypes;

- (NSInteger)articlesCount {
    return self.articles.count;
}

- (NSInteger)articlesStockVolume {
    return [[self.articles valueForKeyPath:@"@sum.stock.volume"] integerValue];
}

- (NSInteger)articlesPicturesCount {
    return [[self.articles valueForKeyPath:@"@distinctUnionOfSets.pictures"] count];
}

- (NSSet *)articlesPriceTypes {
    
    NSSet *articlesPriceTypes = [self.articles valueForKeyPath:@"@distinctUnionOfSets.prices.@distinctUnionOfObjects.priceType"];
    
    //    if (articlesPriceTypes.count > 0) {
    //
    //        NSLog(@"self.name %@", self.name);
    //        NSLog(@"articlesPriceTypes.count %d", articlesPriceTypes.count);
    //
    //        if (articlesPriceTypes.count == 3) {
    //
    //            static dispatch_once_t onceToken;
    //            dispatch_once(&onceToken, ^{
    //
    //                for (STMPriceType *priceType in articlesPriceTypes) {
    //
    //                    NSLog(@"priceType %@", priceType);
    //
    //                }
    //
    //            });
    //
    //        }
    //
    //    }
    
    return articlesPriceTypes;
    
}

- (NSSet *)articlesPrices {
    
    NSSet *articlesPrices = [self.articles valueForKeyPath:@"@distinctUnionOfObjects.prices"];
    
    return articlesPrices;
    
}


@end
