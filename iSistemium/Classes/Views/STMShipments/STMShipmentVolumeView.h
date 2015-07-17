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
@property (nonatomic, strong) UILabel *boxUnitLabel;
@property (nonatomic, strong) UIStepper *boxCountStepper;

@property (nonatomic, strong) UILabel *bottleCountLabel;
@property (nonatomic, strong) UILabel *bottleUnitLabel;
@property (nonatomic, strong) UIStepper *bottleCountStepper;

@property (nonatomic, strong) UIButton *allCountButton;

@property (nonatomic) NSInteger packageRel;
@property (nonatomic) NSInteger volume;
@property (nonatomic) NSInteger volumeLimit;
@property (nonatomic) NSInteger shipmentVolumeLimit;

@property (nonatomic) NSInteger boxCount;
@property (nonatomic) NSInteger bottleCount;

- (void)nullifyView;


@end
