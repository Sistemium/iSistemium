//
//  STMAuthVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMAuthNC.h"
#import "STMUI.h"
#import "STMFunctions.h"

@interface STMAuthVC : UIViewController

@property (nonatomic, strong) STMUISpinnerView *spinnerView;
@property (nonatomic, weak) UIButton *button;

- (void)buttonPressed;
- (void)customInit;
- (void)dismissSpinner;

@end
