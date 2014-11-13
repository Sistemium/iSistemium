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

@interface STMCashingControlsVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *controlsView;
//@property (weak, nonatomic) IBOutlet UIButton *cashingButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
//@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *summLabel;
@property (weak, nonatomic) IBOutlet UITextField *debtSummTextField;
@property (weak, nonatomic) IBOutlet UILabel *remainderLabel;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *cashingSummTextField;
@property (nonatomic, strong) NSDecimalNumber *cashingSummLimit;
@property (nonatomic, strong) NSDecimalNumber *remainderSumm;

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

- (NSMutableArray *)debtsArray {
    
    if (!_debtsArray) {
        
        _debtsArray = [NSMutableArray array];
        
    }
    
    return _debtsArray;
    
}

- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        
        if (_outlet) {
            
//            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
//
//            NSString *totalSumString = [numberFormatter stringFromNumber:self.tableVC.totalSum];
//            
//            self.remainderLabel.text = [NSString stringWithFormat:@"%@", totalSumString];
            
            self.debtsDictionary = nil;
//            [self showControlsView];
            
            self.debtSummTextField.delegate = nil;
            [self.controlsView endEditing:YES];
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

- (void)refreshDateButtonTitle {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    [self.dateButton setTitle:[dateFormatter stringFromDate:self.selectedDate] forState:UIControlStateNormal];
    
}

- (void)addCashing:(STMDebt *)debt {
    
    if (debt) {
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.minimumFractionDigits = 2;

        NSMutableString *debtSum = [[numberFormatter stringFromNumber:debt.calculatedSum] mutableCopy];
        
        self.debtSummTextField.text = [NSString stringWithFormat:@"%@", debtSum];
        self.debtSummTextField.hidden = NO;

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
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

        self.debtSummTextField.text = [numberFormatter stringFromNumber:[NSDecimalNumber zero]];
        self.debtSummTextField.hidden = YES;

        self.debtSummTextField.delegate = nil;
        [self.controlsView endEditing:YES];
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

//    if ([self.splitViewController isKindOfClass:[STMDebtsSVC class]]) {
//        
//        [(STMDebtsSVC *)self.splitViewController setOutletLocked:YES];
//        
//    }

//    [self showCashingControls];
    
    if (self.splitVC.detailVC.isCashingProcessing) {
        
        [self updateControlLabels];
        [self.tableVC.tableView setEditing:YES animated:YES];

    } else {
        
        [self dismissSelf];
        
    }
    
    
}

- (void)dismissSelf {
    
    [self.tableVC.tableView setEditing:NO animated:YES];
    self.splitVC.controlsVC = nil;
    [self.navigationController popViewControllerAnimated:YES];
    
}

/*
- (IBAction)cancelButtonPressed:(id)sender {
    
    [self showCashingButton];

}
*/

- (IBAction)doneButtonPressed:(id)sender {

    if ([self.debtSummTextField isFirstResponder]) {

        [self.debtSummTextField resignFirstResponder];
        
    } else {
        
        [self saveCashings];
        [self.tableVC.tableView reloadData];
        [self dismissSelf];
        [self.splitVC.detailVC cashingButtonPressed];

    }
    
//    [self showCashingButton];

}


#pragma mark - controls view

/*
- (void)hideControlsView {
    
    self.controlsView.hidden = YES;
    
}

- (void)showControlsView {
    
    self.controlsView.hidden = NO;
    [self updateControlLabels];
    [self showCashingButton];
    
}
*/

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
    
    if ([self.remainderSumm doubleValue] < 0) {
        
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

/*
- (void)showCashingButton {
    
    [self.tableVC.tableView setEditing:NO animated:YES];
    
    if ([self.splitViewController isKindOfClass:[STMDebtsSVC class]]) {
        
        [(STMDebtsSVC *)self.splitViewController setOutletLocked:NO];
        
    }
    
    self.cashingButton.hidden = NO;
    
    self.dateButton.hidden = YES;
    self.selectedDate = [NSDate date];
    self.cancelButton.hidden = YES;
    self.doneButton.hidden = YES;
    self.summLabel.hidden = YES;
    self.remainderLabel.hidden = YES;
    self.debtSummTextField.hidden = YES;
    self.cashingSummTextField.hidden = YES;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    self.debtSummTextField.text = [numberFormatter stringFromNumber:[NSDecimalNumber zero]];
    
    self.debtsDictionary = nil;
    self.debtsArray = nil;
    self.remainderSumm = [NSDecimalNumber zero];
    self.cashingSummTextField.text = @"";
    self.cashingSummLimit = [NSDecimalNumber zero];
    
    [self updateControlLabels];
    
    [self.tableVC.tableView reloadData];

    if ([self.splitViewController isKindOfClass:[STMDebtsSVC class]]) {
        
        STMDebtsSVC *splitVC = (STMDebtsSVC *)self.splitViewController;
        NSIndexPath *indexPath = [splitVC.masterVC.resultsController indexPathForObject:self.outlet];
        [splitVC.masterVC.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }
    
}
*/

/*
- (void)showCashingControls {

//    self.cashingButton.hidden = YES;
    
    self.dateButton.hidden = NO;
//    self.cancelButton.hidden = NO;
    self.doneButton.hidden = NO;
    self.summLabel.hidden = NO;
    self.cashingSummTextField.hidden = NO;

    if ([self.cashingSummTextField.text doubleValue] > 0) {
        self.remainderLabel.hidden = NO;
    }

}
*/

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
        
        STMCashing *cashing = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMCashing class]) inManagedObjectContext:self.document.managedObjectContext];
        
        cashing.date = date;
        cashing.summ = summ;
        cashing.debt = debt;
        cashing.outlet = self.outlet;

        debt.calculatedSum = [debt cashingCalculatedSum];
        
    }
    
    [self.document saveDocument:^(BOOL success) {
        if (success) {

            STMSyncer *syncer = [STMSessionManager sharedManager].currentSession.syncer;
            syncer.syncerState = STMSyncerSendData;
            
        }
    }];

    
}

