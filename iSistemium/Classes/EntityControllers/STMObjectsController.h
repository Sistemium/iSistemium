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
#import <Crashlytics/Crashlytics.h>


@interface STMObjectsController : STMController

+ (STMObjectsController *)sharedController;

+ (void)initObjectsCacheWithCompletionHandler:(void (^)(BOOL success))completionHandler;

+ (void)checkObjectsForFlushing;

+ (void)processingOfDataArray:(NSArray *)array roleName:(NSString *)roleName withCompletionHandler:(void (^)(BOOL success))completionHandler;

+ (void)insertObjectsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler;
+ (void)insertObjectFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler;

+ (void)setRelationshipsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler;
+ (void)setRelationshipFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler;

+ (NSSet *)ownObjectKeysForEntityName:(NSString *)entityName;

+ (NSDictionary *)dictionaryForObject:(NSManagedObject *)object;
+ (NSArray *)jsonForObjectsWithParameters:(NSDictionary *)parameters error:(NSError **)error;

+ (void)syncObject:(NSDictionary *)objectDictionary;

+ (void)removeObject:(NSManagedObject *)object;
+ (STMRecordStatus *)createRecordStatusAndRemoveObject:(NSManagedObject *)object;

+ (void)dataLoadingFinished;

+ (NSManagedObject *)newObjectForEntityName:(NSString *)entityName;
+ (NSManagedObject *)objectForXid:(NSData *)xidData;

+ (NSArray *)localDataModelEntityNames;

+ (NSArray *)objectsForEntityName:(NSString *)entityName;



@end
