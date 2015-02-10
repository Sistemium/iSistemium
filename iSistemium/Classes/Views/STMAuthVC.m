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


#pragma mark - view lifecycle

- (void)customInit {
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillDisappear:(BOOL)animated {
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
