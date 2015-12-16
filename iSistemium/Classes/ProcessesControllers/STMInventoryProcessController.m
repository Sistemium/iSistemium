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

@property (nonatomic, strong) STMInventoryBatch *currentInventoryBatch;
@property (nonatomic, strong) STMStockBatch *currentStockBatch;
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
//            [[self sharedInstance] prepareToCreateNewBatchOfArticlesWithCode:barcode responder:source];
            break;
        }
        case STMBarCodeTypeExciseStamp: {
//            [[self sharedInstance] currentBatchAddItemWithCode:barcode responder:source];
            break;
        }
        case STMBarCodeTypeStockBatch: {
//            [[self sharedInstance] currentBatchDoneWithStockBatchCode:barcode responder:source];
            [[self sharedInstance] receiveStockBatchCode:barcode responder:source];
            break;
        }
        default: {
            break;
        }
    }
    
}

+ (NSArray <STMInventoryBatch *> *)notDoneInventoryBatchesForStockBatch:(STMStockBatch *)stockBatch {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMInventoryBatch class])];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isDone == nil OR isDone == NO) AND stockBatch == %@", stockBatch];
    request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];
    
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:nil];
    
    if (result.count > 1) {
        
        NSString *logMessage = [NSString stringWithFormat:@"More than one not done inventoryBatch for stockBatch: %@", stockBatch.barCodes.anyObject];
        [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"error"];

    }
    
    return result;
    
}


#pragma mark - instance methods

#pragma mark stockBatchCodes

- (void)receiveStockBatchCode:(NSString *)stockBatchCode responder:(id <STMInventoryControlling>)responder {
    
    if (!self.currentInventoryBatch) {

        [STMSoundController playOk];
        [self prepareToStartNewInventoryBatchForStockBatchCode:stockBatchCode responder:responder];

    } else {
        
        
        
    }
    
}

- (void)prepareToStartNewInventoryBatchForStockBatchCode:(NSString *)stockBatchCode responder:(id <STMInventoryControlling>)responder {
    
    self.currentStockBatchCode = stockBatchCode;
    
    NSArray *stockBatches = [STMBarCodeController stockBatchForBarcode:stockBatchCode];
    
    if (stockBatches.count > 0) {
        
        self.currentStockBatch = stockBatches.firstObject;
        [self selectInventoryBatchForStockBatch:self.currentStockBatch responder:responder];
        
    } else {
        
        self.currentInventoryBatch = (STMInventoryBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatch class])
                                                                                              isFantom:NO];
        
        [responder requestForArticleBarcode];
        
    }

}

- (void)selectInventoryBatchForStockBatch:(STMStockBatch *)stockBatch responder:(id <STMInventoryControlling>)responder {
    
    NSArray <STMInventoryBatch *> *inventoryBatches = [[self class] notDoneInventoryBatchesForStockBatch:self.currentStockBatch];
    
    if (inventoryBatches > 0) {
        
        self.currentInventoryBatch = inventoryBatches.firstObject;
        
    } else {
        
        self.currentInventoryBatch = (STMInventoryBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatch class])
                                                                                              isFantom:NO];
        self.currentInventoryBatch.stockBatchCode = stockBatchCode;
        
    }
    
    [responder didSelectInventoryBatch:self.currentInventoryBatch];

}

#pragma mark articleCodes

- (void)receiveArticleCode:(NSString *)articleCode responder:(id <STMInventoryControlling>)responder {
    
    if (!self.currentInventoryBatch) {
        
        [STMSoundController alertSay:NSLocalizedString(@"INVENTORY INFO MESSAGE", nil)];
        
    } else {

        [self processArticleCode:articleCode responder:responder];

    }
    
}

- (void)processArticleCode:(NSString *)articleCode responder:(id <STMInventoryControlling>)responder {
    
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
    
    self.currentInventoryBatch.article = article;
    self.currentInventoryBatch.productionInfo = self.selectedProductionInfo;
    self.currentInventoryBatch.code = self.currentArticleCode;

    [self createNewStockBatchForArticle:article];
    
    [responder didSuccessfullySelectArticle:self.currentArticle withProductionInfo:self.selectedProductionInfo];
    
}

- (void)createNewStockBatchForArticle:(STMArticle *)article {
    
    STMStockBatch *stockBatch = (STMStockBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMStockBatch class])
                                                                                     isFantom:NO];
    stockBatch.article = article;

    STMStockBatchBarCode *barCode = (STMStockBatchBarCode *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMStockBatchBarCode class])
                                                                                                isFantom:NO];
    barCode.code = self.currentStockBatchCode;
    barCode.stockBatch = stockBatch;
    
    self.currentInventoryBatch.stockBatch = stockBatch;
    
    self.currentStockBatch = stockBatch;
    
    [[[self class] document] saveDocument:^(BOOL success) {
        
    }];

}

#pragma mark exciseMarkCodes

