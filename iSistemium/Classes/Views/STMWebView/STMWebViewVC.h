//
//  STMWebViewVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMTabBarViewController.h"

@interface STMWebViewVC : UIViewController <STMTabBarViewController>

- (void)showActionSheetFromTabBarItem;

@end
