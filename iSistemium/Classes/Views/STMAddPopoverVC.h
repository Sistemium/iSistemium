//
//  STMAddPopoverVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMAddPopoverNC.h"

@interface STMAddPopoverVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) STMAddPopoverNC *parentNC;

- (void)doneButtonPressed;
- (BOOL)textFieldIsFilled:(UITextField *)textField;

@end
