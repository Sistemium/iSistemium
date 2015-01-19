//
//  STMObjectsController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMController.h"
#import <CoreData/CoreData.h>
#import "STMRecordStatus.h"

@interface STMObjectsController : STMController

+ (STMObjectsController *)sharedController;

+ (void)checkObjectsForFlushing;

+ (void)insertObjectsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler;
+ (void)insertObjectFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler;

+ (void)setRelationshipsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler;
+ (void)setRelationshipFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler;

+ (STMRecordStatus *)recordStatusForObject:(NSManagedObject *)object;
+ (STMRecordStatus *)removeObject:(NSManagedObject *)object;

+ (void)dataLoadingFinished;

+ (NSManagedObject *)newObjectForEntityName:(NSString *)entityName;
+ (NSManagedObject *)objectForXid:(NSData *)xidData;
+ (NSUInteger)unreadMessagesCount;
+ (NSArray *)entityNamesForSyncing;
+ (NSArray *)localDataModelEntityNames;

@end