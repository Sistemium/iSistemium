//
//  STMActionPopoverNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMActionPopoverNC.h"
#import "STMRootTBC.h"
#import "STMTabBarButtonTVC.h"
#import "STMFunctions.h"


@interface STMActionPopoverNC () <UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *siblings;
@property (nonatomic, strong) UIPopoverController *actionSheetPopover;


@end

@implementation STMActionPopoverNC

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
