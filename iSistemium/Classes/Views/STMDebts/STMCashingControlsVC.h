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
@property (nonatomic, weak) STMOutletDebtsTVC *tableVC;
@property (nonatomic, strong) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet UILabel *summLabel;
@property (weak, nonatomic) IBOutlet UITextField *debtSummTextField;
@property (weak, nonatomic) IBOutlet UILabel *remainderLabel;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *cashingSummTextField;
@property (weak, nonatomic) IBOutlet UILabel *cashingSumLabel;
@property (weak, nonatomic) IBOutlet UILabel *debtSumLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *debtInfoLabel;
@property (nonatomic, strong) STMDebt *selectedDebt;

- (void)customInit;
- (void)labelsInit;
- (void)updateControlLabels;

@end
