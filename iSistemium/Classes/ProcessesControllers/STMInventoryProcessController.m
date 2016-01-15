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

@property (nonatomic, strong) NSString *partialBoxConfirmationCode;


@end


@implementation STMInventoryProcessController

#pragma mark - singleton

+ (STMInventoryProcessController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {

    }
    return self;
    
}


#pragma mark - class methods

+ (void)receiveBarcode:(NSString *)barcode withType:(STMBarCodeScannedType)type source:(id <STMInventoryControlling>)source {
    
    switch (type) {
        case STMBarCodeTypeUnknown: {
            [STMSoundController alertSay:NSLocalizedString(@"UNKNOWN BARCODE", nil)];
            NSLog(@"unknown barcode %@", barcode);
            break;
        }
        case STMBarCodeTypeArticle: {
            [[self sharedInstance] receiveArticleCode:barcode responder:source];
            break;
        }
        case STMBarCodeTypeExciseStamp: {
            [[self sharedInstance] receiveExciseMarkCode:barcode responder:source];
            break;
        }
        case STMBarCodeTypeStockBatch: {
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
        
        NSString *logMessage = [NSString stringWithFormat:@"More than one not done inventoryBatch for stockBatch: %@", [stockBatch.barCodes.anyObject valueForKey:@"code"]];
        [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"error"];

    }
    
    return result;
    
}

+ (void)selectArticle:(STMArticle *)article source:(id <STMInventoryControlling>)source {
    [[self sharedInstance] checkArticleProductionInfo:article responder:source];
}

+ (void)productionInfo:(NSString *)productionInfo setForArticle:(STMArticle *)article source:(id <STMInventoryControlling>)source {
    
    [self sharedInstance].selectedProductionInfo = productionInfo;
    [[self sharedInstance] didSuccessfullySelectArticle:article responder:source];
    
}


+ (void)cancelCurrentInventoryProcessingWithSource:(id<STMInventoryControlling>)source {
    [[self sharedInstance] nullifyCurrentProperties];
}

+ (void)doneCurrentInventoryProcessingWithSource:(id<STMInventoryControlling>)source {
    [[self sharedInstance] doneCurrentInventoryProcessingWithResponder:source];
}

+ (void)removeInventoryBatch:(STMInventoryBatch *)inventoryBatch {
    
    [[self sharedInstance] nullifyCurrentProperties];
    [STMObjectsController createRecordStatusAndRemoveObject:inventoryBatch];
    
}

+ (void)removeInventoryBatchItem:(STMInventoryBatchItem *)inventoryBatchItem {
    [STMObjectsController createRecordStatusAndRemoveObject:inventoryBatchItem];
}

+ (void)editInventoryBatch:(STMInventoryBatch *)inventoryBatch {
    
    [self sharedInstance].currentInventoryBatch = inventoryBatch;
    [self sharedInstance].currentInventoryBatch.isDone = @(NO);
    
}


#pragma mark - instance methods

#pragma mark stockBatchCodes

- (void)receiveStockBatchCode:(NSString *)stockBatchCode responder:(id <STMInventoryControlling>)responder {

    if (!self.currentInventoryBatch) {

        [STMSoundController playOk];
        [self prepareToStartNewInventoryBatchForStockBatchCode:stockBatchCode responder:responder];

    } else {
        
        if ([self.partialBoxConfirmationCode isEqualToString:stockBatchCode]) {

            [self doneCurrentInventoryProcessingWithResponder:responder];
            [self receiveStockBatchCode:stockBatchCode responder:responder];
            
        } else {
            
            [STMSoundController say:NSLocalizedString(@"PARTIAL BOX CONFIRM", nil)];
            self.partialBoxConfirmationCode = stockBatchCode;
            
        }
        
    }
    
}

- (void)prepareToStartNewInventoryBatchForStockBatchCode:(NSString *)stockBatchCode responder:(id <STMInventoryControlling>)responder {
    
    self.currentStockBatchCode = stockBatchCode;
    
    NSArray *stockBatches = [STMBarCodeController stockBatchForBarcode:stockBatchCode];
    
    if (stockBatches.count > 0) {
        
        STMStockBatch *stockBatch = stockBatches.firstObject;
        
        if (stockBatch.isInventarized.boolValue) {
            
            [STMSoundController say:NSLocalizedString(@"STOCK BATCH IS INVENTARIZED", nil)];
            [self nullifyCurrentProperties];
            
        } else {
            
            self.currentStockBatch = stockBatch;
            [self selectInventoryBatchForStockBatch:self.currentStockBatch responder:responder];

        }
        
    } else {

        [responder requestForArticleBarcode];
        
    }

}

- (void)selectInventoryBatchForStockBatch:(STMStockBatch *)stockBatch responder:(id <STMInventoryControlling>)responder {
    
    NSArray <STMInventoryBatch *> *inventoryBatches = [[self class] notDoneInventoryBatchesForStockBatch:self.currentStockBatch];
    
    if (inventoryBatches.count > 0) {
        
        self.currentInventoryBatch = inventoryBatches.firstObject;
        
    } else {
        
        self.currentInventoryBatch = (STMInventoryBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatch class])
                                                                                              isFantom:NO];
        self.currentInventoryBatch.stockBatchCode = self.currentStockBatchCode;
        self.currentInventoryBatch.stockBatch = stockBatch;
        
    }
    
    [responder didSelectInventoryBatch:self.currentInventoryBatch];

}

