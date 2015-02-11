//
//  STMAuthSuccessVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthSuccessVC.h"

@interface STMAuthSuccessVC ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


@end

@implementation STMAuthSuccessVC

- (void)buttonPressed {
    
    [super buttonPressed];
    [[STMAuthController authController] logout];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.title = NSLocalizedString(@"SISTEMIUM", nil);

    self.button = self.logoutButton;
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
