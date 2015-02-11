//
//  STMAuthPhoneVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthPhoneVC.h"

@interface STMAuthPhoneVC () //<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendPhoneNumberButton;


@end


@implementation STMAuthPhoneVC

- (void)buttonPressed {

    [super buttonPressed];
    
    BOOL success = [[STMAuthController authController] sendPhoneNumber:self.phoneNumberTextField.text];
    if (!success) [self.spinnerView removeFromSuperview];
    
}

- (BOOL)isCorrectValue:(NSString *)textFieldValue {
    return [STMFunctions isCorrectPhoneNumber:textFieldValue];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.title = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);
    self.phoneNumberLabel.text = NSLocalizedString(@"ENTER PHONE NUMBER", nil);
    self.phoneNumberTextField.text = [STMAuthController authController].phoneNumber;
    [self.sendPhoneNumberButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];

    self.textField = self.phoneNumberTextField;
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
