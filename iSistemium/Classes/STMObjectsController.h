//
//  STMObjectsController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMPicture.h"
#import "STMRecordStatus.h"

@interface STMObjectsController : NSObject

+ (STMObjectsController *)sharedController;

+ (void)checkPhotos;
+ (void)checkClientData;
+ (void)checkAppVersion;
+ (void)checkUploadedPhotos;

+ (void)insertObjectsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler;
+ (void)insertObjectFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler;

+ (void)setRelationshipsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler;
+ (void)setRelationshipFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler;

+ (STMRecordStatus *)recordStatusForObject:(NSManagedObject *)object;

+ (void)removeAllObjects;

+ (void)hrefProcessingForObject:(NSManagedObject *)object;
+ (void)dataLoadingFinished;
+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture;

+ (NSManagedObject *)newObjectForEntityName:(NSString *)entityName;
+ (NSManagedObject *)objectForXid:(NSData *)xidData;
+ (NSUInteger)unreadMessagesCount;
+ (NSArray *)entityNamesForSyncing;
+ (NSArray *)localDataModelEntityNames;

@end
