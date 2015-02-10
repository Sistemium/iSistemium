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

- (void)sendPhoneNumber {
    
    [self.view addSubview:self.spinnerView];
    [[STMAuthController authController] sendPhoneNumber:@"89096216061"];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self.sendPhoneNumberButton addTarget:self action:@selector(sendPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    NSLog(@"%@ viewDidLoad", self);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
