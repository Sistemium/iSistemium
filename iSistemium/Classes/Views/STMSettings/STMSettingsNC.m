//
//  STMSettingsNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSettingsNC.h"
#import "STMRootTBC.h"
#import "STMFunctions.h"


@interface STMSettingsNC () <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *siblings;


@end


@implementation STMSettingsNC

- (NSArray *)siblings {
    
    if (!_siblings) {
        _siblings = [[STMRootTBC sharedRootVC] siblingsForViewController:self];
    }
    return _siblings;
    
}

#pragma mark - STMTabBarViewController protocol

- (BOOL)shouldShowOwnActionSheet {
    return NO;
}

- (void)showActionSheetFromTabBarItem {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    if (self.siblings.count > 1) {
        
        for (UIViewController *vc in self.siblings) {
            
            [actionSheet addButtonWithTitle:vc.title];
            
        }
    
        CGRect rect = [STMFunctions frameOfHighlightedTabBarButtonForTBC:self.tabBarController];
        
        [actionSheet showFromRect:rect inView:self.view animated:YES];

    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    UIViewController *vc = self.siblings[buttonIndex];
    
    if (vc != self) {
        [[STMRootTBC sharedRootVC] replaceVC:self withVC:vc];
    }
    
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
