//
//  STMArticleInfoVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCatalogSVC.h"

@interface STMArticleInfoVC : UIViewController

@property (nonatomic, weak) STMCatalogDetailTVC *parentVC;

@property (nonatomic, strong) STMArticle *article;

@end
