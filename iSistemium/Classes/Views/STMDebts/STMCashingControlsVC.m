//
//  STMCashingControlsVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCashingControlsVC.h"
#import "STMConstants.h"
#import "STMDebtsSVC.h"
#import "STMSyncer.h"
#import "STMCashing.h"
#import "STMDebt+Cashing.h"
#import "STMDatePickerVC.h"
#import "STMFunctions.h"
#import "STMCashingProcessController.h"
#import "STMUI.h"

@interface STMCashingControlsVC () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *summLabel;
@property (weak, nonatomic) IBOutlet UITextField *debtSummTextField;
@property (weak, nonatomic) IBOutlet UILabel *remainderLabel;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *cashingSummTextField;
@property (weak, nonatomic) IBOutlet UILabel *cashingSumLabel;
@property (weak, nonatomic) IBOutlet UILabel *debtSumLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *debtInfoLabel;

@property (nonatomic) CGFloat textViewShiftDistance;
@property (nonatomic) BOOL textViewIsShifted;

@property (nonatomic, strong) UIToolbar *keyboardToolbar;

@property (nonatomic, strong) NSString *initialTextFieldValue;

@property (nonatomic, weak) STMDebtsSVC *splitVC;
@property (nonatomic, strong) STMDebt *selectedDebt;

@end

@implementation STMCashingControlsVC

- (STMDebtsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMDebtsSVC class]]) {
            
            _splitVC = (STMDebtsSVC *)self.splitViewController;
            
        }
        
    }
    
    return _splitVC;
    
}

- (UIToolbar *)keyboardToolbar {
    
    if (!_keyboardToolbar) {
        
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(toolbarCancelButtonPressed)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toolbarDoneButtonPressed)];
        
        [cancelButton setTintColor:[UIColor redColor]];
        
        [toolbar setItems:@[cancelButton,flexibleSpace,doneButon] animated:YES];

        _keyboardToolbar = toolbar;
        
    }
    
    return _keyboardToolbar;
    
}

- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        
        if (_outlet) {
            
            self.debtSummTextField.delegate = nil;
            self.debtSummTextField.delegate = self;
            
        }
        
    }
    
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    
    if (_selectedDate != selectedDate) {
        
        _selectedDate = selectedDate;
        
        [STMCashingProcessController sharedInstance].selectedDate = selectedDate;
        
        [self refreshDateButtonTitle];
        
    }
    
}

- (void)setSelectedDebt:(STMDebt *)selectedDebt {
    
    if (_selectedDebt != selectedDebt) {
        
        _selectedDebt = selectedDebt;

        NSNumberFormatter *numberFormatter = [STMFunctions decimalMinTwoDigitFormatter];

        if (selectedDebt) {
            
            NSDateFormatter *dateFormatter = [STMFunctions dateShortNoTimeFormatter];
            NSString *debtDate = [dateFormatter stringFromDate:selectedDebt.date];
            
            self.debtInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DEBT INFO", nil), selectedDebt.ndoc, debtDate];

            NSDecimalNumber *cashingSum = ([STMCashingProcessController sharedInstance].debtsDictionary)[selectedDebt.xid][1];
            
            NSMutableString *cashingSumString = [[numberFormatter stringFromNumber:cashingSum] mutableCopy];
            
            self.debtSummTextField.text = [NSString stringWithFormat:@"%@", cashingSumString];
            self.debtSummTextField.hidden = NO;
            self.debtSumLabel.hidden = NO;
            self.commentTextView.hidden = NO;
            
            NSString *commentText = ([STMCashingProcessController sharedInstance].commentsDictionary)[selectedDebt.xid];
            
            if (commentText) {
                
                self.commentTextView.textColor = [UIColor blackColor];
                self.commentTextView.text = commentText;
                
            } else {
                
                [self wipeCommentText];
                
            }

        } else {

            self.debtInfoLabel.text = nil;
            self.debtSummTextField.text = [numberFormatter stringFromNumber:[NSDecimalNumber zero]];
            self.debtSummTextField.hidden = YES;
            self.debtSumLabel.hidden = YES;
            [self wipeCommentText];
            self.commentTextView.hidden = YES;

        }
        
    }
    
}

- (void)refreshDateButtonTitle {
    
    NSDateFormatter *dateFormatter = [STMFunctions dateLongNoTimeFormatter];
    
    [self.dateButton setTitle:[dateFormatter stringFromDate:[STMCashingProcessController sharedInstance].selectedDate] forState:UIControlStateNormal];
    
}

- (void)debtAdded:(NSNotification *)notification {
    
    [self toolbarDoneButtonPressed];

    STMDebt *debt = (notification.userInfo)[@"debt"];

    if (debt) {
        
        self.selectedDebt = debt;
        [self updateControlLabels];
        
    }
    
}

