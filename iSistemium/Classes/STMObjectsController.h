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

@interface STMObjectsController : NSObject

+ (void)insertObjectFromDictionary:(NSDictionary *)dictionary;
+ (void)setRelationshipFromDictionary:(NSDictionary *)dictionary;
+ (void)removeAllObjects;
+ (void)hrefProcessingForObject:(NSManagedObject *)object;
+ (void)dataLoadingFinished;
+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture;

@end
