//
//  STMAddDebtVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMDatePickerParent.h"
#import "STMDebtsDetailsPVC.h"

@interface STMAddDebtVC : UIViewController <STMDatePickerParent>

@property (nonatomic, weak) STMDebtsDetailsPVC *parentVC;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSString *debtNdoc;
@property (nonatomic, strong) NSDecimalNumber *debtSum;
@property (nonatomic, strong) NSString *commentText;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;

@end
