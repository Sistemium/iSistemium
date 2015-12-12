//
//  STMSupplyOrdersSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrdersSVC.h"


@interface STMSupplyOrdersSVC ()

@property (nonatomic, strong) UINavigationController *detailNC;


@end


@implementation STMSupplyOrdersSVC

- (UINavigationController *)detailNC {
    
    if (!_detailNC) {
        if ([self.viewControllers[1] isKindOfClass:[UINavigationController class]]) {
            _detailNC = self.viewControllers[1];
        }
    }
    return _detailNC;
    
}

- (STMSupplyOrderArticleDocsTVC *)detailTVC {
    
    if (!_detailTVC) {

        UIViewController *detailTVC = self.detailNC.viewControllers[0];
        
        if ([detailTVC isKindOfClass:[STMSupplyOrderArticleDocsTVC class]]) {
            _detailTVC = (STMSupplyOrderArticleDocsTVC *)detailTVC;
        }

    }
    return _detailTVC;
    
}

- (void)setSelectedSupplyOrder:(STMSupplyOrder *)selectedSupplyOrder {
    
    _selectedSupplyOrder = selectedSupplyOrder;
    
    self.detailTVC.supplyOrder = _selectedSupplyOrder;
    
}

- (NSString *)supplyOrderWorkflow {
    
    if (!_supplyOrderWorkflow) {
        _supplyOrderWorkflow = [STMWorkflowController workflowForEntityName:NSStringFromClass([STMSupplyOrder class])];
    }
    return _supplyOrderWorkflow;
    
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
