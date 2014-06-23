//
//  STMCampaignsSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignsSVC.h"

@interface STMCampaignsSVC ()

@end

@implementation STMCampaignsSVC


- (STMCampaignDetailsVC *)detailVC {
    
    if (!_detailVC) {
        
        UINavigationController *navController = (UINavigationController *)self.viewControllers[1];
        UIViewController *vc = navController.viewControllers[0];
        if ([vc isKindOfClass:[STMCampaignDetailsVC class]]) {
            _detailVC = (STMCampaignDetailsVC *)vc;
        }
        
    }
    
    return _detailVC;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    if ([self.detailVC conformsToProtocol:@protocol(UISplitViewControllerDelegate)]) {
        self.delegate = (id <UISplitViewControllerDelegate>)self.detailVC;
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
