//
//  STMShipmentPosition.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

@class STMArticle, STMShipment;

NS_ASSUME_NONNULL_BEGIN

@interface STMShipmentPosition : STMDatum

- (BOOL)wasProcessed;
- (NSString *)volumeText;


@end

NS_ASSUME_NONNULL_END

#import "STMShipmentPosition+CoreDataProperties.h"
