//
//  STMPhotoReportsSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportsSVC.h"


@interface STMPhotoReportsSVC ()


@end


@implementation STMPhotoReportsSVC

- (STMCampaignGroupTVC *)masterVC {
    
    if (!_masterVC) {
        
        UINavigationController *navController = (UINavigationController *)self.viewControllers[0];
        
        UIViewController *masterVC = navController.viewControllers[0];
        
        if ([masterVC isKindOfClass:[STMCampaignGroupTVC class]]) {
            
            _masterVC = (STMCampaignGroupTVC *)masterVC;
            
        }
        
    }
    
    return _masterVC;
    
}

- (STMPhotoReportsCVC *)detailVC {
    
    if (!_detailVC) {
        
        UINavigationController *navController = (UINavigationController *)self.viewControllers[1];
        
        UIViewController *detailVC = navController.viewControllers[0];
        
        if ([detailVC isKindOfClass:[STMPhotoReportsCVC class]]) {
            _detailVC = (STMPhotoReportsCVC *)detailVC;
        }
        
    }
    
    return _detailVC;
    
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
