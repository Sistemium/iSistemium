//
//  STMVolumeTVCell.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVolumeTVCell.h"

@implementation STMVolumeTVCell


- (void)setVolume:(NSInteger)volume {
    
    if (self.packageRel && self.packageRel != 0) {
        
        NSInteger boxCount = floor(volume / self.packageRel);
        NSInteger bottleCount = volume % self.packageRel;
        
        [self setCount:boxCount forLabel:self.boxCountLabel];
        [self setCount:bottleCount forLabel:self.bottleCountLabel];
        
    }
    
}

- (void)setCount:(NSInteger)count forLabel:(STMLabel *)label {
    
    NSString *countString = [NSString stringWithFormat:@"%ld", (long)count];
    label.text = countString;
    
    UIColor *textColor = (count == 0) ? [UIColor lightGrayColor] : [UIColor blackColor];
    
    label.textColor = textColor;

    STMLabel *unitLabel = ([label isEqual:self.boxCountLabel]) ? self.boxUnitLabel : self.bottleUnitLabel;
    unitLabel.textColor = textColor;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
