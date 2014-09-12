//
//  STMHandOverPopoverVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMHandOverPopoverVC.h"

@interface STMHandOverPopoverVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *uncashingSumTextField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) NSNumberFormatter *decimalNumberFormatter;

@end


@implementation STMHandOverPopoverVC


- (NSNumberFormatter *)decimalNumberFormatter {
    
    if (!_decimalNumberFormatter) {
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.minimumFractionDigits = 2;
        numberFormatter.maximumFractionDigits = 2;

        _decimalNumberFormatter = numberFormatter;
        
    }
    
    return _decimalNumberFormatter;
    
}

- (void)uncashingDone {
    
    NSDecimalNumber *summ = [NSDecimalNumber decimalNumberWithDecimal:[[self.decimalNumberFormatter numberFromString:self.uncashingSumTextField.text] decimalValue]];
    
//    NSLog(@"summ %@", summ);
    
    [self.parent uncashingDoneWithSum:summ];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    return [self isCorrectValue];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSNumber *number = [self.decimalNumberFormatter numberFromString:self.uncashingSumTextField.text];
    
    self.uncashingSumTextField.text = [self.decimalNumberFormatter stringFromNumber:number];
    
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
//    [self uncashingDone];
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = 2;

    [text replaceOccurrencesOfString:numberFormatter.groupingSeparator
                          withString:@""
                             options:NSCaseInsensitiveSearch
                               range:NSMakeRange(0, [text length])];
    
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

- (BOOL)isCorrectValue {
    
    NSNumber *number = [self.decimalNumberFormatter numberFromString:self.uncashingSumTextField.text];
    return [number boolValue];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.uncashingSumTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.uncashingSumTextField.delegate = self;
    
    self.uncashingSumTextField.text = [self.decimalNumberFormatter stringFromNumber:self.uncashingSum];
    
    [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(uncashingDone) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
