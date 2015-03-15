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

+ (void)checkEntitiesForDuplicates;

+ (NSSet *)entityNamesWithLifeTime;
+ (NSArray *)entitiesWithLifeTime;

+ (STMEntity *)entityWithName:(NSString *)name;

+ (void)deleteEntityWithName:(NSString *)name;

@end
