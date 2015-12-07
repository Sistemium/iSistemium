//
//  STMInventoryController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryController.h"

#import "STMBarCodeController.h"
#import "STMObjectsController.h"
#import "STMSoundController.h"


@interface STMInventoryController()

@property (nonatomic, strong) STMInventoryBatch *currentBatch;
@property (nonatomic, strong) STMArticle *currentArticle;
@property (nonatomic, strong) NSString *selectedProductionInfo;


@end


@implementation STMInventoryController

+ (STMInventoryController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

+ (void)receiveBarcode:(NSString *)barcode withType:(STMBarCodeScannedType)type source:(id <STMInventoryControlling>)source {
    
    switch (type) {
        case STMBarCodeTypeUnknown: {
            
            break;
        }
        case STMBarCodeTypeArticle: {
            [[self sharedInstance] prepareToCreateNewBatchOfArticlesWithCode:barcode responder:source];
            break;
        }
        case STMBarCodeTypeExciseStamp: {
            [[self sharedInstance] currentBatchAddItemWithCode:barcode responder:source];
            break;
        }
        case STMBarCodeTypeStockBatch: {
            [[self sharedInstance] currentBatchDoneWithStockBatchCode:barcode responder:source];
            break;
        }
        default: {
            break;
        }
    }
    
}

+ (void)selectArticle:(STMArticle *)article source:(id <STMInventoryControlling>)source {
    [[self sharedInstance] checkArticleProductionInfo:article responder:source];
}

+ (void)productionInfo:(NSString *)productionInfo setForArticle:(STMArticle *)article source:(id <STMInventoryControlling>)source {
    
    [self sharedInstance].selectedProductionInfo = productionInfo;
    [[self sharedInstance] didSuccessfullySelectArticle:article responder:source];
    
}

- (void)prepareToCreateNewBatchOfArticlesWithCode:(NSString *)articleCode responder:(id <STMInventoryControlling>)responder {

    if (self.currentBatch) self.currentBatch = nil;
    if (self.selectedProductionInfo) self.selectedProductionInfo = nil;

    NSArray *articles = [STMBarCodeController articlesForBarcode:articleCode];
    
    if (articles.count > 1) {
        
        [responder shouldSelectArticleFromArray:articles];
        
    } else {
        
        [self checkArticleProductionInfo:articles.firstObject responder:responder];
        
    }
    
}

- (void)checkArticleProductionInfo:(STMArticle *)article responder:(id <STMInventoryControlling>)responder {

    if (article.productionInfoType) {
        [responder shouldSetProductionInfoForArticle:article];
    } else {
        [self didSuccessfullySelectArticle:article responder:responder];
    }
    
}

- (void)didSuccessfullySelectArticle:(STMArticle *)article responder:(id <STMInventoryControlling>)responder {
    
    self.currentArticle = article;
    [responder didSuccessfullySelectArticle:self.currentArticle withProductionInfo:self.selectedProductionInfo];

}

- (void)currentBatchAddItemWithCode:(NSString *)itemCode responder:(id <STMInventoryControlling>)responder {
    
    if (self.currentArticle) {
        
        if (!self.currentBatch) {
            
            self.currentBatch = (STMInventoryBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatch class]) isFantom:NO];
            self.currentBatch.article = self.currentArticle;
            self.currentBatch.productionInfo = self.selectedProductionInfo;
            
        }
        
        NSSet *itemsCodes = [self.currentBatch.inventoryBatchItems valueForKeyPath:@"@distinctUnionOfObjects.code"];
        
        if ([itemsCodes containsObject:itemCode]) {
            
            [STMSoundController alertSay:NSLocalizedString(@"THIS EXCISE STAMP ALREADY SCANNED", nil)];
            
        } else {

            STMInventoryBatchItem *item = (STMInventoryBatchItem *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatchItem class]) isFantom:NO];
            item.code = itemCode;
            item.inventoryBatch = self.currentBatch;
            
            [responder itemWasAdded:item];

        }
        
    }
    
}

- (void)currentBatchDoneWithStockBatchCode:(NSString *)stockBatchCode responder:(id <STMInventoryControlling>)responder {
    
    if (self.currentBatch) {
        
        NSArray *stockBatches = [STMBarCodeController stockBatchForBarcode:stockBatchCode];
        
        if (stockBatches.count > 1) {
            NSLog(@"!!! something wrong - more than 1 stockBatch for barcode %@ !!!", stockBatchCode);
        }
        
        STMStockBatch *stockBatch = stockBatches.firstObject;
        
        self.currentBatch.stockBatch = stockBatch;

        [responder finishInventoryBatch:self.currentBatch withStockBatch:stockBatch];

        self.currentBatch = nil;
        self.currentArticle = nil; // may be not necessary
        
        [[[self class] document] saveDocument:^(BOOL success) {
            
        }];
        
    }
    
}


@end
