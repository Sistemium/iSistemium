//
//  STMCatalogSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogSVC.h"

@interface STMCatalogSVC ()

@end

@implementation STMCatalogSVC

- (STMCatalogDetailTVC *)detailTVC {
    
    if (!_detailTVC) {
        
        UINavigationController *navController = (UINavigationController *)self.viewControllers[1];
        
        UIViewController *detailTVC = navController.viewControllers[0];
        
        if ([detailTVC isKindOfClass:[STMCatalogDetailTVC class]]) {
            _detailTVC = (STMCatalogDetailTVC *)detailTVC;
        }
        
    }
    
    return _detailTVC;
    
}

- (STMCatalogMasterTVC *)masterTVC {
    
    if (!_masterTVC) {
        
        UINavigationController *navController = (UINavigationController *)self.viewControllers[0];
        
        UIViewController *masterTVC = navController.viewControllers[0];
        
        if ([masterTVC isKindOfClass:[STMCatalogMasterTVC class]]) {
            
            _masterTVC = (STMCatalogMasterTVC *)masterTVC;
            
        }
        
    }
    
    return _masterTVC;
    
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
