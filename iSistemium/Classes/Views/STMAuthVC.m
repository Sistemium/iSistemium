//
//  STMAuthVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthVC.h"
#import "STMAuthController.h"

@interface STMAuthVC ()
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@end

@implementation STMAuthVC

- (void)enterPhoneNumber {
    
    self.phoneNumberLabel.text = NSLocalizedString(@"ENTER PHONE NUMBER", nil);
    [self.enterButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
    
}

- (void)enterSMSCode {
    
}

- (void)authSuccess {
    
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
