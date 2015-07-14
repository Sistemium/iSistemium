//
//  STMShipmentVolumeView.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 14/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentVolumeView.h"

@interface STMShipmentVolumeView()

@property (nonatomic) NSInteger bottleCountPreviousValue;


@end


@implementation STMShipmentVolumeView

#pragma mark - view controls & labels

- (UILabel *)titleLabel {

    if (!_titleLabel) {
        _titleLabel = [self labelWithTag:1];
    }
    return _titleLabel;
    
}

- (UILabel *)boxCountLabel {
    
    if (!_boxCountLabel) {
        _boxCountLabel = [self labelWithTag:2];
    }
    return _boxCountLabel;
    
}

- (UILabel *)bottleCountLabel {
    
    if (!_bottleCountLabel) {
        _bottleCountLabel = [self labelWithTag:3];
    }
    return _bottleCountLabel;
    
}

- (UILabel *)labelWithTag:(NSInteger)tag {

    UIView *view = [self viewWithTag:tag];
    return ([view isKindOfClass:[UILabel class]]) ? (UILabel *)view : nil;

}

- (UIButton *)allCountButton {
    
    if (!_allCountButton) {
        
        UIView *view = [self viewWithTag:4];
        _allCountButton = ([view isKindOfClass:[UIButton class]]) ? (UIButton *)view : nil;
        
    }
    return _allCountButton;

}

- (UIStepper *)boxCountStepper {
    
    if (!_boxCountStepper) {
        
        _boxCountStepper = [self stepperWithTag:5];
        [_boxCountStepper addTarget:self
                             action:@selector(boxCountChange)
                   forControlEvents:UIControlEventValueChanged];
        
    }
    return _boxCountStepper;
    
}

- (UIStepper *)bottleCountStepper {
    
    if (!_bottleCountStepper) {
        
        _bottleCountStepper = [self stepperWithTag:6];
        [_bottleCountStepper addTarget:self
                                action:@selector(bottleCountChange)
                      forControlEvents:UIControlEventValueChanged];

    }
    return _bottleCountStepper;
    
}

- (UIStepper *)stepperWithTag:(NSInteger)tag {
    
    UIView *view = [self viewWithTag:tag];
    return ([view isKindOfClass:[UIStepper class]]) ? (UIStepper *)view : nil;
    
}

- (NSInteger)bottleCountPreviousValue {
    
    if (!_bottleCountPreviousValue) {
        _bottleCountPreviousValue = 0;
    }
    return _bottleCountPreviousValue;
    
}

#pragma mark - actions

- (void)boxCountChange {
    
    NSString *boxCountString = [NSString stringWithFormat:@"%d", (int)self.boxCountStepper.value];
    self.boxCountLabel.text = boxCountString;
    
    [self bottleCountStepperWraps];
    
}

- (void)bottleCountChange {
    
    if ((self.volumeLimit && (self.volume > self.volumeLimit)) || self.volume < 0) {
        
        self.bottleCountStepper.value = self.bottleCountPreviousValue;
        
    } else {
    
        if ([self isBottleCountWrapUp]) {
            
            self.boxCountStepper.value += 1;
            [self boxCountChange];
            
        } else if ([self isBottleCountWrapDown]) {
            
            self.boxCountStepper.value -= 1;
            [self boxCountChange];
            
        }
        
        NSString *bottleCountString = [NSString stringWithFormat:@"%d", (int)self.bottleCountStepper.value];
        self.bottleCountLabel.text = bottleCountString;
        
        self.bottleCountPreviousValue = self.bottleCountStepper.value;

        [self bottleCountStepperWraps];
        
    }
    
}

- (void)bottleCountStepperWraps {
    
    if (self.volumeLimit) {
        
        if (self.volume + 1 > self.volumeLimit) {
            
            self.bottleCountStepper.maximumValue = self.bottleCountStepper.value;
            self.bottleCountStepper.wraps = NO;
            
        } else {
            
            self.bottleCountStepper.maximumValue = self.packageRel - 1;
            self.bottleCountStepper.wraps = (self.volume - 1 >= 0);
            
        }
        
    } else {
        self.bottleCountStepper.wraps = (self.volume - 1 >= 0);
    }

}

- (BOOL)isBottleCountWrapUp {
    return ((self.bottleCountPreviousValue == self.packageRel - 1) && (self.bottleCountStepper.value == 0));
}

- (BOOL)isBottleCountWrapDown {
    return ((self.bottleCountPreviousValue == 0) && (self.bottleCountStepper.value == self.packageRel - 1));
}


#pragma mark - variables

- (NSInteger)volume {
    
    NSInteger boxValue = floor(self.boxCountStepper.value);
    NSInteger bottleValue = floor(self.bottleCountStepper.value);
    
    NSInteger volume = boxValue * self.packageRel + bottleValue;
    
    return volume;
    
}

- (void)setPackageRel:(NSInteger)packageRel {
    
    _packageRel = packageRel;
    self.bottleCountStepper.maximumValue = packageRel - 1;
    
}

- (void)setVolumeLimit:(NSInteger)volumeLimit {
    
    _volumeLimit = volumeLimit;
    
    if (self.packageRel && self.packageRel != 0) {
        
        NSInteger boxCountMax = floor(volumeLimit/self.packageRel);
        self.boxCountStepper.maximumValue = boxCountMax;
        
    }
    
}


#pragma mark - methods

- (void)nullifyView {
    
    self.boxCountLabel.text = [[NSNumber numberWithInteger:0] stringValue];
    self.bottleCountLabel.text = [[NSNumber numberWithInteger:0] stringValue];
    
    [self boxCountStepper];
    [self bottleCountStepper];
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
