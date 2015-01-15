//
//  STMEntityController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMController.h"
#import "STMEntity.h"

@interface STMEntityController : STMController

+ (NSDictionary *)stcEntities;
+ (NSSet *)entityNamesWithLifeTime;
+ (STMEntity *)entityWithName:(NSString *)name;


@end
