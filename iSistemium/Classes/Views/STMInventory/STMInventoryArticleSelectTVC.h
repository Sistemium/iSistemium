//
//  STMInventoryArticleSelectTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSearchableTVC.h"

#import "STMInventoryNC.h"


@interface STMInventoryArticleSelectTVC : STMSearchableTVC

@property (nonatomic, strong) NSArray <STMArticle *> *articles;
@property (nonatomic, weak) STMInventoryNC *parentNC;
@property (nonatomic, weak) NSString *searchedBarcode;


@end
