//
//  STMShipmentsSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentsSVC.h"

#import "STMShipmentRouteTVC.h"


@interface STMShipmentsSVC ()


@end


@implementation STMShipmentsSVC

- (STMShipmentsMasterNC *)masterNC {
    
    if (!_masterNC) {
        if ([self.viewControllers[0] isKindOfClass:[STMShipmentsMasterNC class]]) {
            _masterNC = self.viewControllers[0];
        }
    }
    return _masterNC;
    
}

- (STMShipmentsDetailNC *)detailNC {
    
    if (!_detailNC) {
        if ([self.viewControllers[1] isKindOfClass:[STMShipmentsDetailNC class]]) {
            _detailNC = self.viewControllers[1];
        }
    }
    return _detailNC;
    
}

- (BOOL)isMasterNCForViewController:(UIViewController *)vc {
    return [self.masterNC.viewControllers containsObject:vc];
}

- (BOOL)isDetailNCForViewController:(UIViewController *)vc {
    return [self.detailNC.viewControllers containsObject:vc];
}

- (void)setSelectedRoute:(STMShipmentRoute *)selectedRoute {
    
    if (![_selectedRoute isEqual:selectedRoute]) {
        
        _selectedRoute = selectedRoute;
        
        if ([self.detailNC.topViewController isKindOfClass:[STMShipmentRouteTVC class]]) {
            
            STMShipmentRouteTVC *routeTVC = (STMShipmentRouteTVC *)self.detailNC.topViewController;
            routeTVC.route = _selectedRoute;
            
        }
        
    }
    
}


#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