- (void)debtRemoved:(NSNotification *)notification {
    
    [self toolbarDoneButtonPressed];

    STMDebt *debt = (notification.userInfo)[@"debt"];
//    STMDebt *selectedDebt = [notification.userInfo objectForKey:@"selectedDebt"];
    
    if (debt) {
        
        self.debtSummTextField.delegate = nil;
        self.debtSummTextField.delegate = self;

        self.selectedDebt = [STMCashingProcessController sharedInstance].debtsArray.lastObject;
        
        [self updateControlLabels];

    }
    
}

- (void)cashingSumChanged:(NSNotification *)notification {
    
    STMDebt *debt = (notification.userInfo)[@"debt"];
    NSDecimalNumber *cashingSum = (notification.userInfo)[@"cashingSum"];
    
    if ([self.selectedDebt isEqual:debt]) {
        
        NSNumberFormatter *numberFormatter = [STMFunctions decimalMinTwoDigitFormatter];
        self.debtSummTextField.text = [numberFormatter stringFromNumber:cashingSum];
        
    }
    
}

- (void)cashingProcessCancel {
    
    [self dismissSelf];
    
}

- (void)cashingProcessDone {
    
    [self dismissSelf];
    
}

- (void)dismissSelf {
    
    self.splitVC.controlsVC = nil;
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - buttons pressed

- (void)toolbarDoneButtonPressed {
    
    [self.view endEditing:NO];
    
}

- (void)toolbarCancelButtonPressed {

    if ([self.debtSummTextField isFirstResponder]) {
        
        self.debtSummTextField.text = self.initialTextFieldValue;
        
    } else if ([self.cashingSummTextField isFirstResponder]) {
        
        self.cashingSummTextField.text = self.initialTextFieldValue;
        
    } else if ([self.commentTextView isFirstResponder]) {
        
        self.commentTextView.text = self.initialTextFieldValue;
        
    }

    [self toolbarDoneButtonPressed];

}

#pragma mark - controls view

- (void)updateControlLabels {
    
    if ([[STMCashingProcessController sharedInstance].cashingSummLimit doubleValue] > 0) {

        [self controlLabelsWithCashingLimit];
        
    } else {

        [self controlLabelsWOCashingLimit];

    }
    
}

- (void)controlLabelsWithCashingLimit {
    
    self.remainderLabel.hidden = NO;
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    NSString *remainderSumString = [numberFormatter stringFromNumber:[STMCashingProcessController sharedInstance].remainderSumm];
    
    self.remainderLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REMAINDER", nil), remainderSumString];
    self.remainderLabel.textColor = [UIColor blackColor];

    if ([[STMCashingProcessController sharedInstance].remainderSumm doubleValue] <= 0) {

        NSDecimalNumber *fillingSum = ([STMCashingProcessController sharedInstance].debtsDictionary)[self.selectedDebt.xid][1];
        
        numberFormatter = [STMFunctions decimalMinTwoDigitFormatter];
        self.debtSummTextField.text = [numberFormatter stringFromNumber:fillingSum];
        
    }
    
    [self showCashingSumLabel];

}

- (void)controlLabelsWOCashingLimit {
    
    self.remainderLabel.hidden = YES;
    
//    self.cashingLimitIsReached = NO;

    [self showCashingSumLabel];

}

- (void)showCashingSumLabel {
    
    NSDecimalNumber *sum = [[STMCashingProcessController sharedInstance] debtsSumm];
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    NSString *sumString = [numberFormatter stringFromNumber:sum];
    self.summLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PICKED", nil), sumString];

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    textField.inputAccessoryView = self.keyboardToolbar;

    return YES;
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.cashingSummTextField] && [self.cashingSummTextField.text isEqualToString:@""]) {
        return YES;
    } else {
        return [self isCorrectDebtSumValueForTextField:textField];
    }

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.initialTextFieldValue = textField.text;
    [textField selectAll:nil];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSNumberFormatter *numberFormatter = [STMFunctions decimalMaxTwoMinTwoDigitFormatter];
    
    if ([textField isEqual:self.debtSummTextField]) {
        
        NSNumber *number = [numberFormatter numberFromString:(NSString * _Nonnull)self.debtSummTextField.text];

        numberFormatter.numberStyle = NSNumberFormatterNoStyle;
        NSString *decimalNumberString = [numberFormatter stringFromNumber:number];
        NSDictionary *local = @{NSLocaleDecimalSeparator: numberFormatter.decimalSeparator};
        
        NSDecimalNumber *cashingSum = [NSDecimalNumber decimalNumberWithString:decimalNumberString locale:local];

        if ([cashingSum compare:self.selectedDebt.calculatedSum] == NSOrderedDescending) {
         
            cashingSum = self.selectedDebt.calculatedSum;
            
        }
        
        [[STMCashingProcessController sharedInstance] setCashingSum:cashingSum forDebt:self.selectedDebt];
        
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.debtSummTextField.text = [numberFormatter stringFromNumber:cashingSum];
        
    } else if ([textField isEqual:self.cashingSummTextField] && self.cashingSummTextField.text) {

        NSNumber *number = [numberFormatter numberFromString:(NSString * _Nonnull)self.cashingSummTextField.text];
        self.cashingSummTextField.text = [numberFormatter stringFromNumber:number];

        [STMCashingProcessController sharedInstance].cashingSummLimit = [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
        
    }
    
    [self updateControlLabels];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSNumberFormatter *numberFormatter = [STMFunctions decimalMaxTwoDigitFormatter];

    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];

    NSArray *textParts = [text componentsSeparatedByString:numberFormatter.decimalSeparator];

    NSString *decimalPart = (textParts.count == 2) ? textParts[1] : nil;

    if (decimalPart.length == 3 && ![string isEqualToString:@""]) {
        
        return NO;
        
    } else {
        
        [text replaceOccurrencesOfString:numberFormatter.groupingSeparator withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [text length])];

        [self fillTextField:textField withText:text];
        
