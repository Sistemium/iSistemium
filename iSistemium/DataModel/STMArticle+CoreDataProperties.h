//
//  STMArticle+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMArticle.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMArticle (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *barcode;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *extraLabel;
@property (nullable, nonatomic, retain) NSNumber *factor;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *packageRel;
@property (nullable, nonatomic, retain) NSDecimalNumber *pieceVolume;
@property (nullable, nonatomic, retain) NSDecimalNumber *pieceWeight;
@property (nullable, nonatomic, retain) NSDecimalNumber *price;
@property (nullable, nonatomic, retain) STMArticleGroup *articleGroup;
@property (nullable, nonatomic, retain) NSSet<STMBasketPosition *> *basketPositions;
@property (nullable, nonatomic, retain) NSSet<STMCampaign *> *campaigns;
@property (nullable, nonatomic, retain) NSSet<STMShipmentPosition *> *factShipmentPositions;
@property (nullable, nonatomic, retain) NSSet<STMArticlePicture *> *pictures;
@property (nullable, nonatomic, retain) NSSet<STMPrice *> *prices;
@property (nullable, nonatomic, retain) NSSet<STMSaleOrderPosition *> *saleOrderPositions;
@property (nullable, nonatomic, retain) NSSet<STMShipmentPosition *> *shipmentPositions;
@property (nullable, nonatomic, retain) STMStock *stock;
@property (nullable, nonatomic, retain) NSSet<STMBarCode *> *barcodes;

@end

@interface STMArticle (CoreDataGeneratedAccessors)

- (void)addBasketPositionsObject:(STMBasketPosition *)value;
- (void)removeBasketPositionsObject:(STMBasketPosition *)value;
- (void)addBasketPositions:(NSSet<STMBasketPosition *> *)values;
- (void)removeBasketPositions:(NSSet<STMBasketPosition *> *)values;

- (void)addCampaignsObject:(STMCampaign *)value;
- (void)removeCampaignsObject:(STMCampaign *)value;
- (void)addCampaigns:(NSSet<STMCampaign *> *)values;
- (void)removeCampaigns:(NSSet<STMCampaign *> *)values;

- (void)addFactShipmentPositionsObject:(STMShipmentPosition *)value;
- (void)removeFactShipmentPositionsObject:(STMShipmentPosition *)value;
- (void)addFactShipmentPositions:(NSSet<STMShipmentPosition *> *)values;
- (void)removeFactShipmentPositions:(NSSet<STMShipmentPosition *> *)values;

- (void)addPicturesObject:(STMArticlePicture *)value;
- (void)removePicturesObject:(STMArticlePicture *)value;
- (void)addPictures:(NSSet<STMArticlePicture *> *)values;
- (void)removePictures:(NSSet<STMArticlePicture *> *)values;

- (void)addPricesObject:(STMPrice *)value;
- (void)removePricesObject:(STMPrice *)value;
- (void)addPrices:(NSSet<STMPrice *> *)values;
- (void)removePrices:(NSSet<STMPrice *> *)values;

- (void)addSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)removeSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)addSaleOrderPositions:(NSSet<STMSaleOrderPosition *> *)values;
- (void)removeSaleOrderPositions:(NSSet<STMSaleOrderPosition *> *)values;

- (void)addShipmentPositionsObject:(STMShipmentPosition *)value;
- (void)removeShipmentPositionsObject:(STMShipmentPosition *)value;
- (void)addShipmentPositions:(NSSet<STMShipmentPosition *> *)values;
- (void)removeShipmentPositions:(NSSet<STMShipmentPosition *> *)values;

- (void)addBarcodesObject:(STMBarCode *)value;
- (void)removeBarcodesObject:(STMBarCode *)value;
- (void)addBarcodes:(NSSet<STMBarCode *> *)values;
- (void)removeBarcodes:(NSSet<STMBarCode *> *)values;

@end

NS_ASSUME_NONNULL_END
