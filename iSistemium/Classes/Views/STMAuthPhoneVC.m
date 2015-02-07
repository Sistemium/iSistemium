//
//  STMAuthVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthPhoneVC.h"

@interface STMAuthPhoneVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendPhoneButton;

@end


@implementation STMAuthPhoneVC

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

//- (void)authSuccess {
//    
//    [self performSegueWithIdentifier:@"showSuccessAuth" sender:self];
//    
//}

- (void)sendPhoneNumber {
    
    [self.view addSubview:self.spinnerView];

    [[STMAuthController authController] sendPhoneNumber:self.phoneNumberTextField.text];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([STMFunctions isCorrectPhoneNumber:textField.text]) {
        [self sendPhoneNumber];
    }

    return NO;
    
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if ([STMFunctions isCorrectPhoneNumber:textField.text]) {
        self.sendPhoneButton.enabled = YES;
    } else {
        self.sendPhoneButton.enabled = NO;
    }
    
}

- (void)authControllerStateChanged {
    
    if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
        [self performSegueWithIdentifier:@"enterSMSCode" sender:self];
//    } else if ([STMAuthController authController].controllerState == STMAuthSuccess) {
//        [self authSuccess];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"enterSMSCode"]) {
        
        NSLog(@"segue.destinationViewController %@", segue.destinationViewController);
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    [self enterPhoneNumber];
    self.navigationItem.title = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);
    NSLog(@"self %@", self);

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
