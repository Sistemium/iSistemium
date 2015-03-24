//
//  STMArticleGroup+custom.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleGroup+custom.h"
#import "STMPriceType.h"


@implementation STMArticleGroup (custom)

@dynamic articlesStockVolume;


- (NSInteger)articlesCount {
    return self.articles.count;
}

- (NSInteger)articlesStockVolume {
    return [[self.articles valueForKeyPath:@"@sum.stock.volume"] integerValue];
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
