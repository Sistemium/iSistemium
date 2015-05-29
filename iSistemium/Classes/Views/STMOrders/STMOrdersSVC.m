//
//  STMOrdersSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersSVC.h"
#import "STMOrdersListTVC.h"
#import "STMOrderInfoTVC.h"


@interface STMOrdersSVC ()

@end

@implementation STMOrdersSVC

- (UINavigationController *)masterNC {
    
    if (!_masterNC) {
        if ([self.viewControllers[0] isKindOfClass:[UINavigationController class]]) {
            _masterNC = self.viewControllers[0];
        }
    }
    return _masterNC;
    
}

- (STMOrdersMasterPVC *)masterPVC {
    
    if (!_masterPVC) {
        
        UIViewController *masterPVC = self.masterNC.viewControllers[0];
        
        if ([masterPVC isKindOfClass:[STMOrdersMasterPVC class]]) {
            _masterPVC = (STMOrdersMasterPVC *)masterPVC;
        }
        
    }
    return _masterPVC;
    
}

- (UINavigationController *)detailNC {
    
    if (!_detailNC) {
        if ([self.viewControllers[1] isKindOfClass:[UINavigationController class]]) {
            _detailNC = self.viewControllers[1];
        }
    }
    return _detailNC;
    
}

- (STMOrdersDetailTVC *)detailTVC {
    
    if (!_detailTVC) {
    
        UIViewController *detailTVC = self.detailNC.viewControllers[0];

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

- (void)setSelectedOrder:(STMSaleOrder *)selectedOrder {
    
    if (_selectedOrder != selectedOrder) {
        
        _selectedOrder = selectedOrder;
        
        if ([self.detailNC.topViewController isKindOfClass:[STMOrderInfoTVC class]]) {
            
            [(STMOrderInfoTVC *)self.detailNC.topViewController setSaleOrder:selectedOrder];
            
        }
        
    }
    
}

- (void)stateUpdate {
    
    [self.masterPVC updateResetFilterButtonState];
    [self.detailTVC refreshTable];
    
}

- (void)orderWillSelected {
    
    STMOrdersListTVC *ordersListTVC = [[STMOrdersListTVC alloc] initWithStyle:UITableViewStyleGrouped];
    
    [self.masterNC pushViewController:ordersListTVC animated:YES];
    
}

- (void)backButtonPressed {
    
    UINavigationController *nc = self.detailTVC.navigationController;
    [nc popViewControllerAnimated:YES];
    
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
