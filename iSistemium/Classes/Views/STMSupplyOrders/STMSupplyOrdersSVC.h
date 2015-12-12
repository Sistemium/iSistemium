//
//  STMSupplyOrdersSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSplitViewController.h"

#import "STMSupplyOrdersTVC.h"
#import "STMSupplyOrderArticleDocsTVC.h"
#import "STMWorkflowController.h"


@interface STMSupplyOrdersSVC : STMSplitViewController

@property (nonatomic, strong) STMSupplyOrdersTVC *masterTVC;
@property (nonatomic, strong) STMSupplyOrderArticleDocsTVC *detailTVC;

@property (nonatomic, strong) STMSupplyOrder *selectedSupplyOrder;
@property (nonatomic, strong) STMSupplyOrderArticleDoc *selectedSupplyOrderArticleDoc;

@property (nonatomic, strong) NSString *supplyOrderWorkflow;


- (BOOL)isMasterNCForViewController:(UIViewController *)vc;
- (BOOL)isDetailNCForViewController:(UIViewController *)vc;


@end
