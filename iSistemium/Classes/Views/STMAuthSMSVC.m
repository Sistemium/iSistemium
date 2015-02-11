//
//  STMAuthSMSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthSMSVC.h"

@interface STMAuthSMSVC ()

@property (weak, nonatomic) IBOutlet UILabel *enterSMSLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterSMSTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendSMSButton;


@end

@implementation STMAuthSMSVC

- (void)buttonPressed {

    [super buttonPressed];
    [[STMAuthController authController] sendSMSCode:@"1234"];
    
}

- (void)backToPhoneNumber {
    [STMAuthController authController].controllerState = STMAuthEnterPhoneNumber;
}

#pragma mark - view lifecycle

- (void)customInit {

    self.navigationItem.title = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);
    
    NSString *title = [@"< " stringByAppendingString:[STMAuthController authController].phoneNumber];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backToPhoneNumber)];
    
    self.enterSMSLabel.text = NSLocalizedString(@"ENTER SMS CODE", nil);

    [self.sendSMSButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
    self.sendSMSButton.enabled = [STMFunctions isCorrectSMSCode:self.enterSMSTextField.text];

    self.button = self.sendSMSButton;
    [super customInit];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];    

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