//        NSInteger offset = range.location + string.length + replaceOccurrences;
//
//        UITextPosition *from = [textField positionFromPosition:[textField beginningOfDocument] offset:offset];
//        UITextPosition *to = [textField positionFromPosition:from offset:0];
//        [textField setSelectedTextRange:[textField textRangeFromPosition:from toPosition:to]];

        return NO;
        
    }
    
}

- (void)fillTextField:(UITextField *)textField withText:(NSString *)text {
    
    NSNumberFormatter *numberFormatter = [STMFunctions decimalMaxTwoDigitFormatter];

    NSNumber *number = [numberFormatter numberFromString:text];
    
    if (!number) {
        
        if ([text isEqualToString:@""]) {
            
            textField.text = text;
            
        }
        
    } else {
        
        if ([number doubleValue] == 0) {
            
            textField.text = text;
            
        } else {
            
            NSString *finalString = [numberFormatter stringFromNumber:number];
            
            NSString *appendingString = nil;
            
            NSString *suffix = nil;
            
            for (int i = 0; i <= 2; i++) {
                
                suffix = numberFormatter.decimalSeparator;
                
                for (int j = 0; j < i; j++) {
                    
                    suffix = [suffix stringByAppendingString:@"0"];
                    
                }
                
                appendingString = ([text hasSuffix:suffix]) ? suffix : appendingString;
                
            }

            finalString = (appendingString) ? [finalString stringByAppendingString:appendingString] : finalString;

            textField.text = finalString;
            
        }
                
    }

}

- (BOOL)isCorrectDebtSumValueForTextField:(UITextField *)textField {
    
    if (textField.text) {
        
        NSNumberFormatter *numberFormatter = [STMFunctions decimalFormatter];
        NSNumber *number = [numberFormatter numberFromString:(NSString * _Nonnull)textField.text];
        
        return [number boolValue];

    } else {
        
        return NO;
        
    }
    
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.commentTextView]) {
        
        self.commentTextView.inputAccessoryView = self.keyboardToolbar;
        
    }
    
    return YES;
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.commentTextView]) {
        
        self.commentTextView.inputAccessoryView = nil;
        
    }
    
    return YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.commentTextView]) {
        
        NSString *text = self.commentTextView.text;
        
        if ([text isEqualToString:NSLocalizedString(@"ADD COMMENT", nil)]) {
            
            self.commentTextView.text = @"";
            self.commentTextView.textColor = [UIColor blackColor];
            
        }
        
        self.initialTextFieldValue = self.commentTextView.text;
        
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.commentTextView]) {
        
        NSString *text = self.commentTextView.text;
        
        if ([text isEqualToString:@""]) {
            
            [self wipeCommentText];
            
            text = nil;
            
        }

        [[STMCashingProcessController sharedInstance] setComment:text forDebt:self.selectedDebt];
        
        if (self.textViewIsShifted) {
            
            [self moveTextFieldViewByDictance:-self.textViewShiftDistance];
            
            self.textViewIsShifted = NO;
            
        }
        
    }
    
}

- (void)wipeCommentText {
    
    self.commentTextView.text = NSLocalizedString(@"ADD COMMENT", nil);
    self.commentTextView.textColor = GREY_LINE_COLOR;

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([self.commentTextView isFirstResponder] && [touch view] != self.commentTextView) {
        
        [self.commentTextView resignFirstResponder];
        
    }
    
    [super touchesBegan:touches withEvent:event];
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.view endEditing:NO];
}


