//
//  STMAuthVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthVC.h"

@interface STMAuthVC ()

@end

@implementation STMAuthVC

- (STMUISpinnerView *)spinnerView {
    
    if (!_spinnerView) {
        _spinnerView = [STMUISpinnerView spinnerViewWithFrame:self.view.frame];
    }
    return _spinnerView;
    
}

- (void)buttonPressed {
    [self.view addSubview:self.spinnerView];
}

- (void)dismissSpinner {
    [self.spinnerView removeFromSuperview];
}

#pragma mark - view lifecycle

- (void)customInit {
    [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

//    NSLog(@"%@ viewDidLoad", self);

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.spinnerView removeFromSuperview];
    
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
