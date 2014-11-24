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
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMSyncer.h"
#import "STMCashing.h"
#import "STMDebt+Cashing.h"
#import "STMDatePickerVC.h"

@interface STMCashingControlsVC () <UITextFieldDelegate, UITextViewDelegate>

//@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *summLabel;
@property (weak, nonatomic) IBOutlet UITextField *debtSummTextField;
@property (weak, nonatomic) IBOutlet UILabel *remainderLabel;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *cashingSummTextField;
@property (weak, nonatomic) IBOutlet UILabel *cashingSumLabel;
//@property (weak, nonatomic) IBOutlet UITextView *debtInfoTextView;
@property (weak, nonatomic) IBOutlet UILabel *debtSumLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *debtInfoLabel;

@property (nonatomic) CGFloat textViewShiftDistance;
@property (nonatomic) BOOL textViewIsShifted;

@property (nonatomic, strong) UIToolbar *keyboardToolbar;

@property (nonatomic, strong) NSDecimalNumber *cashingSummLimit;
@property (nonatomic, strong) NSDecimalNumber *remainderSumm;
@property (nonatomic, strong) NSString *initialTextFieldValue;
@property (nonatomic, strong) NSMutableDictionary *commentsDictionary;


@property (nonatomic, strong) STMDebtsSVC *splitVC;
@property (nonatomic, strong) STMDocument *document;
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

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (NSMutableDictionary *)debtsDictionary {
    
    if (!_debtsDictionary) {
        
        _debtsDictionary = [NSMutableDictionary dictionary];
        
    }
    
    return _debtsDictionary;
    
}

- (NSMutableDictionary *)commentsDictionary {
    
    if (!_commentsDictionary) {
        
        _commentsDictionary = [NSMutableDictionary dictionary];
        
    }
    
    return _commentsDictionary;
    
}

- (NSMutableArray *)debtsArray {
    
    if (!_debtsArray) {
        
        _debtsArray = [NSMutableArray array];
        
    }
    
    return _debtsArray;
    
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
            
            self.debtsDictionary = nil;
            self.debtSummTextField.delegate = nil;
//            [self.controlsView endEditing:YES];
            self.debtSummTextField.delegate = self;
            
        }
        
    }
    
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    
    if (_selectedDate != selectedDate) {
        
        _selectedDate = selectedDate;
        
        [self refreshDateButtonTitle];
        
    }
    
}

