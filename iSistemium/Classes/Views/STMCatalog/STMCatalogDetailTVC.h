//
//  STMCatalogDetailTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMPriceType.h"


@interface STMCatalogDetailTVC : STMFetchedResultsControllerTVC

@property (nonatomic, strong) STMPriceType *selectedPriceType;

- (void)refreshTable;
- (void)dismissArticleInfoPopover;
- (void)hideKeyboard;

- (NSArray *)currentArticles;

@end
