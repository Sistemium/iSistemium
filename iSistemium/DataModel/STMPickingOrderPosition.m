//
//  STMPickingOrderPosition.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrderPosition.h"
#import "STMArticle.h"
#import "STMPickingOrder.h"
#import "STMPickingOrderPositionPicked.h"
#import "STMQualityClass.h"

@implementation STMPickingOrderPosition

- (NSUInteger)nonPickedVolume {
    
    NSInteger volume = self.volume.integerValue;
    NSInteger pickedVolume = [[self.pickingOrderPositionsPicked valueForKeyPath:@"@sum.volume"] integerValue];

    NSInteger result = volume - pickedVolume;
    
    return (result > 0) ? result : 0;
    
}


@end
