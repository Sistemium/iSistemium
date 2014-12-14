//
//  STMEntityController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMEntity.h"

@interface STMEntityController : NSObject

+ (NSDictionary *)stcEntities;
+ (STMEntity *)entityWithName:(NSString *)name;


@end
