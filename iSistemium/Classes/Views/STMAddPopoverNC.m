//
//  STMAddPopoverNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddPopoverNC.h"
#import "STMSelectPartnerTVC.h"

@interface STMAddPopoverNC ()

@end

@implementation STMAddPopoverNC

- (void)dismissSelf {

    [self popViewControllerAnimated:NO];
    [self.parentVC dissmissPopover];
    
}


#pragma mark - view lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    if (self.partner) {
        
        if ([self.visibleViewController isKindOfClass:[STMSelectPartnerTVC class]]) {
            
            [(STMSelectPartnerTVC *)self.visibleViewController setPartner:self.partner];
            
        }
        
    }
    
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
