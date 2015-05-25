//
//  STMArticlePicturePVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCatalogSVC.h"


@interface STMArticlePicturePVC : UIPageViewController

@property (nonatomic, weak) STMCatalogDetailTVC *parentVC;
@property (nonatomic, strong) STMArticle *currentArticle;


@end
