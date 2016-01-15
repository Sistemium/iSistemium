//
//  STMInventoryInfoSelectTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMInventoryNC.h"
#import "STMProductionInfoSelecting.h"


@interface STMInventoryInfoSelectTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMArticle *article;

@property (nonatomic, weak) STMInventoryNC *parentNC;
@property (nonatomic, weak) id <STMProductionInfoSelecting> ownerVC;

@property (nonatomic, strong) STMArticleProductionInfo *selectedProductionInfo;
@property (nonatomic, strong) NSString *currentProductionInfo;

- (void)infoSelected;


@end
