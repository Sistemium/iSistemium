//
//  STMBasketNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMBasketNC.h"

#import "STMSelectOutletTVC.h"
#import "STMBasketPositionsTVC.h"

#define FRAME_WIDTH 640
#define FRAME_HEIGHT 640


@interface STMBasketNC ()


@end


@implementation STMBasketNC

- (instancetype)initWithParent:(STMCatalogDetailTVC *)parentVC {

    STMSelectOutletTVC *rootViewController = [[STMSelectOutletTVC alloc] initWithStyle:UITableViewStyleGrouped];
    
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        
        self.parentVC = parentVC;
        
        self.toolbarHidden = NO;
        
        self.view.frame = CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT);
        
        if (self.parentVC.selectedOutlet) {
            
            STMBasketPositionsTVC *basketPositionsTVC = [[STMBasketPositionsTVC alloc] initWithOutlet:self.parentVC.selectedOutlet];            
            [self pushViewController:basketPositionsTVC animated:NO];
            
        }

        
    }
    return self;

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
