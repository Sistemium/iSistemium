//
//  STMCampaign+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMCampaign.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMCampaign (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSString *gain;
@property (nullable, nonatomic, retain) NSString *goal;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) NSSet<STMArticle *> *articles;
@property (nullable, nonatomic, retain) STMCampaignGroup *campaignGroup;
@property (nullable, nonatomic, retain) NSSet<STMOutlet *> *outlets;
@property (nullable, nonatomic, retain) NSSet<STMPhotoReport *> *photoReports;
@property (nullable, nonatomic, retain) NSSet<STMCampaignPicture *> *pictures;

@end

@interface STMCampaign (CoreDataGeneratedAccessors)

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet<STMArticle *> *)values;
- (void)removeArticles:(NSSet<STMArticle *> *)values;

- (void)addOutletsObject:(STMOutlet *)value;
- (void)removeOutletsObject:(STMOutlet *)value;
- (void)addOutlets:(NSSet<STMOutlet *> *)values;
- (void)removeOutlets:(NSSet<STMOutlet *> *)values;

- (void)addPhotoReportsObject:(STMPhotoReport *)value;
- (void)removePhotoReportsObject:(STMPhotoReport *)value;
- (void)addPhotoReports:(NSSet<STMPhotoReport *> *)values;
- (void)removePhotoReports:(NSSet<STMPhotoReport *> *)values;

- (void)addPicturesObject:(STMCampaignPicture *)value;
- (void)removePicturesObject:(STMCampaignPicture *)value;
- (void)addPictures:(NSSet<STMCampaignPicture *> *)values;
- (void)removePictures:(NSSet<STMCampaignPicture *> *)values;

@end

NS_ASSUME_NONNULL_END
