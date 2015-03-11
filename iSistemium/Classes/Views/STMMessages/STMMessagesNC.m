//
//  STMMessagesNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMMessagesNC.h"
#import "STMFunctions.h"

@interface STMMessagesNC () <UIActionSheetDelegate>

@end

@implementation STMMessagesNC


#pragma mark - STMTabBarViewController

- (void)showActionSheetFromTabBarItem {
    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"TITLE" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"DO SMTHNG", nil];
//    
//    CGRect rect = [STMFunctions frameOfHighlightedTabBarButtonForTBC:self.tabBarController];
//    
//    [actionSheet showFromRect:rect inView:self.view animated:YES];
    
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
