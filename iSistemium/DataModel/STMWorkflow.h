//
//  STMWorkflow.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/09/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMEntity, STMMessage;

@interface STMWorkflow : STMComment

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * workflow;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *entities;
@end

@interface STMWorkflow (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(STMMessage *)value;
- (void)removeMessagesObject:(STMMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addEntitiesObject:(STMEntity *)value;
- (void)removeEntitiesObject:(STMEntity *)value;
- (void)addEntities:(NSSet *)values;
- (void)removeEntities:(NSSet *)values;

@end
