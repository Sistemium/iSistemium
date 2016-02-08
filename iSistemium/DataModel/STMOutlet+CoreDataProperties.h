//
//  STMOutlet+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMOutlet.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMOutlet (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *checksum;
@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isActive;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, retain) NSString *shortName;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) NSSet<STMBasketPosition *> *basketPositions;
@property (nullable, nonatomic, retain) NSSet<STMCampaign *> *campaigns;
@property (nullable, nonatomic, retain) NSSet<STMCashing *> *cashings;
@property (nullable, nonatomic, retain) NSSet<STMDebt *> *debts;
@property (nullable, nonatomic, retain) STMPartner *partner;
@property (nullable, nonatomic, retain) NSSet<STMPhotoReport *> *photoReports;
@property (nullable, nonatomic, retain) NSSet<STMSaleOrder *> *saleOrders;
@property (nullable, nonatomic, retain) STMSalesman *salesman;
@property (nullable, nonatomic, retain) NSSet<STMShipment *> *shipments;

@end

@interface STMOutlet (CoreDataGeneratedAccessors)

- (void)addBasketPositionsObject:(STMBasketPosition *)value;
- (void)removeBasketPositionsObject:(STMBasketPosition *)value;
- (void)addBasketPositions:(NSSet<STMBasketPosition *> *)values;
- (void)removeBasketPositions:(NSSet<STMBasketPosition *> *)values;

- (void)addCampaignsObject:(STMCampaign *)value;
- (void)removeCampaignsObject:(STMCampaign *)value;
- (void)addCampaigns:(NSSet<STMCampaign *> *)values;
- (void)removeCampaigns:(NSSet<STMCampaign *> *)values;

- (void)addCashingsObject:(STMCashing *)value;
- (void)removeCashingsObject:(STMCashing *)value;
- (void)addCashings:(NSSet<STMCashing *> *)values;
- (void)removeCashings:(NSSet<STMCashing *> *)values;

- (void)addDebtsObject:(STMDebt *)value;
- (void)removeDebtsObject:(STMDebt *)value;
- (void)addDebts:(NSSet<STMDebt *> *)values;
- (void)removeDebts:(NSSet<STMDebt *> *)values;

- (void)addPhotoReportsObject:(STMPhotoReport *)value;
- (void)removePhotoReportsObject:(STMPhotoReport *)value;
- (void)addPhotoReports:(NSSet<STMPhotoReport *> *)values;
- (void)removePhotoReports:(NSSet<STMPhotoReport *> *)values;

- (void)addSaleOrdersObject:(STMSaleOrder *)value;
- (void)removeSaleOrdersObject:(STMSaleOrder *)value;
- (void)addSaleOrders:(NSSet<STMSaleOrder *> *)values;
- (void)removeSaleOrders:(NSSet<STMSaleOrder *> *)values;

- (void)addShipmentsObject:(STMShipment *)value;
- (void)removeShipmentsObject:(STMShipment *)value;
- (void)addShipments:(NSSet<STMShipment *> *)values;
- (void)removeShipments:(NSSet<STMShipment *> *)values;

@end

NS_ASSUME_NONNULL_END
