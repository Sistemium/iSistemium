//
//  STMShipmentVolumeView.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 14/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMShipmentVolumeView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *boxCountLabel;
@property (nonatomic, strong) UILabel *bottleCountLabel;
@property (nonatomic, strong) UIButton *allCountButton;
@property (nonatomic, strong) UIStepper *boxCountStepper;
@property (nonatomic, strong) UIStepper *bottleCountStepper;

@property (nonatomic) NSInteger packageRel;
@property (nonatomic) NSInteger volume;
@property (nonatomic) NSInteger volumeLimit;


- (void)nullifyView;


@end
