//
//  STMAuthVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthVC.h"
#import "STMAuthController.h"
#import "STMFunctions.h"

@interface STMAuthVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendPhoneButton;

@end


@implementation STMAuthVC

- (void)enterPhoneNumber {
    
    self.phoneNumberLabel.text = NSLocalizedString(@"ENTER PHONE NUMBER", nil);

    self.sendPhoneButton.enabled = NO;
    [self.sendPhoneButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
    [self.sendPhoneButton addTarget:self action:@selector(sendPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
    
    self.phoneNumberTextField.delegate = self;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.phoneNumberTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];

    if ([STMAuthController authController].phoneNumber) {
        self.phoneNumberTextField.text = [STMAuthController authController].phoneNumber;
        [self textFieldDidChange:self.phoneNumberTextField];
    }

}

- (void)enterSMSCode {
    
}

- (void)authSuccess {
    
}

- (void)sendPhoneNumber {
    [[STMAuthController authController] sendPhoneNumber:self.phoneNumberTextField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.phoneNumberTextField) {
        
        if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
            if ([STMFunctions isCorrectPhoneNumber:textField.text]) {
                [self sendPhoneNumber];
            }
        }
        return NO;
        
    }
    return YES;
    
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
        
        if ([STMFunctions isCorrectPhoneNumber:textField.text]) {
            self.sendPhoneButton.enabled = YES;
        } else {
            self.sendPhoneButton.enabled = NO;
        }

    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    if ([STMAuthController authController].controllerState == STMAuthSuccess) {
        
        self.navigationItem.title = NSLocalizedString(@"SISTEMIUM", nil);
        [self authSuccess];
        
    } else {
        
        self.navigationItem.title = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);
        
        if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
            [self enterPhoneNumber];
        } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
            [self enterSMSCode];
        }
        
    }

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
