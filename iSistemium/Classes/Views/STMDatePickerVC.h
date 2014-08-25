//
//  STMDatePickerVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCashingControlsVC.h"

@interface STMDatePickerVC : UIViewController

@property (nonatomic, strong) STMCashingControlsVC *parentVC;
@property (nonatomic, strong) NSDate *selectedDate;

@end
