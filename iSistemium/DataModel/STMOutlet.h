//
//  STMOutlet.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMCampaign, STMCashing, STMDebt, STMPartner, STMPhotoReport, STMSaleOrder, STMSalesman, STMShipment;

@interface STMOutlet : STMComment

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSSet *campaigns;
@property (nonatomic, retain) NSSet *cashings;
@property (nonatomic, retain) NSSet *debts;
@property (nonatomic, retain) STMPartner *partner;
@property (nonatomic, retain) NSSet *photoReports;
@property (nonatomic, retain) NSSet *saleOrders;
@property (nonatomic, retain) STMSalesman *salesman;
@property (nonatomic, retain) NSSet *shipments;
@end

@interface STMOutlet (CoreDataGeneratedAccessors)

- (void)addCampaignsObject:(STMCampaign *)value;
- (void)removeCampaignsObject:(STMCampaign *)value;
- (void)addCampaigns:(NSSet *)values;
- (void)removeCampaigns:(NSSet *)values;

- (void)addCashingsObject:(STMCashing *)value;
- (void)removeCashingsObject:(STMCashing *)value;
- (void)addCashings:(NSSet *)values;
- (void)removeCashings:(NSSet *)values;

- (void)addDebtsObject:(STMDebt *)value;
- (void)removeDebtsObject:(STMDebt *)value;
- (void)addDebts:(NSSet *)values;
- (void)removeDebts:(NSSet *)values;

- (void)addPhotoReportsObject:(STMPhotoReport *)value;
- (void)removePhotoReportsObject:(STMPhotoReport *)value;
- (void)addPhotoReports:(NSSet *)values;
- (void)removePhotoReports:(NSSet *)values;

- (void)addSaleOrdersObject:(STMSaleOrder *)value;
- (void)removeSaleOrdersObject:(STMSaleOrder *)value;
- (void)addSaleOrders:(NSSet *)values;
- (void)removeSaleOrders:(NSSet *)values;

- (void)addShipmentsObject:(STMShipment *)value;
- (void)removeShipmentsObject:(STMShipment *)value;
- (void)addShipments:(NSSet *)values;
- (void)removeShipments:(NSSet *)values;

@end
