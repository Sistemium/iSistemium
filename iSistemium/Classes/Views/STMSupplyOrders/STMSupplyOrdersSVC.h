//
//  STMSupplyOrdersSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSplitViewController.h"

#import "STMSupplyOrderArticleDocsTVC.h"


@interface STMSupplyOrdersSVC : STMSplitViewController

@property (nonatomic, strong) STMSupplyOrder *selectedSupplyOrder;

@property (nonatomic, strong) STMSupplyOrderArticleDocsTVC *detailTVC;


@end
