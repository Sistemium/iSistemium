//
//  STMAddEtceteraVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMDatePickerParent.h"
#import "STMUncashingDetailsTVC.h"

@interface STMAddEtceteraVC : UIViewController <STMDatePickerParent>

@property (nonatomic, strong) STMUncashingDetailsTVC *parentVC;
@property (nonatomic, strong) NSDate *selectedDate;


@end
