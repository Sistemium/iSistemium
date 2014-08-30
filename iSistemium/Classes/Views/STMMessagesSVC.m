//
//  STMMessagesSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMMessagesSVC.h"

@interface STMMessagesSVC ()

@end

@implementation STMMessagesSVC

- (STMMessagesDetailTVC *)detailVC {
    
    if (!_detailVC) {
        
        UINavigationController *navController = (UINavigationController *)self.viewControllers[1];
        
        UIViewController *detailVC = navController.viewControllers[0];
        
        if ([detailVC isKindOfClass:[STMMessagesDetailTVC class]]) {
            _detailVC = (STMMessagesDetailTVC *)detailVC;
        }
        
    }
    
    return _detailVC;
    
}

- (STMMessagesMasterTVC *)masterVC {
    
    if (!_masterVC) {
        
        UINavigationController *navController = (UINavigationController *)self.viewControllers[0];
        
        UIViewController *masterVC = navController.viewControllers[0];
        
        if ([masterVC isKindOfClass:[STMMessagesMasterTVC class]]) {
            
            _masterVC = (STMMessagesMasterTVC *)masterVC;
            
        }
        
    }
    
    return _masterVC;
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
