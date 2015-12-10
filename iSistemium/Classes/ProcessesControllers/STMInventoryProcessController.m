//
//  STMInventoryProcessController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryProcessController.h"

#import "STMBarCodeController.h"
#import "STMObjectsController.h"
#import "STMSoundController.h"


@interface STMInventoryProcessController()

@property (nonatomic, strong) STMInventoryBatch *currentBatch;
@property (nonatomic, strong) STMArticle *currentArticle;
@property (nonatomic, strong) NSString *currentArticleCode;
@property (nonatomic, strong) NSString *currentStockBatchCode;
@property (nonatomic, strong) NSString *selectedProductionInfo;


@end


@implementation STMInventoryProcessController

+ (STMInventoryProcessController *)sharedInstance {
    
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
            [STMSoundController alertSay:NSLocalizedString(@"UNKNOWN BARCODE", nil)];
            NSLog(@"unknown barcode %@", barcode);
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

+ (void)cancelCurrentInventoryProcessing {
    [[self sharedInstance] cancelCurrentProcess];
}

+ (void)doneCurrentInventoryProcessing {
    [[self sharedInstance] currentBatchDoneWithStockBatchCode:nil responder:nil];
}

+ (void)articleMismatchConfirmedForStockBatch:(STMStockBatch *)stockBatch source:(id<STMInventoryControlling>)source {
    [[self sharedInstance] articleMismatchConfirmedForStockBatch:stockBatch source:source];
}

- (void)prepareToCreateNewBatchOfArticlesWithCode:(NSString *)articleCode responder:(id <STMInventoryControlling>)responder {

    [self nullifyCurrentProperties];
    
    self.currentArticleCode = articleCode;

    NSArray *articles = [STMBarCodeController articlesForBarcode:articleCode];
    
    if (articles.count > 1) {
        
        [responder shouldSelectArticleFromArray:articles lookingForBarcode:nil];
        
    } else if (articles.count == 1) {
        
        [self checkArticleProductionInfo:articles.firstObject responder:responder];
        
    } else {
        
        articles = [STMObjectsController objectsForEntityName:NSStringFromClass([STMArticle class])
                                                      orderBy:@"name"
                                                    ascending:YES
                                                   fetchLimit:0
                                                  withFantoms:NO
                                       inManagedObjectContext:nil
                                                        error:nil];
        
        [responder shouldSelectArticleFromArray:articles lookingForBarcode:articleCode];
        
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
    
    [STMSoundController playOk];

    self.currentArticle = article;
    [responder didSuccessfullySelectArticle:self.currentArticle withProductionInfo:self.selectedProductionInfo];

}

- (void)currentBatchAddItemWithCode:(NSString *)itemCode responder:(id <STMInventoryControlling>)responder {
    
    if (self.currentArticle) {
        
        if (!self.currentBatch) {
            
            self.currentBatch = (STMInventoryBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatch class]) isFantom:NO];
            self.currentBatch.article = self.currentArticle;
            self.currentBatch.productionInfo = self.selectedProductionInfo;
            self.currentBatch.code = self.currentArticleCode;
            
        }
        
        NSSet *itemsCodes = [self.currentBatch.inventoryBatchItems valueForKeyPath:@"@distinctUnionOfObjects.code"];
        
        if ([itemsCodes containsObject:itemCode]) {
            
            [STMSoundController alertSay:NSLocalizedString(@"THIS EXCISE STAMP ALREADY SCANNED", nil)];
            
        } else {
            
            [STMSoundController playOk];

            STMInventoryBatchItem *item = (STMInventoryBatchItem *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatchItem class]) isFantom:NO];
            item.code = itemCode;
            item.inventoryBatch = self.currentBatch;
            
            [responder itemWasAdded:item];
            
            [[[self class] document] saveDocument:^(BOOL success) {
                
            }];

        }
        
    }
    
}

- (void)currentBatchDoneWithStockBatchCode:(NSString *)stockBatchCode responder:(id <STMInventoryControlling>)responder {
    
    if (self.currentBatch) {
        
        self.currentStockBatchCode = stockBatchCode;
        
        NSArray *stockBatches = [STMBarCodeController stockBatchForBarcode:stockBatchCode];
        
        if (stockBatches.count > 1) {
            NSLog(@"!!! something wrong - more than 1 stockBatch for barcode %@ !!!", stockBatchCode);
        }
        
        STMStockBatch *stockBatch = stockBatches.firstObject;
        
        if ([stockBatch.article isEqual:self.currentArticle]) {
            
            [self finishInventoryBatchWithStockBatch:stockBatch responder:responder];

        } else {
            
            [responder shouldConfirmArticleMismatchForStockBatch:stockBatch withInventoryBatch:self.currentBatch];
            
        }
        
    }
    
}

- (void)articleMismatchConfirmedForStockBatch:(STMStockBatch *)stockBatch source:(id<STMInventoryControlling>)source {
    
    [[STMLogger sharedLogger] saveLogMessageWithText:@"articleMismatch" type:@"error" owner:self.currentBatch];
    [self finishInventoryBatchWithStockBatch:stockBatch responder:source];
    
}

- (void)finishInventoryBatchWithStockBatch:(STMStockBatch *)stockBatch responder:(id <STMInventoryControlling>)responder {
    
    [STMSoundController playOk];

    self.currentBatch.stockBatch = stockBatch;
    self.currentBatch.stockBatchCode = self.currentStockBatchCode;
    
    [responder finishInventoryBatch:self.currentBatch withStockBatch:stockBatch];
    
    [self nullifyCurrentProperties];
    
    [[[self class] document] saveDocument:^(BOOL success) {
        
    }];

}

- (void)nullifyCurrentProperties {
    
    self.currentBatch = nil;
    self.currentArticle = nil;
    self.currentArticleCode = nil;
    self.currentStockBatchCode = nil;
    self.selectedProductionInfo = nil;

}

- (void)cancelCurrentProcess {
    
    self.currentBatch = nil;
    self.currentArticle = nil;
    
}


@end