- (void)setSelectedDebt:(STMDebt *)selectedDebt {
    
    if (_selectedDebt != selectedDebt) {
        
        _selectedDebt = selectedDebt;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.minimumFractionDigits = 2;

        if (selectedDebt) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
            
            NSString *debtDate = [dateFormatter stringFromDate:selectedDebt.date];
            
            self.debtInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DEBT INFO", nil), selectedDebt.ndoc, debtDate];

            NSDecimalNumber *cashingSum = [self.debtsDictionary objectForKey:selectedDebt.xid][1];
            
            NSMutableString *cashingSumString = [[numberFormatter stringFromNumber:cashingSum] mutableCopy];
            
            self.debtSummTextField.text = [NSString stringWithFormat:@"%@", cashingSumString];
            self.debtSummTextField.hidden = NO;
            self.debtSumLabel.hidden = NO;
            self.commentTextView.hidden = NO;
            
            NSString *commentText = [self.commentsDictionary objectForKey:selectedDebt.xid];
            
            if (commentText) {
                
                self.commentTextView.textColor = [UIColor blackColor];
                self.commentTextView.text = commentText;
                
            } else {
                
                [self wipeCommentText];
                
            }

            [self.tableVC updateRowWithDebt:selectedDebt];

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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    [self.dateButton setTitle:[dateFormatter stringFromDate:self.selectedDate] forState:UIControlStateNormal];
    
}

- (void)addCashing:(STMDebt *)debt {
    
    if (debt) {
        
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
//        numberFormatter.minimumFractionDigits = 2;
//
//        NSMutableString *debtSum = [[numberFormatter stringFromNumber:debt.calculatedSum] mutableCopy];
//        
//        self.debtSummTextField.text = [NSString stringWithFormat:@"%@", debtSum];
//        self.debtSummTextField.hidden = NO;
//        self.debtSumLabel.hidden = NO;

        STMDebt *lastDebt = [self.debtsArray lastObject];

        [self.debtsDictionary setObject:@[debt, debt.calculatedSum] forKey:debt.xid];
        [self.debtsArray addObject:debt];
        
        self.selectedDebt = debt;
        
        self.remainderSumm = [self.remainderSumm decimalNumberBySubtracting:debt.calculatedSum];
        
        [self.tableVC updateRowWithDebt:lastDebt];
        [self.tableVC updateRowWithDebt:debt];

        [self updateControlLabels];
        
    }
    
}

- (void)removeCashing:(STMDebt *)debt {
    
    if (debt && [[self.debtsDictionary allKeys] containsObject:debt.xid]) {
        
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
//
//        self.debtSummTextField.text = [numberFormatter stringFromNumber:[NSDecimalNumber zero]];
//        self.debtSummTextField.hidden = YES;
//        self.debtSumLabel.hidden = YES;

        self.debtSummTextField.delegate = nil;
//        [self.controlsView endEditing:YES];
        self.debtSummTextField.delegate = self;

        [self.debtsDictionary removeObjectForKey:debt.xid];
        [self.debtsArray removeObject:debt];
        
        self.selectedDebt = [self.debtsArray lastObject];
        
        self.remainderSumm = [self.cashingSummLimit decimalNumberBySubtracting:[self debtsSumm]];
        
        [self.tableVC updateRowWithDebt:debt];
        [self updateControlLabels];
        
    }
    
}


#pragma mark - buttons pressed

- (IBAction)cashingButtonPressed:(id)sender {

    if (self.splitVC.detailVC.isCashingProcessing) {
        
        [self updateControlLabels];
        [self.tableVC.tableView setEditing:YES animated:YES];

    } else {
        
        [self dismissSelf];
        
    }
    
    
}

- (void)dismissSelf {
    
    self.splitVC.controlsVC = nil;
    [self.tableVC.tableView setEditing:NO animated:YES];
    [self.tableVC.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)doneButtonPressed:(id)sender {

    if ([self.debtSummTextField isFirstResponder]) {

        [self.debtSummTextField resignFirstResponder];
        
    } else {
        
        if ([self.remainderSumm doubleValue] == 0) {
            
            [self saveCashings];
            [self dismissSelf];
            [self.splitVC.detailVC cashingButtonPressed];

        } else {

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"REM SUM NOT NULL", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];

        }
        

    }
    
}

- (void)toolbarDoneButtonPressed {
    
    [self.view endEditing:NO];
    
//    if ([self.debtSummTextField isFirstResponder]) {
//        
//        [self.debtSummTextField resignFirstResponder];
//        
//    } else if ([self.cashingSummTextField isFirstResponder]) {
//        
//        [self.cashingSummTextField resignFirstResponder];
//        
//    }
    
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
    
    if ([self.cashingSummLimit doubleValue] > 0) {

        [self controlLabelsWithCashingLimit];
        
    } else {

        [self controlLabelsWOCashingLimit];

    }
    
}

- (NSDecimalNumber *)fillingSumProcessing {

    NSDecimalNumber *fillingSumm = [NSDecimalNumber zero];

    STMDebt *lastDebt = [self.debtsArray lastObject];    
    if (lastDebt) {
        
        NSDecimalNumber *cashingSum = [self.debtsDictionary objectForKey:lastDebt.xid][1];
        fillingSumm = [self.remainderSumm decimalNumberByAdding:cashingSum];
        
    }
    
    if ([fillingSumm doubleValue] < 0) {
        
        [self.debtsArray removeObject:lastDebt];
        [self.debtsDictionary removeObjectForKey:lastDebt.xid];
        [self.tableVC updateRowWithDebt:lastDebt];
        self.remainderSumm = fillingSumm;
        self.selectedDebt = [self.debtsArray lastObject];
        
        return [self fillingSumProcessing];
        
    } else {
        
        return fillingSumm;
        
    }
    
}

- (void)controlLabelsWithCashingLimit {
    
    self.remainderLabel.hidden = NO;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if ([self.remainderSumm doubleValue] <= 0) {
        
        NSDecimalNumber *fillingSumm = [self fillingSumProcessing];

        numberFormatter.minimumFractionDigits = 2;
        self.debtSummTextField.text = [numberFormatter stringFromNumber:fillingSumm];
        self.remainderLabel.textColor = [UIColor redColor];
        
        [self.debtsDictionary setObject:@[self.selectedDebt, fillingSumm] forKey:self.selectedDebt.xid];
        [self.tableVC updateRowWithDebt:self.selectedDebt];
        
        numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        NSString *remainderSumString = [numberFormatter stringFromNumber:[NSDecimalNumber zero]];
        self.remainderLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REMAINDER", nil), remainderSumString];
        
        self.cashingLimitIsReached = YES;
        
        self.remainderSumm = [NSDecimalNumber zero];
        
    } else {
        
        numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        NSString *remainderSumString = [numberFormatter stringFromNumber:self.remainderSumm];
        self.remainderLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REMAINDER", nil), remainderSumString];
        self.remainderLabel.textColor = [UIColor blackColor];
        
        self.cashingLimitIsReached = NO;
        
    }
    
    [self showCashingSumLabel];

}

- (void)controlLabelsWOCashingLimit {
    
    self.remainderLabel.hidden = YES;
    
    self.cashingLimitIsReached = NO;

    [self showCashingSumLabel];

}

- (void)showCashingSumLabel {
    
    NSDecimalNumber *sum = [NSDecimalNumber zero];
    
    for (NSArray *debtValues in [self.debtsDictionary allValues]) {
        
        NSDecimalNumber *cashing = debtValues[1];
        
        sum = [sum decimalNumberByAdding:cashing];
        
    }
    
    self.doneButton.enabled = (sum.floatValue > 0);
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSString *sumString = [numberFormatter stringFromNumber:sum];
    self.summLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PICKED", nil), sumString];

}

- (NSDecimalNumber *)debtsSumm {
    
    NSDecimalNumber *sum = [NSDecimalNumber zero];

    for (NSArray *debtValues in [self.debtsDictionary allValues]) {
        
        NSDecimalNumber *cashing = debtValues[1];
        
        sum = [sum decimalNumberByAdding:cashing];
        
    }
    
    return sum;
    
}

#pragma mark - save cashings

- (void)saveCashings {
    
    NSDate *date = self.selectedDate;
    
    for (NSArray *debtArray in [self.debtsDictionary allValues]) {
    
        STMDebt *debt = debtArray[0];
        NSDecimalNumber *summ = debtArray[1];
        NSString *commentText = [self.commentsDictionary objectForKey:debt.xid];
        
        STMCashing *cashing = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMCashing class]) inManagedObjectContext:self.document.managedObjectContext];
        
        cashing.date = date;
        cashing.summ = summ;
        cashing.debt = debt;
        cashing.commentText = commentText;
        cashing.outlet = self.outlet;

        debt.calculatedSum = [debt cashingCalculatedSum];
        
    }
    
    [self.document saveDocument:^(BOOL success) {
        if (success) {

            STMSyncer *syncer = [STMSessionManager sharedManager].currentSession.syncer;
            syncer.syncerState = STMSyncerSendDataOnce;
            
        }
    }];

    
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
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumFractionDigits = 2;
    
    if ([textField isEqual:self.debtSummTextField]) {
        
        NSNumber *number = [numberFormatter numberFromString:self.debtSummTextField.text];
        NSDecimalNumber *cashingSum = [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
        
        [self.debtsDictionary setObject:@[self.selectedDebt, cashingSum] forKey:self.selectedDebt.xid];
        
        [self.tableVC updateRowWithDebt:self.selectedDebt];
        
        self.debtSummTextField.text = [numberFormatter stringFromNumber:number];
        
        self.remainderSumm = [self.cashingSummLimit decimalNumberBySubtracting:[self debtsSumm]];
        
    } else if ([textField isEqual:self.cashingSummTextField]) {
        
        NSNumber *number = [numberFormatter numberFromString:self.cashingSummTextField.text];
        self.cashingSummTextField.text = [numberFormatter stringFromNumber:number];
        self.cashingSummLimit = [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
        self.remainderSumm = [self.cashingSummLimit decimalNumberBySubtracting:[self debtsSumm]];
        
    }
    
    [self updateControlLabels];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = 2;
    
    [text replaceOccurrencesOfString:numberFormatter.groupingSeparator withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [text length])];

    NSNumber *number = [numberFormatter numberFromString:[NSString stringWithFormat:@"%@", text]];
    
    if (!number) {
        
        if ([text isEqualToString:@""]) {
            
            textField.text = text;
            
        }
        
        return NO;
        
    } else {

        NSString *finalString = [numberFormatter stringFromNumber:number];

        if ([string isEqualToString:numberFormatter.decimalSeparator]) {
            
            finalString = [finalString stringByAppendingString:numberFormatter.decimalSeparator];
            
        }
        
        textField.text = finalString;
        
        return NO;

    }
    
}

