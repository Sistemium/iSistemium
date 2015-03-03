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
#import "STMFunctions.h"
#import "STMUI.h"

@interface STMCatalogSVC : STMUISplitViewController

@property (nonatomic, strong) STMCatalogMasterTVC *masterTVC;
@property (nonatomic, strong) STMCatalogDetailTVC *detailTVC;

@property (nonatomic, strong) STMArticleGroup *currentArticleGroup;

- (NSArray *)nestedArticleGroups;

@end
