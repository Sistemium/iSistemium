//
//  STMDebt.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMComment.h"

@class STMCashing, STMOutlet;

NS_ASSUME_NONNULL_BEGIN

@interface STMDebt : STMComment

- (NSDecimalNumber *)cashingCalculatedSum;


@end

NS_ASSUME_NONNULL_END

#import "STMDebt+CoreDataProperties.h"