#pragma mark - keyboard show / hide

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([self.commentTextView isFirstResponder] && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        
        if (!self.textViewIsShifted) {
            
            CGFloat keyboardHeight = [self keyboardHeightFrom:[notification userInfo]];
            CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
            CGFloat textViewHeight = self.commentTextView.frame.size.height;
            CGFloat textViewOriginY = self.commentTextView.frame.origin.y;
            CGFloat viewHeight = self.view.frame.size.height;
            
            CGFloat distance = textViewOriginY+textViewHeight+keyboardHeight-viewHeight-tabBarHeight;
            
            if (distance > 0) {
                
                self.textViewShiftDistance = textViewOriginY+textViewHeight+keyboardHeight-viewHeight-tabBarHeight;
                
                [self moveTextFieldViewByDictance:self.textViewShiftDistance];
                
                self.textViewIsShifted = YES;

            }
            
        }
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {

    if ([self.commentTextView isFirstResponder] && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        
        if (self.textViewIsShifted) {
            
            [self moveTextFieldViewByDictance:-self.textViewShiftDistance];
            
            self.textViewIsShifted = NO;

        }

    }
    
}

- (CGFloat)keyboardHeightFrom:(NSDictionary *)info {
    
    CGRect keyboardRect = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardRect = [[[UIApplication sharedApplication].delegate window] convertRect:keyboardRect fromView:self.view];
    
    return keyboardRect.size.height;
    
}

- (void)moveTextFieldViewByDictance:(CGFloat)distance {
    
    const float movementDuration = 0.3f;
    
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, -distance);
    [UIView commitAnimations];
    
}


#pragma mark - observers

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(keyboardWillBeHidden:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(cashingProcessCancel)
               name:@"cashingProcessCancel"
             object:[STMCashingProcessController sharedInstance]];
    
    [nc addObserver:self
           selector:@selector(cashingProcessDone)
               name:@"cashingProcessDone"
             object:[STMCashingProcessController sharedInstance]];

    [nc addObserver:self
           selector:@selector(debtAdded:)
               name:@"debtAdded"
             object:[STMCashingProcessController sharedInstance]];

    [nc addObserver:self
           selector:@selector(debtRemoved:)
               name:@"debtRemoved"
             object:[STMCashingProcessController sharedInstance]];

    [nc addObserver:self
           selector:@selector(cashingSumChanged:)
               name:@"cashingSumChanged"
             object:[STMCashingProcessController sharedInstance]];

    [nc addObserver:self
           selector:@selector(toolbarDoneButtonPressed)
               name:@"textFieldsShouldResignResponder"
             object:nil];
    
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - view lifecycle

- (void)labelsInit {
    
    self.selectedDate = [NSDate date];
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    self.cashingSumLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"CASHING SUMM", nil), @""];
    
    self.cashingSummTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.cashingSummTextField.placeholder = NSLocalizedString(@"CASHING SUMM PLACEHOLDER", nil);
    self.cashingSummTextField.delegate = self;
    
    self.remainderLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REMAINDER", nil), @""];
    
    self.debtInfoLabel.text = nil;
    
    self.debtSumLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DEBT SUM LABEL", nil), @""];
    self.debtSumLabel.hidden = YES;
    
    self.debtSummTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.debtSummTextField.hidden = YES;
    self.debtSummTextField.delegate = self;
    
    self.summLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PICKED", nil), [numberFormatter stringFromNumber:[NSDecimalNumber zero]]];
    
    self.commentTextView.delegate = self;
    self.commentTextView.layer.borderWidth = 1.0f;
    self.commentTextView.layer.borderColor = [GREY_LINE_COLOR CGColor];
    self.commentTextView.layer.cornerRadius = 5.0f;
    self.commentTextView.hidden = YES;
    [self wipeCommentText];
    
}

- (void)customInit {
    
    self.title = NSLocalizedString(@"CASHING", nil);
    
    self.splitVC.controlsVC = self;

    self.navigationItem.leftBarButtonItem = [[STMBarButtonItemCancel alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIBarButtonItemStylePlain target:[STMCashingProcessController sharedInstance] action:@selector(cancelCashingProcess)];

    [self.navigationItem setHidesBackButton:YES animated:YES];

    [self labelsInit];

    if ([STMCashingProcessController sharedInstance].state == STMCashingProcessRunning) [self updateControlLabels];

}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self addObservers];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self removeObservers];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showDatePicker"] && [segue.destinationViewController isKindOfClass:[STMDatePickerVC class]]) {

        STMDatePickerVC *datePickerVC = (STMDatePickerVC *)segue.destinationViewController;
        datePickerVC.parentVC = self;
        datePickerVC.selectedDate = self.selectedDate;

    }

}


@end
