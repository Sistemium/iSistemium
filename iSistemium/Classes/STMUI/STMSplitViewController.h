//
//  STMUISplitViewController.h
//  iSistemium
//
//  Created by Alexander Levin on 11/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMTabBarViewController.h"

@interface STMSplitViewController : UISplitViewController <STMTabBarViewController>

@property (nonatomic, strong) NSArray *actions;

@end
