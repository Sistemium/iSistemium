//
//  STMTabBarViewController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STMTabBarViewController <NSObject>

- (BOOL)shouldShowOwnActions;
- (void)showActionPopoverFromTabBarItem;

@optional
- (void)selectSiblingAtIndex:(NSUInteger)index;
- (void)selectActionAtIndex:(NSUInteger)index;


@end
