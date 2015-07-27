//
//  STMMessagesNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMTabBarItemControllable.h"

@interface STMMessagesNC : UINavigationController <STMTabBarItemControllable>

- (void)showActionSheetFromTabBarItem;


@end
