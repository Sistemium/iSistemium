//
//  STMSupplyOrderArticleDoc.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrderArticleDoc.h"
#import "STMArticle.h"
#import "STMArticleDoc.h"
#import "STMSupplyOrder.h"

#import "STMStockBatchOperation.h"

#import "STMFunctions.h"


@implementation STMSupplyOrderArticleDoc

- (NSString *)volumeText {
    
    return [STMFunctions volumeStringWithVolume:self.volume.integerValue
                                  andPackageRel:(self.article.packageRel) ? self.article.packageRel.integerValue : self.articleDoc.article.packageRel.integerValue];
    
}

- (STMArticle *)operatingArticle {
    return (self.article) ? (STMArticle * _Nonnull)self.article : self.articleDoc.article;
}

- (NSInteger)volumeRemainingToSupply {

    NSInteger minusVolume = [[self.sourceOperations valueForKeyPath:@"@sum.volume"] integerValue];
    return self.volume.integerValue - minusVolume;

}

- (NSInteger)lastSourceOperationVolume {
    
    NSSortDescriptor *deviceCtsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                                                          ascending:NO
                                                                           selector:@selector(compare:)];
    
    NSArray *operations = [self.sourceOperations sortedArrayUsingDescriptors:@[deviceCtsDescriptor]];
    
    STMStockBatchOperation *operation = operations.firstObject;
    
    return operation.volume.integerValue;
    
}


@end
