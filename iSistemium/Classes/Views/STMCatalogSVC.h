//
//  STMCatalogSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCatalogMasterTVC.h"
#import "STMCatalogDetailTVC.h"

@interface STMCatalogSVC : UISplitViewController

@property (nonatomic, strong) STMCatalogMasterTVC *masterTVC;
@property (nonatomic, strong) STMCatalogDetailTVC *detailTVC;


@end
