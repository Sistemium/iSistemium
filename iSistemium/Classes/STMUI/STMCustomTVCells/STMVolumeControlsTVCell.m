//
//  STMVolumeControlsTVCell.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVolumeControlsTVCell.h"

@interface STMVolumeControlsTVCell()

@property (nonatomic) NSInteger bottleCountPreviousValue;
@property (nonatomic) BOOL initialVolumeSetWasDone;


@end


@implementation STMVolumeControlsTVCell

- (IBAction)allCountButtonPressed:(id)sender {
    
    if (self.shipmentVolumeLimit) {
        
        if (self.packageRel && self.packageRel != 0) {
            
            NSInteger boxCount = floor(self.shipmentVolumeLimit / self.packageRel);
            self.boxCountStepper.value = boxCount;
            
            NSInteger bottleCount = self.shipmentVolumeLimit % self.packageRel;
            self.bottleCountStepper.value = bottleCount;
            
        }

        self.volumeCell.volume = self.shipmentVolumeLimit;
        self.volume = self.shipmentVolumeLimit;

    }

}

- (IBAction)boxCountChanged:(id)sender {
    [self countChanged];
}

- (IBAction)bottleCountChanged:(id)sender {
    
    if (self.bottleCountStepper.value == -1 && self.bottleCountStepper.minimumValue == -1) {
        
        self.bottleCountStepper.maximumValue = self.packageRel - 1;
        self.bottleCountStepper.minimumValue = 0;
        self.bottleCountStepper.value = self.bottleCountStepper.maximumValue;
        
        self.boxCountStepper.value -= 1;
        [self boxCountChanged:nil];
        
    }
    
    if ((self.volumeLimit && (self.volume > self.volumeLimit)) || self.volume < 0) {
        
        self.bottleCountStepper.value = self.bottleCountPreviousValue;
        
    } else {
        
        if ([self isBottleCountWrapUp]) {
            
            self.boxCountStepper.value += 1;
            [self boxCountChanged:nil];
            
        } else if ([self isBottleCountWrapDown]) {
            
            self.boxCountStepper.value -= 1;
            [self boxCountChanged:nil];
            
        }
        
        self.bottleCountPreviousValue = self.bottleCountStepper.value;
        
    }
    
    [self countChanged];

}

- (void)bottleCountStepperWraps {
    [self bottleCountStepperWrapsForVolume:self.volume];
}

- (void)bottleCountStepperWrapsForVolume:(NSInteger)volume {
    
    if (self.volumeLimit) {
        
        if (volume + 1 > self.volumeLimit) {
            
            self.bottleCountStepper.maximumValue = self.bottleCountStepper.value;
            self.bottleCountStepper.minimumValue = (self.bottleCountStepper.value == 0) ? -1 : 0;
            self.bottleCountStepper.wraps = NO;
            
        } else {
            
            self.bottleCountStepper.maximumValue = self.packageRel - 1;
            self.bottleCountStepper.minimumValue = 0;
            self.bottleCountStepper.wraps = (volume - 1 >= 0);
            
        }
        
    } else {
        self.bottleCountStepper.wraps = (volume - 1 >= 0);
    }
    
}

- (BOOL)isBottleCountWrapUp {
    return ((self.bottleCountPreviousValue == self.packageRel - 1) && (self.bottleCountStepper.value == 0));
}

- (BOOL)isBottleCountWrapDown {
    return ((self.bottleCountPreviousValue == 0) && (self.bottleCountStepper.value == self.packageRel - 1));
}

- (void)countChanged {
    
    [self bottleCountStepperWraps];
    
    self.volumeCell.volume = self.packageRel * self.boxCountStepper.value + self.bottleCountStepper.value;
    self.allCountButton.enabled = (self.volume < self.shipmentVolumeLimit);

}

- (NSInteger)bottleCountPreviousValue {
    
    if (!_bottleCountPreviousValue) {
        _bottleCountPreviousValue = 0;
    }
    return _bottleCountPreviousValue;
    
}

- (NSInteger)volume {
    
    NSInteger boxValue = floor(self.boxCountStepper.value);
    NSInteger bottleValue = floor(self.bottleCountStepper.value);
    
    NSInteger volume = boxValue * self.packageRel + bottleValue;
    
    return volume;
    
}

- (void)setVolume:(NSInteger)volume {
    
    if (self.packageRel && self.packageRel != 0) {
        
        (self.initialVolumeSetWasDone) ? [self bottleCountStepperWrapsForVolume:volume] : [self bottleCountStepperWraps];
        
        NSInteger boxCount = floor(volume / self.packageRel);
        NSInteger bottleCount = volume % self.packageRel;
        
        if (self.boxCountStepper && self.bottleCountStepper) {
            
            self.boxCountStepper.value = boxCount;
            self.bottleCountStepper.value = bottleCount;
            
            [self bottleCountStepperWraps];
            
        }
        
        self.initialVolumeSetWasDone = YES;
        
    }
    
    self.allCountButton.enabled = (self.volume < self.shipmentVolumeLimit);
    
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


- (void)awakeFromNib {
    
    [self.allCountButton setTitle:NSLocalizedString(@"ALL VOLUME BUTTON", nil) forState:UIControlStateNormal];
    [self.allCountButton setTitle:@"" forState:UIControlStateDisabled];
    
    [super awakeFromNib];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