/*
- (NSDecimalNumber *)cashingCalculatedSumForDebt:(STMDebt *)debt {
    
    NSDecimalNumber *result = debt.summ;
    
    for (STMCashing *cashing in debt.cashings) {
        
        result = [result decimalNumberBySubtracting:cashing.summ];
        
    }
    
    if ([result compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        
        result = [NSDecimalNumber zero];
        
    }
    
    return result;
    
}
*/

/*
#pragma mark - keyboard show / hide

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGFloat keyboardHeight = [self keyboardHeightFrom:[notification userInfo]];
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    [self moveTextFieldViewByDictance:keyboardHeight-tabBarHeight];
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {

    CGFloat keyboardHeight = [self keyboardHeightFrom:[notification userInfo]];
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    [self moveTextFieldViewByDictance:tabBarHeight-keyboardHeight];

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
    
    CGRect tableVCFrame = self.tableVC.tableView.frame;
    CGFloat newHeight = tableVCFrame.size.height - distance;

    self.tableVC.tableView.frame = CGRectMake(tableVCFrame.origin.x, tableVCFrame.origin.y, tableVCFrame.size.width, newHeight);
    
}
*/

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.cashingSummTextField] && [self.cashingSummTextField.text isEqualToString:@""]) {
        return YES;
    } else {
        return [self isCorrectDebtSumValueForTextField:textField];
    }

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



#pragma mark - observers

- (void)addObservers {
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cashingButtonPressed:) name:@"cashingButtonPressed" object:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.splitVC.controlsVC = self;

    [self.navigationItem setHidesBackButton:YES animated:YES];

    self.selectedDate = [NSDate date];
    
//    if (!self.outlet) {
//        [self hideControlsView];
//    }
    
//    [self.cashingButton setTitle:NSLocalizedString(@"CASHING", nil) forState:UIControlStateNormal];
//    [self.cancelButton setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    self.doneButton.enabled = NO;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    self.summLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PICKED", nil), [numberFormatter stringFromNumber:[NSDecimalNumber zero]]];
    
//    NSString *totalSumString = [numberFormatter stringFromNumber:self.tableVC.totalSum];
    
    self.remainderLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REMAINDER", nil), @""];
    
    self.debtSummTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.debtSummTextField.hidden = YES;
    self.debtSummTextField.delegate = self;
    
    self.cashingSummTextField.keyboardType = UIKeyboardTypeDecimalPad;
//    self.cashingSummTextField.hidden = YES;
    self.cashingSummTextField.placeholder = NSLocalizedString(@"CASHING SUMM", nil);
    self.cashingSummTextField.delegate = self;
    
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
