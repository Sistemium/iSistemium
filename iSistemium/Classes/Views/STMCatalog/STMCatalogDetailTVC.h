//
//  STMCatalogDetailTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMPriceType.h"
#import "STMArticle.h"


@interface STMCatalogDetailTVC : STMFetchedResultsControllerTVC

#warning — have to use STMVariableCellsHeightTVC class?

@property (nonatomic, strong) STMPriceType *selectedPriceType;

- (void)refreshTable;

- (void)dismissArticleInfoPopover;
- (void)showFullscreen;

- (void)dismissCatalogSettingsPopover;

- (void)hideKeyboard;


- (NSArray *)currentArticles;
- (STMArticle *)selectPreviousArticle;
- (STMArticle *)selectNextArticle;

@end
