//
//  STMRootVC.h
//  TestRootVC
//
//  Created by Maxim Grigoriev on 20/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMRootVC : UITabBarController

+ (STMRootVC *)sharedRootVC;

- (void)showTabWithName:(NSString *)tabName;


@end
