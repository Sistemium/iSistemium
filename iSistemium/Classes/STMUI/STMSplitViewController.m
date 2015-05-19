//
//  STMUISplitViewController.m
//  iSistemium
//
//  Created by Alexander Levin on 11/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSplitViewController.h"
#import "STMRootTBC.h"
#import "STMTabBarButtonTVC.h"
#import "STMFunctions.h"


@interface STMSplitViewController () <UISplitViewControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *siblings;
@property (nonatomic, strong) UIPopoverController *actionSheetPopover;

@end


@implementation STMSplitViewController

- (NSArray *)siblings {
    
    if (!_siblings) {
        _siblings = [[STMRootTBC sharedRootVC] siblingsForViewController:self];
    }
    return _siblings;
    
}

- (UIPopoverController *)actionSheetPopover {
    
    if (!_actionSheetPopover) {
        
        STMTabBarButtonTVC *vc = [[STMTabBarButtonTVC alloc] init];
        
        vc.siblings = self.siblings;
        vc.actions = self.actions;
        vc.parentVC = self;
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        popover.delegate = self;
        popover.popoverContentSize = CGSizeMake(vc.view.frame.size.width, vc.view.frame.size.height);
        
        _actionSheetPopover = popover;
        
    }
    return _actionSheetPopover;
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.actionSheetPopover = nil;
}


#pragma mark - STMTabBarViewController protocol

- (BOOL)shouldShowOwnActions {
    return NO;
}

- (void)showActionPopoverFromTabBarItem {
    
    CGRect rect = [STMFunctions frameOfHighlightedTabBarButtonForTBC:self.tabBarController];
    
    [self.actionSheetPopover presentPopoverFromRect:rect
                                             inView:self.tabBarController.view
                           permittedArrowDirections:UIPopoverArrowDirectionAny
                                           animated:YES];
    
}

- (void)selectSiblingAtIndex:(NSUInteger)index {
    
    UIViewController *vc = self.siblings[index];
    
    if (vc != self) {
        [[STMRootTBC sharedRootVC] replaceVC:self withVC:vc];
    }
    
    [self.actionSheetPopover dismissPopoverAnimated:YES];
    
}

- (void)selectActionAtIndex:(NSUInteger)index {
    
    [self.actionSheetPopover dismissPopoverAnimated:YES];
    
}


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
