//
//  STMArticle+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
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
@property (nullable, nonatomic, retain) NSSet<STMArticleProductionInfo *> *articleProductionInfo;
@property (nullable, nonatomic, retain) NSSet<STMArticleBarCode *> *barCodes;
@property (nullable, nonatomic, retain) NSSet<STMBasketPosition *> *basketPositions;
@property (nullable, nonatomic, retain) NSSet<STMCampaign *> *campaigns;
@property (nullable, nonatomic, retain) NSSet<STMShipmentPosition *> *factShipmentPositions;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderPosition *> *pickingOrderPositions;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderPositionPicked *> *pickingOrderPositionsPicked;
@property (nullable, nonatomic, retain) NSSet<STMArticlePicture *> *pictures;
@property (nullable, nonatomic, retain) NSSet<STMPrice *> *prices;
@property (nullable, nonatomic, retain) STMProductionInfoType *productionInfoType;
@property (nullable, nonatomic, retain) NSSet<STMSaleOrderPosition *> *saleOrderPositions;
@property (nullable, nonatomic, retain) NSSet<STMShipmentPosition *> *shipmentPositions;
@property (nullable, nonatomic, retain) STMStock *stock;
@property (nullable, nonatomic, retain) NSSet<STMStockBatch *> *stockBatches;
@property (nullable, nonatomic, retain) NSSet<STMArticleDoc *> *articleDocs;
@property (nullable, nonatomic, retain) NSSet<STMSupplyOrderArticleDoc *> *supplyOrderArticleDocs;

@end

@interface STMArticle (CoreDataGeneratedAccessors)

- (void)addArticleProductionInfoObject:(STMArticleProductionInfo *)value;
- (void)removeArticleProductionInfoObject:(STMArticleProductionInfo *)value;
- (void)addArticleProductionInfo:(NSSet<STMArticleProductionInfo *> *)values;
- (void)removeArticleProductionInfo:(NSSet<STMArticleProductionInfo *> *)values;

- (void)addBarCodesObject:(STMArticleBarCode *)value;
- (void)removeBarCodesObject:(STMArticleBarCode *)value;
- (void)addBarCodes:(NSSet<STMArticleBarCode *> *)values;
- (void)removeBarCodes:(NSSet<STMArticleBarCode *> *)values;

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

- (void)addPickingOrderPositionsObject:(STMPickingOrderPosition *)value;
- (void)removePickingOrderPositionsObject:(STMPickingOrderPosition *)value;
- (void)addPickingOrderPositions:(NSSet<STMPickingOrderPosition *> *)values;
- (void)removePickingOrderPositions:(NSSet<STMPickingOrderPosition *> *)values;

- (void)addPickingOrderPositionsPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)removePickingOrderPositionsPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)addPickingOrderPositionsPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;
- (void)removePickingOrderPositionsPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;

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

- (void)addStockBatchesObject:(STMStockBatch *)value;
- (void)removeStockBatchesObject:(STMStockBatch *)value;
- (void)addStockBatches:(NSSet<STMStockBatch *> *)values;
- (void)removeStockBatches:(NSSet<STMStockBatch *> *)values;

- (void)addArticleDocsObject:(STMArticleDoc *)value;
- (void)removeArticleDocsObject:(STMArticleDoc *)value;
- (void)addArticleDocs:(NSSet<STMArticleDoc *> *)values;
- (void)removeArticleDocs:(NSSet<STMArticleDoc *> *)values;

- (void)addSupplyOrderArticleDocsObject:(STMSupplyOrderArticleDoc *)value;
- (void)removeSupplyOrderArticleDocsObject:(STMSupplyOrderArticleDoc *)value;
- (void)addSupplyOrderArticleDocs:(NSSet<STMSupplyOrderArticleDoc *> *)values;
- (void)removeSupplyOrderArticleDocs:(NSSet<STMSupplyOrderArticleDoc *> *)values;

@end

NS_ASSUME_NONNULL_END
