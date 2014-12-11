//
//  STMUISplitViewController.m
//  iSistemium
//
//  Created by Alexander Levin on 11/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUISplitViewController.h"

@interface STMUISplitViewController ()

@end

@implementation STMUISplitViewController

- (void) setPreferredDisplayMode: (UISplitViewControllerDisplayMode) mode {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [super setPreferredDisplayMode: mode];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

@end
