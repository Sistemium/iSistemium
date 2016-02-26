//
//  STMShipmentsDetailNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentsDetailNC.h"

@interface STMShipmentsDetailNC ()

@end

@implementation STMShipmentsDetailNC


#pragma mark - view lifecycle

- (void)customInit {

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }

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
