//
//  STMAddDebtVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddDebtVC.h"
#import "STMDatePickerVC.h"
#import "STMFunctions.h"
#import "STMDebtsController.h"
#import <QuartzCore/QuartzCore.h>

@interface STMAddDebtVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ndocLabel;
@property (weak, nonatomic) IBOutlet UILabel *sumLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *ndocTextField;
@property (weak, nonatomic) IBOutlet UITextField *sumTextField;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, strong) NSString *initialTextFieldValue;

@property (nonatomic, strong) NSString *debtNdoc;
@property (nonatomic, strong) NSDecimalNumber *debtSum;
@property (nonatomic, strong) NSString *commentText;

@end

@implementation STMAddDebtVC

@synthesize selectedDate = _selectedDate;

- (NSDate *)selectedDate {
    
    if (!_selectedDate) {
        
        _selectedDate = [NSDate date];
        
    }
    
    return _selectedDate;
    
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    
    if (_selectedDate != selectedDate) {
        
        _selectedDate = selectedDate;
        
        NSDateFormatter *dateFormatter = [STMFunctions dateLongNoTimeFormatter];
        [self.dateButton setTitle:[dateFormatter stringFromDate:_selectedDate] forState:UIControlStateNormal];
        
    }
    
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

- (void)toolbarCancelButtonPressed {
    
    if ([self.sumTextField isFirstResponder]) {
        
        self.sumTextField.text = self.initialTextFieldValue;
        
    } else if ([self.ndocTextField isFirstResponder]) {

        self.ndocTextField.text = self.initialTextFieldValue;

    } else if ([self.commentTextField isFirstResponder]) {
        
        self.commentTextField.text = self.initialTextFieldValue;
        
    }

    [self.view endEditing:YES];

}

- (void)toolbarDoneButtonPressed {
    
    if ([self.ndocTextField isFirstResponder]) {
        
        NSString *debtNdoc = [self.ndocTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if ([debtNdoc isEqualToString:@""]) {
            
            [self.ndocTextField becomeFirstResponder];
            [self errorStyleForTextField:self.ndocTextField];
            
        } else {
            [self checkSumField];
        }

    } else if ([self.sumTextField isFirstResponder]) {
        
        if (![self checkSumField]) {
            [self errorStyleForTextField:self.sumTextField];
        } else {
            [self.commentTextField becomeFirstResponder];
        }
        
    } else {
        
        [self.view endEditing:YES];
        
    }
    
}

- (BOOL)checkSumField {
    
    if ([self.sumTextField.text isEqualToString:@""]) {
        
        [self.sumTextField becomeFirstResponder];
        return NO;
        
    } else {
        return YES;
    }
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    [self.parentVC dismissAddDebt];
    
}

- (IBAction)doneButtonPressed:(id)sender {
    
    NSString *debtNdoc = [self.ndocTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    double debtSum = [self.sumTextField.text doubleValue];
//    NSString *debtComment = [self.commentTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([debtNdoc isEqualToString:@""]) {
        
        [self.ndocTextField becomeFirstResponder];
        [self errorStyleForTextField:self.ndocTextField];
        
        if (debtSum == 0) [self errorStyleForTextField:self.sumTextField];
        
    } else if (debtSum == 0) {
        
        [self.sumTextField becomeFirstResponder];
        [self errorStyleForTextField:self.sumTextField];
        
//    } else if ([debtComment isEqualToString:@""]) {
//        
//        [self.commentTextField becomeFirstResponder];
        
    } else {

        [self.view endEditing:NO];
        
//        NSLog(@"self.debtSum %@", self.debtSum);

        [STMDebtsController addNewDebtWithSum:self.debtSum ndoc:self.debtNdoc date:self.selectedDate outlet:self.parentVC.outlet comment:self.commentText];
        [self.parentVC dismissAddDebt];

    }
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    textField.inputAccessoryView = self.keyboardToolbar;
    
    return YES;
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.sumTextField]) {
        
        return ([textField.text isEqualToString:@""] || [self isCorrectDebtSumValueForTextField:textField]);
        
    } else {
        
        return YES;
        
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.initialTextFieldValue = textField.text;
    [textField selectAll:nil];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.text) {
        
        NSNumberFormatter *numberFormatter = [STMFunctions decimalMaxTwoMinTwoDigitFormatter];
        
        if ([textField isEqual:self.sumTextField]) {
            
            NSNumber *number = [numberFormatter numberFromString:(NSString * _Nonnull)textField.text];
            textField.text = [numberFormatter stringFromNumber:number];
            
            numberFormatter.numberStyle = NSNumberFormatterNoStyle;
            NSString *decimalNumberString = [numberFormatter stringFromNumber:number];
            NSDictionary *local = @{NSLocaleDecimalSeparator: numberFormatter.decimalSeparator};
            
            self.debtSum = [NSDecimalNumber decimalNumberWithString:decimalNumberString locale:local];
            
        } else if ([textField isEqual:self.ndocTextField]) {
            
            self.debtNdoc = textField.text;
            if (![self checkSumField]) [self okStyleForTextField:self.sumTextField];
            
        } else if ([textField isEqual:self.commentTextField]) {
            
            self.commentText = textField.text;
            if (![self checkSumField]) [self okStyleForTextField:self.sumTextField];
            
        }
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isEqual:self.sumTextField]) {

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
            
            return NO;
            
        }

    } else {
        
        [self okStyleForTextField:textField];
        return YES;
        
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
        
        [self okStyleForTextField:textField];
        
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

- (void)okStyleForTextField:(UITextField *)textField {
    
    textField.layer.borderWidth = 1.0;
    textField.layer.cornerRadius = 8.0;
    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
}

- (void)errorStyleForTextField:(UITextField *)textField {
    
    textField.layer.borderWidth = 1.0;
    textField.layer.cornerRadius = 8.0;
    textField.layer.borderColor = [[UIColor redColor] CGColor];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    NSDateFormatter *dateFormatter = [STMFunctions dateLongNoTimeFormatter];
    
    [self.dateButton setTitle:[dateFormatter stringFromDate:self.selectedDate] forState:UIControlStateNormal];
    
    self.dateLabel.text = NSLocalizedString(@"DOC DATE", nil);
    self.ndocLabel.text = NSLocalizedString(@"DOC NUMBER", nil);
    self.sumLabel.text = NSLocalizedString(@"DEBT SUM", nil);
    self.commentLabel.text = NSLocalizedString(@"DEBT COMMENT", nil);
    
    self.ndocTextField.delegate = self;
    self.ndocTextField.keyboardType = UIKeyboardTypeDefault;
    
    self.sumTextField.delegate = self;
    self.sumTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    self.commentTextField.delegate = self;
    self.commentTextField.keyboardType = UIKeyboardTypeDefault;
    
    [self.ndocTextField becomeFirstResponder];
    
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
