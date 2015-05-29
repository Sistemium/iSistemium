//
//  STMOrdersSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersSVC.h"
#import "STMOrdersListTVC.h"


@interface STMOrdersSVC ()

@end

@implementation STMOrdersSVC

- (STMOrdersMasterNC *)masterNC {
    
    if (!_masterNC) {
        if ([self.viewControllers[0] isKindOfClass:[STMOrdersMasterNC class]]) {
            _masterNC = self.viewControllers[0];
        }
    }
    return _masterNC;
    
}

- (STMOrdersMasterPVC *)masterPVC {
    
    if (!_masterPVC) {
        
        UINavigationController *nc = (UINavigationController *)self.viewControllers[0];
        UIViewController *masterPVC = nc.viewControllers[0];
        
        if ([masterPVC isKindOfClass:[STMOrdersMasterPVC class]]) {
            _masterPVC = (STMOrdersMasterPVC *)masterPVC;
        }
        
    }
    return _masterPVC;
    
}

- (STMOrdersDetailTVC *)detailTVC {
    
    if (!_detailTVC) {
    
        UINavigationController *nc = (UINavigationController *)self.viewControllers[1];
        UIViewController *detailTVC = nc.viewControllers[0];

        if ([detailTVC isKindOfClass:[STMOrdersDetailTVC class]]) {
            _detailTVC = (STMOrdersDetailTVC *)detailTVC;
        }
        
    }
    return _detailTVC;
    
}

- (void)setSelectedDate:(NSDate *)selectedDate {

    _selectedDate = selectedDate;
    [self stateUpdate];
    
}

- (void)setSelectedOutlet:(STMOutlet *)selectedOutlet {
    
    _selectedOutlet = selectedOutlet;
    [self stateUpdate];
    
}

- (void)setSelectedSalesman:(STMSalesman *)selectedSalesman {
    
    _selectedSalesman = selectedSalesman;
    [self stateUpdate];
    
}

- (void)stateUpdate {
    
    [self.masterPVC updateResetFilterButtonState];
    [self.detailTVC refreshTable];
    
}

- (void)orderWillSelected {
    
    STMOrdersListTVC *ordersListTVC = [[STMOrdersListTVC alloc] initWithStyle:UITableViewStyleGrouped];
    
    [self.masterNC pushViewController:ordersListTVC animated:YES];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
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
