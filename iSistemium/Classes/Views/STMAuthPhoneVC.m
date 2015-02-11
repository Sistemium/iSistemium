//
//  STMAuthPhoneVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthPhoneVC.h"

@interface STMAuthPhoneVC ()

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendPhoneNumberButton;


@end


@implementation STMAuthPhoneVC

- (void)buttonPressed {

    [super buttonPressed];
    [[STMAuthController authController] sendPhoneNumber:@"89096216061"];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.title = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);

//    self.phoneNumberLabel.text =
    
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
