//
//  STMMessagesNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMMessagesNC.h"
#import "STMMessageVC.h"


@interface STMMessagesNC () <UIActionSheetDelegate>

@property (nonatomic, strong) STMMessageVC *messageVC;

@end


@implementation STMMessagesNC


#pragma mark - STMTabBarItemControllable protocol

- (BOOL)shouldShowOwnActions {
    return YES;
}

- (void)selectActionAtIndex:(NSUInteger)index {
    
    [super selectActionAtIndex:index];
    
    NSString *action = self.actions[index];
    
    if ([action isEqualToString:NSLocalizedString(@"MARK ALL AS READ", nil)]) {

        NSLog(@"MARK ALL AS READ");
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    self.actions = @[NSLocalizedString(@"MARK ALL AS READ", nil)];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
