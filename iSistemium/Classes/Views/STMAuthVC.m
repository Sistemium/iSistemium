//
//  STViewController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAuthVC.h"
#import "STMAuthController.h"
#import "STMFunctions.h"
#import "STMRootVC.h"

@interface STMAuthVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authInfoLabel;
@property (weak, nonatomic) IBOutlet UITextField *authInfoTextField;
@property (weak, nonatomic) IBOutlet UIButton *requestSMSCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *phoneInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *changePhoneNumberButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainViewBarButton;

@property (nonatomic) STMAuthState viewState;
@property (nonatomic, strong) STMAuthController *authController;


@end


@implementation STMAuthVC


#pragma mark - variables setters & getters

@synthesize viewState = _viewState;

- (STMAuthController *)authController {
    
    return [STMAuthController authController];
    
}

- (void)setViewState:(STMAuthState)viewState {
    
    _viewState = viewState;
    
//    NSLog(@"_viewState %d", _viewState);

    if (_viewState == STMAuthEnterPhoneNumber) {

        [self prepareForEnterPhoneNumber];
        
    } else if (_viewState == STMAuthEnterSMSCode) {
        
        [self prepareForEnterSMSCode];
        
    } else if (self.viewState == STMAuthSuccess) {
        
        [self showAuthInfo];
//        [self mainViewBarButtonPressed:self.mainViewBarButton];
        [(STMRootVC *)self.tabBarController showTabWithName:@"STMCampaigns"];
        
    }

}


#pragma mark - view layout

- (void)prepareForEnterPhoneNumber {
    
    [self.spinner stopAnimating];
    
    self.mainViewBarButton.enabled = NO;
    
    self.titleLabel.text = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);
    
    self.phoneInfoLabel.hidden = YES;
    
    self.changePhoneNumberButton.hidden = YES;
    
    self.requestSMSCodeButton.hidden = YES;
    
    [self.sendButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
    self.sendButton.hidden = NO;
    
    self.authInfoLabel.text = NSLocalizedString(@"ENTER PHONE NUMBER", nil);
    self.authInfoLabel.hidden = NO;

    self.authInfoTextField.placeholder = @"89091234567";
    [self.authInfoTextField becomeFirstResponder];
    self.authInfoTextField.hidden = NO;
    
    if (self.authController.phoneNumber) {
        self.authInfoTextField.text = self.authController.phoneNumber;
        [self textFieldDidChange:self.authInfoTextField];
    }
    
}

- (void)prepareForEnterSMSCode {
    
    [self.spinner stopAnimating];
    
    self.phoneInfoLabel.text = self.authController.phoneNumber;
    self.phoneInfoLabel.hidden = NO;
    
    [self.changePhoneNumberButton setTitle:NSLocalizedString(@"CHANGE", nil) forState:UIControlStateNormal];
    self.changePhoneNumberButton.enabled = YES;
    self.changePhoneNumberButton.hidden = NO;

    self.requestSMSCodeButton.enabled = YES;
    self.requestSMSCodeButton.hidden = NO;

    self.authInfoLabel.text = NSLocalizedString(@"ENTER SMS CODE", nil);
    
    self.authInfoTextField.text = @"";
    self.authInfoTextField.placeholder = @"XXXX";
    [self.authInfoTextField becomeFirstResponder];

}

- (void)showAuthInfo {
    
    self.titleLabel.text = NSLocalizedString(@"SISTEMIUM", nil);
    
    [self.spinner stopAnimating];
    
    self.mainViewBarButton.enabled = YES;
    
    self.phoneInfoLabel.text = self.authController.phoneNumber;
    
    [self.changePhoneNumberButton setTitle:NSLocalizedString(@"LOGOUT", nil) forState:UIControlStateNormal];
    self.changePhoneNumberButton.enabled = YES;
    
    self.authInfoLabel.hidden = YES;
    
    self.requestSMSCodeButton.hidden = YES;
    
    self.authInfoTextField.hidden = YES;
    [self.authInfoTextField resignFirstResponder];
    
    self.sendButton.hidden = YES;
    
}


