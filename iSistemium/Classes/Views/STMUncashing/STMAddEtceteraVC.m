//
//  STMAddEtceteraVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAddEtceteraVC.h"
#import "STMDatePickerVC.h"
#import "STMFunctions.h"
#import "STMCashingController.h"

#import <QuartzCore/QuartzCore.h>

@interface STMAddEtceteraVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *sumLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UITextField *sumTextField;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@property (weak, nonatomic) IBOutlet UIToolbar *doneButton;
@property (weak, nonatomic) IBOutlet UIToolbar *cancelButton;

@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, strong) NSString *initialTextFieldValue;

@property (nonatomic, strong) NSString *ndoc;
@property (nonatomic, strong) NSDecimalNumber *sum;
@property (nonatomic, strong) NSString *commentText;


@end

@implementation STMAddEtceteraVC


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
        toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, TOOLBAR_HEIGHT);
        
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
        
    } else if ([self.numberTextField isFirstResponder]) {
        
        self.numberTextField.text = self.initialTextFieldValue;
        
    } else if ([self.commentTextField isFirstResponder]) {
        
        self.commentTextField.text = self.initialTextFieldValue;
        
    }
    
    [self.view endEditing:NO];
    
}

- (void)toolbarDoneButtonPressed {

    if ([self.sumTextField isFirstResponder]) {
        
        [self.commentTextField becomeFirstResponder];
        [self checkSumField];
        
    } else if ([self.numberTextField isFirstResponder]) {
        
        [self.sumTextField becomeFirstResponder];
        
    } else if ([self.commentTextField isFirstResponder]) {
        
        [self.commentTextField resignFirstResponder];
        
    }
    
//    [self.view endEditing:NO];
    
}


- (void)checkSumField {
    
    if ([self.sumTextField.text isEqualToString:@""]) {
        
        [self.sumTextField becomeFirstResponder];
        
    }
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.parentVC dismissAddCashingPopover];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    [self.view endEditing:NO];

    if ([self textFieldFillingIsCorrect]) {
        
        [STMCashingController addCashingWithSum:self.sum ndoc:self.ndoc date:self.selectedDate comment:self.commentText debt:nil outlet:nil type:self.cashingType];
        
        [self.parentVC dismissAddCashingPopover];

    }
    
}

- (BOOL)textFieldFillingIsCorrect {
    
    BOOL result = YES;
    UITextField *textFieldToSelect = nil;
    
    if (!self.commentText || [[self.commentText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        
        [self errorStyleForTextField:self.commentTextField];
        result = NO;
        textFieldToSelect = self.commentTextField;
        
    }

    if (!self.sum) {
        
        [self errorStyleForTextField:self.sumTextField];
        result = NO;
        textFieldToSelect = self.sumTextField;
        
    }

    if (!self.ndoc || [[self.ndoc stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        
        [self errorStyleForTextField:self.numberTextField];
        result = NO;
        textFieldToSelect = self.numberTextField;
        
    }
    
    if (textFieldToSelect) [textFieldToSelect becomeFirstResponder];
    
    return result;

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
    
    NSNumberFormatter *numberFormatter = [STMFunctions decimalMaxTwoMinTwoDigitFormatter];
    
    if ([textField isEqual:self.sumTextField] && textField.text) {
        
        NSNumber *number = [numberFormatter numberFromString:(NSString * _Nonnull)textField.text];
        textField.text = [numberFormatter stringFromNumber:number];
        
        numberFormatter.numberStyle = NSNumberFormatterNoStyle;
        NSString *decimalNumberString = [numberFormatter stringFromNumber:number];
        NSDictionary *local = @{NSLocaleDecimalSeparator: numberFormatter.decimalSeparator};
        
        if (!decimalNumberString) {
            self.sum = nil;
        } else {
            self.sum = [NSDecimalNumber decimalNumberWithString:decimalNumberString locale:local];    
        }
        
    } else if ([textField isEqual:self.numberTextField]) {
        
        self.ndoc = textField.text;
        
    } else if ([textField isEqual:self.commentTextField]) {
        
        self.commentText = self.commentTextField.text;
        
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
        
        if ([text isEqualToString:@""]/* || [text isEqualToString:@"-"]*/) {
            
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
    self.numberLabel.text = NSLocalizedString(@"DOC NUMBER", nil);
    self.sumLabel.text = NSLocalizedString(@"SUM", nil);
    
    if (self.cashingType == STMCashingEtcetera) {
        self.commentLabel.text = NSLocalizedString(@"OUTLET", nil);
    } else if (self.cashingType == STMCashingDeduction) {
        self.commentLabel.text = NSLocalizedString(@"BASIS", nil);
    } else {
        self.commentLabel.text = NSLocalizedString(@"COMMENT", nil);
    }
    
    self.numberTextField.delegate = self;
    self.numberTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.numberTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self okStyleForTextField:self.numberTextField];

    [self.numberTextField becomeFirstResponder];
    
    self.sumTextField.delegate = self;
    self.sumTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.sumTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self okStyleForTextField:self.sumTextField];
    
    self.commentTextField.delegate = self;
    self.commentTextField.keyboardType = UIKeyboardTypeDefault;
    self.commentTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self okStyleForTextField:self.commentTextField];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
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
