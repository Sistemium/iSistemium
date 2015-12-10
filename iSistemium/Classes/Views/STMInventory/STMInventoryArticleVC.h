//
//  STMInventoryArticleVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STMDataModel.h"

#import "STMInventoryItemsVC.h"


@interface STMInventoryArticleVC : UIViewController

@property (nonatomic, weak) STMArticle *article;
@property (nonatomic, weak) NSString *productionInfo;

@property (nonatomic, weak) STMInventoryItemsVC *parentVC;


@end
