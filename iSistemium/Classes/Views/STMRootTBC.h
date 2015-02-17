//
//  STMRootVC.h
//  TestRootVC
//
//  Created by Maxim Grigoriev on 20/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMRootTBC : UITabBarController

+ (STMRootTBC *)sharedRootVC;

- (void)showTabWithName:(NSString *)tabName;
- (void)showTabAtIndex:(NSUInteger)index;
- (void)newAppVersionAvailable:(NSNotification *)notification;

@property (nonatomic, strong) NSMutableArray *storyboardTitles;
@property (nonatomic) BOOL newAppVersionAvailable;


@end
