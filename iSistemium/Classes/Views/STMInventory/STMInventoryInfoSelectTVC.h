//
//  STMInventoryInfoSelectTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMInventoryNC.h"


@interface STMInventoryInfoSelectTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMArticle *article;

@property (nonatomic, weak) STMInventoryNC *parentNC;

@property (nonatomic, strong) STMArticleProductionInfo *selectedProductionInfo;
@property (nonatomic, weak) NSString *currentProductionInfo;

- (void)infoSelected;


@end
