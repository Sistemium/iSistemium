//
//  STMUncashingSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMUncashingMasterTVC.h"
#import "STMUncashingDetailsTVC.h"

@interface STMUncashingSVC : UISplitViewController

@property (nonatomic, strong) STMUncashingMasterTVC *masterVC;
@property (nonatomic, strong) STMUncashingDetailsTVC *detailVC;

@property (nonatomic) BOOL isUncashingHandOverProcessing;

@end
