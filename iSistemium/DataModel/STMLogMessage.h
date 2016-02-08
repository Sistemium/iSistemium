//
//  STMLogMessage.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMLogMessage : STMComment

- (NSString *)dayAsString;


@end

NS_ASSUME_NONNULL_END

#import "STMLogMessage+CoreDataProperties.h"
