//
//  STMArticlePictureVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCatalogSVC.h"
#import "STMArticlePicturePVC.h"


@interface STMArticlePictureVC : UIViewController

@property (nonatomic, strong) STMArticle *article;
@property (nonatomic) NSUInteger index;

@property (nonatomic, weak) STMArticlePicturePVC *pageVC;


@end
