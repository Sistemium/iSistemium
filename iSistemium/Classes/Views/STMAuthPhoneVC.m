//
//  STMAuthPhoneVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthPhoneVC.h"

@interface STMAuthPhoneVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendPhoneNumberButton;


@end


@implementation STMAuthPhoneVC

- (void)buttonPressed {

    [super buttonPressed];
    [[STMAuthController authController] sendPhoneNumber:self.phoneNumberTextField.text];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([STMFunctions isCorrectPhoneNumber:textField.text]) {
        [self buttonPressed];
    }
    return NO;

}

- (void)textFieldDidChange:(UITextField *)textField {
    
    self.sendPhoneNumberButton.enabled = [STMFunctions isCorrectPhoneNumber:textField.text];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.title = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);
    
    self.phoneNumberLabel.text = NSLocalizedString(@"ENTER PHONE NUMBER", nil);
    
    self.phoneNumberTextField.delegate = self;
    [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.phoneNumberTextField becomeFirstResponder];
//    [self.phoneNumberTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];

    if ([STMAuthController authController].phoneNumber) {
        self.phoneNumberTextField.text = [STMAuthController authController].phoneNumber;
    }
    
//    [self textFieldDidChange:self.phoneNumberTextField];

    [self.sendPhoneNumberButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
    
    self.button = self.sendPhoneNumberButton;
    [super customInit];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
