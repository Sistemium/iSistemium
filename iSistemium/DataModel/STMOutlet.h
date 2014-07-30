//
//  STMOutlet.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMCampaign, STMDebt, STMPartner, STMPhotoReport, STMSalesman;

@interface STMOutlet : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *campaigns;
@property (nonatomic, retain) STMPartner *partner;
@property (nonatomic, retain) NSSet *photoReports;
@property (nonatomic, retain) STMSalesman *salesmans;
@property (nonatomic, retain) NSSet *debts;
@end

@interface STMOutlet (CoreDataGeneratedAccessors)

- (void)addCampaignsObject:(STMCampaign *)value;
- (void)removeCampaignsObject:(STMCampaign *)value;
- (void)addCampaigns:(NSSet *)values;
- (void)removeCampaigns:(NSSet *)values;

- (void)addPhotoReportsObject:(STMPhotoReport *)value;
- (void)removePhotoReportsObject:(STMPhotoReport *)value;
- (void)addPhotoReports:(NSSet *)values;
- (void)removePhotoReports:(NSSet *)values;

- (void)addDebtsObject:(STMDebt *)value;
- (void)removeDebtsObject:(STMDebt *)value;
- (void)addDebts:(NSSet *)values;
- (void)removeDebts:(NSSet *)values;

@end