- (void)receiveExciseMarkCode:(NSString *)exciseMarkCode responder:(id <STMInventoryControlling>)responder {
    
    if (!self.currentInventoryBatch) {
        
        [STMSoundController alertSay:NSLocalizedString(@"INVENTORY INFO MESSAGE", nil)];

    } else {
        
        if (self.currentInventoryBatch.inventoryBatchItems.count < [self.currentInventoryBatch operatingArticle].packageRel.integerValue) {
            
            [self addItemWithCode:exciseMarkCode responder:responder];
            
        } else {
            
            self.currentInventoryBatch.isDone = YES;
            
            [self selectInventoryBatchForStockBatch:self.currentStockBatch responder:responder];
            
        }
        
    }
    
}

- (void)addItemWithCode:(NSString *)itemCode responder:(id <STMInventoryControlling>)responder {

    NSSet *itemsCodes = [self.currentBatch.inventoryBatchItems valueForKeyPath:@"@distinctUnionOfObjects.code"];
    
    if ([itemsCodes containsObject:itemCode]) {
        
        [STMSoundController alertSay:NSLocalizedString(@"THIS EXCISE STAMP ALREADY SCANNED", nil)];
        
    } else {
        
        [STMSoundController playOk];
        
        STMInventoryBatchItem *item = (STMInventoryBatchItem *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatchItem class])
                                                                                                   isFantom:NO];
        item.code = itemCode;
        item.inventoryBatch = self.currentInventoryBatch;
        
        [responder itemWasAdded:item];
        
        [[[self class] document] saveDocument:^(BOOL success) {
            
        }];
        
    }
    
}


#pragma mark - old algorithm (article - excise - stockBatch)

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

- (void)currentBatchAddItemWithCode:(NSString *)itemCode responder:(id <STMInventoryControlling>)responder {
    
    if (self.currentArticle) {
        
        if (!self.currentInventoryBatch) {
            
            self.currentInventoryBatch = (STMInventoryBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatch class]) isFantom:NO];
            self.currentInventoryBatch.article = self.currentArticle;
            self.currentInventoryBatch.productionInfo = self.selectedProductionInfo;
            self.currentInventoryBatch.code = self.currentArticleCode;
            
        }
        
        NSSet *itemsCodes = [self.currentBatch.inventoryBatchItems valueForKeyPath:@"@distinctUnionOfObjects.code"];
        
        if ([itemsCodes containsObject:itemCode]) {
            
            [STMSoundController alertSay:NSLocalizedString(@"THIS EXCISE STAMP ALREADY SCANNED", nil)];
            
        } else {
            
            [STMSoundController playOk];

            STMInventoryBatchItem *item = (STMInventoryBatchItem *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatchItem class]) isFantom:NO];
            item.code = itemCode;
            item.inventoryBatch = self.currentInventoryBatch;
            
            [responder itemWasAdded:item];
            
            [[[self class] document] saveDocument:^(BOOL success) {
                
            }];

        }
        
    }
    
}

- (void)currentBatchDoneWithStockBatchCode:(NSString *)stockBatchCode responder:(id <STMInventoryControlling>)responder {
    
    if (self.currentInventoryBatch) {
        
        self.currentStockBatchCode = stockBatchCode;
        
        NSArray *stockBatches = [STMBarCodeController stockBatchForBarcode:stockBatchCode];
        
        if (stockBatches.count > 1) {
            NSLog(@"!!! something wrong - more than 1 stockBatch for barcode %@ !!!", stockBatchCode);
        }
        
        STMStockBatch *stockBatch = stockBatches.firstObject;
        
        if (!stockBatch || [stockBatch.article isEqual:self.currentArticle]) {
            
            [self finishInventoryBatchWithStockBatch:stockBatch responder:responder];

        } else {
            
            [responder shouldConfirmArticleMismatchForStockBatch:stockBatch withInventoryBatch:self.currentInventoryBatch];
            
        }
        
    }
    
}

- (void)articleMismatchConfirmedForStockBatch:(STMStockBatch *)stockBatch source:(id<STMInventoryControlling>)source {
    
    [[STMLogger sharedLogger] saveLogMessageWithText:@"articleMismatch" type:@"error" owner:self.currentInventoryBatch];
    [self finishInventoryBatchWithStockBatch:stockBatch responder:source];
    
}

- (void)finishInventoryBatchWithStockBatch:(STMStockBatch *)stockBatch responder:(id <STMInventoryControlling>)responder {
    
    [STMSoundController playOk];
    
    if (!stockBatch) {
        
        [STMSoundController alertSay:NSLocalizedString(@"NEW STOCK BATCH CODE", nil)];

    } else {

        self.currentBatch.stockBatch = stockBatch;

    }

    self.currentInventoryBatch.stockBatchCode = self.currentStockBatchCode;
    
    [responder finishInventoryBatch:self.currentInventoryBatch withStockBatch:stockBatch];
    
    [self nullifyCurrentProperties];
    
    [[[self class] document] saveDocument:^(BOOL success) {
        
    }];

}


#pragma mark -

- (void)nullifyCurrentProperties {
    
    self.currentInventoryBatch = nil;
    self.currentArticle = nil;
    self.currentArticleCode = nil;
    self.currentStockBatchCode = nil;
    self.selectedProductionInfo = nil;

}

- (void)cancelCurrentProcess {
    
    self.currentInventoryBatch = nil;
    self.currentArticle = nil;
    
}


@end
