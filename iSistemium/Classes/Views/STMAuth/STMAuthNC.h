//
//  STMAuthNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMAuthController.h"
#import "STMRootTBC.h"
#import "STMTabBarItemControllable.h"

@interface STMAuthNC : UINavigationController <STMTabBarItemControllable>

+ (STMAuthNC *)sharedAuthNC;

@end
