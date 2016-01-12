//
//  STMBasketNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STMCatalogDetailTVC.h"


@interface STMBasketNC : UINavigationController

@property (nonatomic, weak) STMCatalogDetailTVC *parentVC;

- (instancetype)initWithParent:(STMCatalogDetailTVC *)parentVC;


@end
