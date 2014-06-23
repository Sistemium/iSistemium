//
//  STMObjectsController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface STMObjectsController : NSObject

+ (void)insertObjectFromDictionary:(NSDictionary *)dictionary;
+ (void)setRelationshipFromDictionary:(NSDictionary *)dictionary;
+ (void)removeAllObjects;
+ (void)totalNumberOfObjects;
+ (void)hrefProcessingForObject:(NSManagedObject *)object;

@end
