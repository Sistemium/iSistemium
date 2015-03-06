//
//  STMArticle.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticleGroup, STMArticlePicture, STMCampaign, STMSaleOrderPosition;

@interface STMArticle : STMComment

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * extraLabel;
@property (nonatomic, retain) NSNumber * factor;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * packageRel;
@property (nonatomic, retain) NSDecimalNumber * pieceVolume;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) STMArticleGroup *articleGroup;
@property (nonatomic, retain) NSSet *campaigns;
@property (nonatomic, retain) NSSet *pictures;
@property (nonatomic, retain) NSSet *saleOrderPositions;
@end

@interface STMArticle (CoreDataGeneratedAccessors)

- (void)addCampaignsObject:(STMCampaign *)value;
- (void)removeCampaignsObject:(STMCampaign *)value;
- (void)addCampaigns:(NSSet *)values;
- (void)removeCampaigns:(NSSet *)values;

- (void)addPicturesObject:(STMArticlePicture *)value;
- (void)removePicturesObject:(STMArticlePicture *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

- (void)addSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)removeSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)addSaleOrderPositions:(NSSet *)values;
- (void)removeSaleOrderPositions:(NSSet *)values;

@end
