//
//  STMProfileNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 04/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMProfileNC.h"
#import "STMRootTBC.h"


@interface STMProfileNC ()

@end


@implementation STMProfileNC

#pragma mark - STMTabBarViewController protocol

- (BOOL)shouldShowActionSheet {
    return NO;
}

- (void)showActionSheetFromTabBarItem {
    
    if ([STMRootTBC sharedRootVC].newAppVersionAvailable) {
        
        //        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"UPDATE", nil), nil];
        //
        //        CGRect rect = [STMFunctions frameOfHighlightedTabBarButtonForTBC:self.tabBarController];
        //
        //        [actionSheet showFromRect:rect inView:self.view animated:YES];
        
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //    if (buttonIndex != -1) {
    //
    //    }
    
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
