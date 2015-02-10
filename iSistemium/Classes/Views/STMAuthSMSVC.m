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

- (void)sendSMS {

    [self.view addSubview:self.spinnerView];
    [[STMAuthController authController] sendSMSCode:@"1234"];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    [self.sendSMSButton addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"%@ viewDidLoad", self);
    
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
