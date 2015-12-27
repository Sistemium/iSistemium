//
//  STMArticleSelectionTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSearchableTVC.h"
#import "STMSupplyOrderOperationsTVC.h"


@interface STMArticleSelectionTVC : STMSearchableTVC

@property (nonatomic, strong) NSArray *articles;
@property (nonatomic, weak) STMSupplyOrderOperationsTVC *parentVC;
@property (nonatomic, weak) STMArticle *visibleArticle;
@property (nonatomic, weak) STMArticle *articleDocArticle;
@property (nonatomic, weak) STMArticle *selectedArticle;


@end
