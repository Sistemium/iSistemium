//
//  STMHandOverPopoverVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMUncashingDetailsTVC.h"

@interface STMHandOverPopoverVC : UIViewController

@property (nonatomic, strong) NSDecimalNumber *uncashingSum;

@property (nonatomic, strong) STMUncashingDetailsTVC *parent;

@end
