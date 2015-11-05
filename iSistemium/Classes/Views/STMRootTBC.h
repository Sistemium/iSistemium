//
//  STMRootVC.h
//  TestRootVC
//
//  Created by Maxim Grigoriev on 20/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMRootTBC : UITabBarController

@property (nonatomic, strong) NSMutableArray *storyboardTitles;
@property (nonatomic) BOOL newAppVersionAvailable;

+ (STMRootTBC *)sharedRootVC;

- (UIViewController *)topmostVC;

- (NSArray *)siblingsForViewController:(UIViewController *)vc;
- (void)replaceVC:(UIViewController *)currentVC withVC:(UIViewController *)vc;

- (void)showTabWithName:(NSString *)tabName;
- (void)showTabAtIndex:(NSUInteger)index;
- (void)newAppVersionAvailable:(NSNotification *)notification;


@end
