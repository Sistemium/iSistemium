//
//  STMCatalogDetailTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"


@interface STMCatalogDetailTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) STMPriceType *selectedPriceType;
@property (nonatomic, strong) STMOutlet *selectedOutlet;

- (void)refreshTable;

- (void)dismissArticleInfoPopover;
- (void)showFullscreen;

- (void)dismissCatalogSettingsPopover;
- (void)dismissBasketPopover;

- (void)hideKeyboard;


- (NSArray *)currentArticles;
- (STMArticle *)selectPreviousArticle;
- (STMArticle *)selectNextArticle;


@end
