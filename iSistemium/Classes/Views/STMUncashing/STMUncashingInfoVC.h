//
//  STMUncashingInfoVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMUncashing.h"
#import "STMUncashingPlace.h"
#import "STMUncashingHandOverVC.h"

@interface STMUncashingInfoVC : UIViewController

@property (nonatomic, weak) STMUncashingHandOverVC *parentVC;

@property (nonatomic, strong) STMUncashing *uncashing;

@property (nonatomic, strong) NSDecimalNumber *sum;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) STMUncashingPlace *place;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

@end
