//
//  STMVolumeTVCell.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMVolumeTVCell.h"

#import "STMPositionVolumesVC.h"


@implementation STMVolumeTVCell

- (void)volumeChangedForParentVC {
    
    if ([self.parentVC isKindOfClass:[STMPositionVolumesVC class]]) {
        [(STMPositionVolumesVC *)self.parentVC volumeChangedInCell:self];
    }
    
}


@end