#pragma mark - buttons

- (IBAction)sendButtonPressed:(id)sender {

    self.sendButton.enabled = NO;
    [self.spinner startAnimating];

    if (self.viewState == STMAuthEnterPhoneNumber) {
        
        [self.authController sendPhoneNumber:self.authInfoTextField.text];
        
    } else if (self.viewState == STMAuthEnterSMSCode) {
        
        self.changePhoneNumberButton.enabled = NO;
        self.requestSMSCodeButton.enabled = NO;

        [self.authController sendSMSCode:self.authInfoTextField.text];
        
    }
    
}

- (IBAction)changePhoneNumberButtonPressed:(id)sender {
    
    if (self.viewState == STMAuthSuccess) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOGOUT", nil) message:NSLocalizedString(@"R U SURE TO LOGOUT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alertView.tag = 2;
        [alertView show];
        
    } else {
        
        self.authController.controllerState = STMAuthEnterPhoneNumber;
        
    }
    
}

- (IBAction)requestSMSCodeButtonPressed:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NEW SMS CODE ALERT TITLE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alertView.tag = 1;
    [alertView show];

}

- (IBAction)mainViewBarButtonPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"showCampaignTVC" sender:self];

}


#pragma mark - notifications

- (void)authControllerError:(NSNotification *)notification {
    
    [self.authInfoTextField resignFirstResponder];
    
    NSString *error = [[notification userInfo] objectForKey:@"error"];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.tag = 0;
    [alertView show];
    
}

- (void)authControllerStateChanged {

        self.viewState = self.authController.controllerState;
    
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (alertView.tag) {

        case 0:
            [self.authInfoTextField becomeFirstResponder];
            break;
            
        case 1:
            if (buttonIndex == 1) {
                self.changePhoneNumberButton.enabled = NO;
                self.requestSMSCodeButton.enabled = NO;
                [self.authController requestNewSMSCode];
            }
            break;
            
        case 2:
            if (buttonIndex == 1) {
                [self.changePhoneNumberButton setTitle:NSLocalizedString(@"CHANGE", nil) forState:UIControlStateNormal];
                [self.authController logout];
            }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.authInfoTextField) {

        if (self.sendButton.enabled) {
            
            [self sendButtonPressed:self.sendButton];
            
        }
        
        return NO;
        
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if (self.viewState == STMAuthEnterPhoneNumber) {
        
        self.sendButton.enabled = [STMFunctions isCorrectPhoneNumber:textField.text];
        
    } else if (self.viewState == STMAuthEnterSMSCode) {
        
        self.sendButton.enabled = [STMFunctions isCorrectSMSCode:textField.text];
        
    }
    
}


#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authControllerError:) name:@"authControllerError" object:self.authController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authControllerStateChanged) name:@"authControllerStateChanged" object:self.authController];

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"authControllerError" object:self.authController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"authControllerStateChanged" object:self.authController];
    
}

- (void)customInit {
    
    [self addObservers];
    
    self.authInfoTextField.delegate = self;
    [self.authInfoTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.authInfoTextField.keyboardType = UIKeyboardTypeNumberPad;

    self.spinner.hidesWhenStopped = YES;
    
    [self.sendButton setTitleColor:self.sendButton.tintColor forState:UIControlStateNormal];
    
    [self.requestSMSCodeButton setTitle:NSLocalizedString(@"NEW SMS CODE", nil) forState:UIControlStateNormal];
    [self.mainViewBarButton setTitle:NSLocalizedString(@"MAIN VIEW BUTTON TITLE", nil)];
    
    
    self.viewState = self.authController.controllerState;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!self.authInfoTextField.hidden) {
        [self.authInfoTextField becomeFirstResponder];
    }
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    [self removeObservers];
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
    }

}

@end
