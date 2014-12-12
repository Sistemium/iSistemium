//
//  STMUISplitViewController.m
//  iSistemium
//
//  Created by Alexander Levin on 11/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUISplitViewController.h"

@interface STMUISplitViewController () <UISplitViewControllerDelegate>

@end

@implementation STMUISplitViewController

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    
    return NO;
    
}

//- (void) setPreferredDisplayMode: (UISplitViewControllerDisplayMode) mode {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//        [super setPreferredDisplayMode: mode];
//    }
//}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (systemVersion >= 8.0) {
        
        self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        
    } else if (systemVersion >= 5.0 && systemVersion < 8.0) {
        
        self.delegate = self;
        
    }
    
}

@end