#pragma mark articleCodes

- (void)receiveArticleCode:(NSString *)articleCode responder:(id <STMInventoryControlling>)responder {
    
    self.partialBoxConfirmationCode = nil;
    
    if (!self.currentStockBatchCode) {
        
        [STMSoundController alertSay:NSLocalizedString(@"INVENTORY INFO MESSAGE", nil)];
        
    } else {

        if (self.currentInventoryBatch) {

            [STMSoundController alertSay:NSLocalizedString(@"SCAN EXCISE MARK", nil)];
            
        } else {
        
            [self processArticleCode:articleCode responder:responder];

        }
        
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
        
        [STMSoundController alertSay:NSLocalizedString(@"NO ARTICLES FOR THIS BARCODE", nil)];

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
    
    self.currentInventoryBatch = (STMInventoryBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatch class])
                                                                                          isFantom:NO];
    self.currentInventoryBatch.article = article;
    self.currentInventoryBatch.productionInfo = self.selectedProductionInfo;
    self.currentInventoryBatch.code = self.currentArticleCode;
    self.currentInventoryBatch.stockBatchCode = self.currentStockBatchCode;

    [self createNewStockBatchForArticle:article];
    
    [responder didSelectInventoryBatch:self.currentInventoryBatch];
    
}

- (void)createNewStockBatchForArticle:(STMArticle *)article {
    
    STMStockBatch *stockBatch = (STMStockBatch *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMStockBatch class])
                                                                                     isFantom:NO];
    stockBatch.article = article;
    stockBatch.productionInfo = self.selectedProductionInfo;

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
    
    self.partialBoxConfirmationCode = nil;
    
    if (!self.currentInventoryBatch) {
        
        [STMSoundController alertSay:NSLocalizedString(@"INVENTORY INFO MESSAGE", nil)];

    } else {
        
        [self addItemWithCode:exciseMarkCode responder:responder];
        
    }
    
}

- (void)addItemWithCode:(NSString *)itemCode responder:(id <STMInventoryControlling>)responder {
    
    NSInteger packageRel = [self.currentInventoryBatch operatingArticle].packageRel.integerValue;

    if (self.currentInventoryBatch.inventoryBatchItems.count >= packageRel) {
        
        [STMSoundController say:NSLocalizedString(@"THIS BOX IS FULL", nil)];
        
    } else {

        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMInventoryBatchItem class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        
        NSArray *itemsCodes = [[[self class] document].managedObjectContext executeFetchRequest:request error:nil];
        itemsCodes = [itemsCodes valueForKeyPath:@"@distinctUnionOfObjects.code"];
        
        if ([itemsCodes containsObject:itemCode]) {
            
            [STMSoundController alertSay:NSLocalizedString(@"THIS EXCISE STAMP ALREADY SCANNED", nil)];
            
        } else {
            
            [STMSoundController playOk];
            
            STMInventoryBatchItem *item = (STMInventoryBatchItem *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMInventoryBatchItem class])
                                                                                                       isFantom:NO];
            item.code = itemCode;
            item.inventoryBatch = self.currentInventoryBatch;
            
            [[[self class] document] saveDocument:^(BOOL success) {
                
            }];
            
            if (self.currentInventoryBatch.inventoryBatchItems.count >= packageRel) {
                
                self.currentInventoryBatch.isDone = @(YES);
                
                [STMSoundController say:NSLocalizedString(@"FULL BOX SCANNED", nil)];
                
                [self doneCurrentInventoryProcessingWithResponder:responder];
                
            }
            
        }

    }
    
}


- (void)doneCurrentInventoryProcessingWithResponder:(id <STMInventoryControlling>)responder {
    
    self.currentInventoryBatch.isDone = @(YES);
    
    [responder finishInventoryBatch];
    
    [self nullifyCurrentProperties];
    
    [[[self class] document] saveDocument:^(BOOL success) {
        
    }];
    
}


#pragma mark -

- (void)nullifyCurrentProperties {
    
    self.currentInventoryBatch = nil;
    self.currentArticleCode = nil;
    self.currentStockBatchCode = nil;
    self.selectedProductionInfo = nil;
    self.partialBoxConfirmationCode = nil;

}

- (void)cancelCurrentProcess {
    self.currentInventoryBatch = nil;
}


@end
