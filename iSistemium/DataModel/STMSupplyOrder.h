//
//  STMSupplyOrder.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMComment.h"

@class STMPartner, STMSupplyOrderArticleDoc;

NS_ASSUME_NONNULL_BEGIN

@interface STMSupplyOrder : STMComment

- (NSString *)title;


@end

NS_ASSUME_NONNULL_END

#import "STMSupplyOrder+CoreDataProperties.h"