- (BOOL)isCorrectDebtSumValueForTextField:(UITextField *)textField {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSNumber *number = [numberFormatter numberFromString:textField.text];
    
    return [number boolValue];
    
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
            
            if (self.selectedDebt.xid) {
                [self.commentsDictionary removeObjectForKey:self.selectedDebt.xid];
            }
            
        } else {
            
            if (self.selectedDebt.xid) {
                [self.commentsDictionary setObject:text forKey:self.selectedDebt.xid];
            }
            
        }
        
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


#pragma mark - keyboard show / hide

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([self.commentTextView isFirstResponder] && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
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

    if ([self.commentTextView isFirstResponder] && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        if (self.textViewIsShifted) {
            
            [self moveTextFieldViewByDictance:-self.textViewShiftDistance];
            
            self.textViewIsShifted = NO;

        }

    }
    
}

- (CGFloat)keyboardHeightFrom:(NSDictionary *)info {
    
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cashingButtonPressed:) name:@"cashingButtonPressed" object:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.title = NSLocalizedString(@"CASHING", nil);
    
    self.splitVC.controlsVC = self;

    [self.navigationItem setHidesBackButton:YES animated:YES];

    self.selectedDate = [NSDate date];
    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    self.cashingSumLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"CASHING SUMM", nil), @""];
    
    self.cashingSummTextField.keyboardType = UIKeyboardTypeDecimalPad;
    //    self.cashingSummTextField.hidden = YES;
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

    [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    self.doneButton.enabled = NO;

    [self cashingButtonPressed:nil];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
