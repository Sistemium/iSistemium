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

- (NSAttributedString *)operatingPackageRelStringWithFontSize:(CGFloat)fontSize {
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                 NSForegroundColorAttributeName:[UIColor blackColor]};

    if (self.packageRel && self.packageRel.integerValue != [self operatingArticle].packageRel.integerValue) {

        NSString *packageRelString = [NSString stringWithFormat:@"%@: %@ ", NSLocalizedString(@"PACKAGE REL", nil), self.packageRel];
        NSMutableAttributedString *returnString = [[NSMutableAttributedString alloc] initWithString:packageRelString attributes:attributes];
        
        attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:(fontSize - 2)],
                       NSForegroundColorAttributeName:[UIColor lightGrayColor],
                       NSStrikethroughStyleAttributeName  : @(NSUnderlinePatternSolid | NSUnderlineStyleSingle)};
        
        packageRelString = [NSString stringWithFormat:@"%@", [self operatingArticle].packageRel];
        
        [returnString appendAttributedString:[[NSAttributedString alloc] initWithString:packageRelString attributes:attributes]];
        
        return returnString;
        
    } else {
    
        NSString *packageRelString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PACKAGE REL", nil), [self operatingArticle].packageRel];
        return [[NSAttributedString alloc] initWithString:packageRelString];
        
    }
    
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
