//
//  STMUncashingInfoVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMUncashing.h"
#import "STMUncashingHandOverVC.h"

@interface STMUncashingInfoVC : UIViewController

@property (nonatomic, strong) STMUncashingHandOverVC *parentVC;

@property (nonatomic, strong) STMUncashing *uncashing;

@property (nonatomic, strong) NSDecimalNumber *sum;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) UIImage *image;

@end
