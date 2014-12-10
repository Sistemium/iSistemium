//
//  STMAddDebtVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMDatePickerParent.h"
#import "STMDebtsDetailsPVC.h"

@interface STMAddDebtVC : UIViewController <STMDatePickerParent>

@property (nonatomic, strong) STMDebtsDetailsPVC *parentVC;
@property (nonatomic, strong) NSDate *selectedDate;

@end
