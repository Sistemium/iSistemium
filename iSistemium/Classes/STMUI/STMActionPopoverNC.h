//
//  STMActionPopoverNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMTabBarViewController.h"


@interface STMActionPopoverNC : UINavigationController <STMTabBarViewController>

@property (nonatomic, strong) NSArray *actions;

@end
