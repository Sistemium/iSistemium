//
//  STMOrdersSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMUISplitViewController.h"
#import "STMOrdersMasterPVC.h"
#import "STMOrdersDetailTVC.h"

@interface STMOrdersSVC : STMUISplitViewController

@property (nonatomic, strong) STMOrdersMasterPVC *masterPVC;
@property (nonatomic, strong) STMOrdersDetailTVC *detailTVC;


@end
