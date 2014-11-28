//
//  STMUncashingHandOverVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/10/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMUncashingSVC.h"

@interface STMUncashingHandOverVC : UIViewController

@property (nonatomic, strong) STMUncashingSVC *splitVC;

- (void)doneButtonPressed;
- (void)dismissInfoPopover;
- (void)confirmButtonPressed;
- (void)deletePhoto;

@end
