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


@interface STMInventoryController()

@property (nonatomic, strong) STMInventoryBatch *currentBatch;
@property (nonatomic, strong) STMArticle *currentArticle;


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

+ (void)receiveBarcode:(NSString *)barcode withType:(STMBarCodeScannedType)type {
    
    switch (type) {
        case STMBarCodeTypeUnknown: {
            
            break;
        }
        case STMBarCodeTypeArticle: {
            [[self sharedInstance] prepareToCreateNewBatchOfArticlesWithCode:barcode];
            break;
        }
        case STMBarCodeTypeExciseStamp: {
            [[self sharedInstance] currentBatchAddItemWithCode:barcode];
            break;
        }
        case STMBarCodeTypeStockBatch: {
            [[self sharedInstance] currentBatchDoneWithStockBatchCode:barcode];
            break;
        }
        default: {
            break;
        }
    }
    
}

- (void)prepareToCreateNewBatchOfArticlesWithCode:(NSString *)articleCode {

    if (self.currentBatch) self.currentBatch = nil;

    NSArray *articles = [STMBarCodeController articlesForBarcode:articleCode];
    
    if (articles.count > 1) {
        NSLog(@"show article selector");
    }
    
    self.currentArticle = articles.firstObject;
    
}

- (void)currentBatchAddItemWithCode:(NSString *)itemCode {
    
    if (self.currentArticle) {
        
        if (!self.currentBatch) {
            
            self.currentBatch = (STMInventoryBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatch class]) isFantom:NO];
            self.currentBatch.article = self.currentArticle;
            
        }

        STMInventoryBatchItem *item = (STMInventoryBatchItem *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatchItem class]) isFantom:NO];
        item.code = itemCode;
        item.inventoryBatch = self.currentBatch;
        
    }
    
}

- (void)currentBatchDoneWithStockBatchCode:(NSString *)stockBatchCode {
    
    if (self.currentBatch) {
        
        NSArray *stockBatches = [STMBarCodeController stockBatchForBarcode:stockBatchCode];
        
        if (stockBatches.count > 1) {
            NSLog(@"!!! something wrong - more than 1 stockBatch for barcode %@ !!!", stockBatchCode);
        }
        
        STMStockBatch *stockBatch = stockBatches.firstObject;
        
        self.currentBatch.stockBatch = stockBatch;
        
        self.currentBatch = nil;
        self.currentArticle = nil; // may be not necessary

        [[[self class] document] saveDocument:^(BOOL success) {
            
        }];
        
    }
    
}


@end
