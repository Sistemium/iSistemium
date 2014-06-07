//
//  STMArticle.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticlePicture, STMCampaign;

@interface STMArticle : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *campaigns;
@property (nonatomic, retain) NSSet *pictures;
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

@end
