//
//  STMOrderEditablesVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrderEditablesVC.h"
#import "STMSaleOrderController.h"

@interface STMOrderEditablesVC ()

@end

@implementation STMOrderEditablesVC

- (void)setupHeader {
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 250, 44)];
    fromLabel.text = [STMSaleOrderController labelForProcessing:self.fromProcessing];
    
    [self.view addSubview:fromLabel];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self setupHeader];
    
    self.view.frame = CGRectMake(0, 0, 300, 150);

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {

    [self.view setNeedsDisplay];
    
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
