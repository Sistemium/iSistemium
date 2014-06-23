//
//  STMCampaign.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticle, STMCampaignPicture, STMOutlet, STMPhotoReport;

@interface STMCampaign : STMComment

@property (nonatomic, retain) NSString * gain;
@property (nonatomic, retain) NSString * goal;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *articles;
@property (nonatomic, retain) NSSet *outlets;
@property (nonatomic, retain) NSSet *photoReports;
@property (nonatomic, retain) NSSet *pictures;
@end

@interface STMCampaign (CoreDataGeneratedAccessors)

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet *)values;
- (void)removeArticles:(NSSet *)values;

- (void)addOutletsObject:(STMOutlet *)value;
- (void)removeOutletsObject:(STMOutlet *)value;
- (void)addOutlets:(NSSet *)values;
- (void)removeOutlets:(NSSet *)values;

- (void)addPhotoReportsObject:(STMPhotoReport *)value;
- (void)removePhotoReportsObject:(STMPhotoReport *)value;
- (void)addPhotoReports:(NSSet *)values;
- (void)removePhotoReports:(NSSet *)values;

- (void)addPicturesObject:(STMCampaignPicture *)value;
- (void)removePicturesObject:(STMCampaignPicture *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

@end
