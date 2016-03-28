//
//  STMPickingOrderPosition.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

@class STMArticle, STMPickingOrder, STMPickingOrderPositionPicked, STMQualityClass;

NS_ASSUME_NONNULL_BEGIN

@interface STMPickingOrderPosition : STMDatum

- (NSUInteger)nonPickedVolume;


@end

NS_ASSUME_NONNULL_END

#import "STMPickingOrderPosition+CoreDataProperties.h"
