//
//  STMInventoryNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMActionPopoverNC.h"

#import "STMInventoryItemsVC.h"


@interface STMInventoryNC : STMActionPopoverNC

@property (nonatomic, strong) STMInventoryItemsVC *itemsVC;
@property (nonatomic) BOOL scanEnabled;

- (void)selectArticle:(STMArticle *)article withSearchedBarcode:(NSString *)barcode;
- (void)selectInfo:(STMArticleProductionInfo *)info;


@end
