//
//  STMCatalogSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STMCatalogMasterTVC.h"
#import "STMCatalogDetailTVC.h"

#import "STMArticle.h"
#import "STMArticleGroupController.h"
#import "STMArticlePicture.h"
#import "STMPrice.h"
#import "STMPriceType.h"
#import "STMStock.h"

#import "STMObjectsController.h"

#import "STMFunctions.h"
#import "STMUI.h"
#import "STMNS.h"
#import "STMConstants.h"

typedef NS_ENUM(NSInteger, STMCatalogInfoShowType) {
    STMCatalogInfoShowPrice,
    STMCatalogInfoShowPieceVolume,
    STMCatalogInfoShowStock
};

@interface STMCatalogSVC : STMSplitViewController

@property (nonatomic, strong) STMCatalogMasterTVC *masterTVC;
@property (nonatomic, strong) STMCatalogDetailTVC *detailTVC;

@property (nonatomic, strong) STMArticleGroup *currentArticleGroup;

@property (nonatomic, strong) STMPriceType *selectedPriceType;
@property (nonatomic, strong) NSArray *availablePriceTypes;

@property (nonatomic) STMCatalogInfoShowType selectedInfoShowType;

@property (nonatomic) BOOL showOnlyNonZeroStock;
@property (nonatomic) BOOL showOnlyWithPictures;

- (NSArray *)nestedArticleGroups;

- (NSArray *)catalogSettings;

- (void)updateSettings:(NSArray *)newSettings;

@end
