//
//  STMShipmentPosition.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMComment.h"

@class STMArticle, STMShipment;

NS_ASSUME_NONNULL_BEGIN

@interface STMShipmentPosition : STMComment

- (BOOL)wasProcessed;
- (NSString *)volumeText;


@end

NS_ASSUME_NONNULL_END

#import "STMShipmentPosition+CoreDataProperties.h"
