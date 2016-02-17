//
//  STMSupplyOrdersSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrdersSVC.h"

#import "STMSupplyOrdersMasterNC.h"
#import "STMSupplyOrdersDetailNC.h"


@interface STMSupplyOrdersSVC ()

@property (nonatomic, strong) STMSupplyOrdersMasterNC *masterNC;
@property (nonatomic, strong) STMSupplyOrdersDetailNC *detailNC;


@end


@implementation STMSupplyOrdersSVC

- (STMSupplyOrdersMasterNC *)masterNC {
    
    if (!_masterNC) {
        if ([self.viewControllers[0] isKindOfClass:[STMSupplyOrdersMasterNC class]]) {
            _masterNC = self.viewControllers[0];
        }
    }
    return _masterNC;
    
}

- (STMSupplyOrdersTVC *)masterTVC {
    
    if (!_masterTVC) {
        
        UIViewController *masterTVC = self.masterNC.viewControllers[0];
        
        if ([masterTVC isKindOfClass:[STMSupplyOrdersTVC class]]) {
            _masterTVC = (STMSupplyOrdersTVC *)masterTVC;
        }

    }
    return _masterTVC;
    
}

- (STMSupplyOrdersDetailNC *)detailNC {
    
    if (!_detailNC) {
        if ([self.viewControllers[1] isKindOfClass:[STMSupplyOrdersDetailNC class]]) {
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

- (BOOL)isMasterNCForViewController:(UIViewController *)vc {
    return [self.masterNC.viewControllers containsObject:vc];
}

- (BOOL)isDetailNCForViewController:(UIViewController *)vc {
    return [self.detailNC.viewControllers containsObject:vc];
}

- (void)masterBackButtonPressed {
    [self.detailNC popToRootViewControllerAnimated:YES];
}

- (void)orderProcessingChanged {
    [self.detailTVC orderProcessingChanged];
}

- (void)setSelectedSupplyOrder:(STMSupplyOrder *)selectedSupplyOrder {
    
    _selectedSupplyOrder = selectedSupplyOrder;
    
    self.detailTVC.supplyOrder = _selectedSupplyOrder;
    
}

- (void)setSelectedSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)selectedSupplyOrderArticleDoc {
    
    _selectedSupplyOrderArticleDoc = selectedSupplyOrderArticleDoc;
    
    [self.masterTVC segueToArticleDocs];
    [self.detailTVC highlightSupplyOrderArticleDoc:_selectedSupplyOrderArticleDoc];
    
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
