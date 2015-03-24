//
//  STMArticleGroup+custom.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleGroup+custom.h"

@implementation STMArticleGroup (custom)

- (NSInteger)articlesCount {
    return self.articles.count;
}

- (NSInteger)articlesStockVolume {
    return [[self.articles valueForKeyPath:@"@sum.stock.volume"] integerValue];
}

@end
