//
//  STMVolumeTVCell+category.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMVolumeTVCell+category.h"

#import "STMPositionVolumesVC.h"


@implementation STMVolumeTVCell (category)

- (void)volumeChangedForParentVC {
    
    if ([self.parentVC isKindOfClass:[STMPositionVolumesVC class]]) {
        [(STMPositionVolumesVC *)self.parentVC volumeChangedInCell:self];
    }
    
}


@end
