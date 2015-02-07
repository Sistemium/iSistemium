//
//  STMAuthVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMAuthController.h"
#import "STMFunctions.h"

@interface STMAuthVC : UIViewController

@property (nonatomic, strong) UIView *spinnerView;

- (void)customInit;

- (void)authControllerStateChanged;

@end
