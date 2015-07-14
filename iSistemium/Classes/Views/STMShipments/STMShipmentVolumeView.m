//
//  STMShipmentVolumeView.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 14/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentVolumeView.h"

@implementation STMShipmentVolumeView

- (UILabel *)titleLabel {
    return [self labelWithTag:1];
}

- (UILabel *)boxCountLabel {
    return [self labelWithTag:2];
}

- (UILabel *)bottleCountLabel {
    return [self labelWithTag:3];
}

- (UILabel *)labelWithTag:(NSInteger)tag {

    UIView *view = [self viewWithTag:tag];
    return ([view isKindOfClass:[UILabel class]]) ? (UILabel *)view : nil;

}

- (UIButton *)allCountButton {

    UIView *view = [self viewWithTag:4];
    return ([view isKindOfClass:[UIButton class]]) ? (UIButton *)view : nil;

}

- (UIStepper *)boxCountStepper {
    return [self stepperWithTag:5];
}

- (UIStepper *)bottleCountStepper {
    return [self stepperWithTag:6];
}

- (UIStepper *)stepperWithTag:(NSInteger)tag {
    
    UIView *view = [self viewWithTag:tag];
    return ([view isKindOfClass:[UIStepper class]]) ? (UIStepper *)view : nil;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
