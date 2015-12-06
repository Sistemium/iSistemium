//
//  STMInventoryArticleSelectTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMInventoryNC.h"


@interface STMInventoryArticleSelectTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) NSArray <STMArticle *> *articles;

@property (nonatomic, weak) STMInventoryNC *parentNC;


@end
