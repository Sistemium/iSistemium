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

#import "STMStockBatch.h"
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

- (NSNumber *)operatingPackageRel {
    return (self.packageRel) ? (NSNumber * _Nonnull)self.packageRel : self.articleDoc.article.packageRel;
}

- (NSInteger)volumeRemainingToSupply {

    NSInteger minusVolume = [[self.sourceOperations valueForKeyPath:@"@sum.volume"] integerValue];
    return self.volume.integerValue - minusVolume;

}

- (NSInteger)lastSourceOperationVolume {
    
    STMStockBatchOperation *operation = [self lastOperation];
    
    return operation.volume.integerValue;
    
}

- (NSInteger)lastSourceOperationNumberOfBarcodes {
    
    STMStockBatchOperation *operation = [self lastOperation];
    
    if ([operation.destinationAgent isKindOfClass:[STMStockBatch class]]) {
        
        STMStockBatch *stockBatch = (STMStockBatch *)operation.destinationAgent;
        
        return stockBatch.barCodes.count;
        
    } else {
        
        return 0;
        
    }
    
}

- (STMStockBatchOperation *)lastOperation {
    
    NSSortDescriptor *deviceCtsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                                                          ascending:NO
                                                                           selector:@selector(compare:)];
    
    NSArray *operations = [self.sourceOperations sortedArrayUsingDescriptors:@[deviceCtsDescriptor]];
    
    STMStockBatchOperation *operation = operations.firstObject;

    return operation;
    
}


@end
