//
//  STMCashingControlsVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutlet.h"
#import "STMDebt.h"
#import "STMOutletDebtsTVC.h"
#import "STMDatePickerParent.h"

@interface STMCashingControlsVC : UIViewController <STMDatePickerParent>

@property (nonatomic, strong) STMOutlet *outlet;
@property (nonatomic, strong) STMOutletDebtsTVC *tableVC;
@property (nonatomic, strong) NSDate *selectedDate;


@end
