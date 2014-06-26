//
//  STMObjectsController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMObjectsController.h"
#import "STMSessionManager.h"
#import "STMDocument.h"
#import "STMFunctions.h"
#import "STMSyncer.h"

#import "STMPartner.h"
#import "STMOutlet.h"
#import "STMSalesman.h"
#import "STMCampaign.h"
#import "STMCampaignPicture.h"
#import "STMPhotoReport.h"
#import "STMPhoto.h"
#import "STMArticle.h"
#import "STMArticlePicture.h"
#import "STMSettings.h"
#import "STMLogMessage.h"


@implementation STMObjectsController

+ (STMDocument *)document {
    
    return (STMDocument *)[STMSessionManager sharedManager].currentSession.document;
    
}

+ (void)insertObjectFromDictionary:(NSDictionary *)dictionary {
    
//    NSLog(@"%@", dictionary);
    
    NSString *name = [dictionary objectForKey:@"name"];
    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *entityName = [@"STM" stringByAppendingString:[nameExplode objectAtIndex:1]];
//    NSLog(@"entityName %@", entityName);
    
    NSArray *dataModelEntityNames = [self dataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        NSString *xid = [dictionary objectForKey:@"xid"];
//        NSLog(@"xid %@", xid);
        
        NSManagedObject *object = [self objectForEntityName:entityName andXid:xid];
        
        NSDictionary *properties = [dictionary objectForKey:@"properties"];
        
        NSSet *ownObjectKeys = [self ownObjectKeysForEntityName:entityName];
//        NSLog(@"ownObjectKeys %@", ownObjectKeys);

        for (NSString *key in ownObjectKeys) {
            
            id value = [properties objectForKey:key];
            if (value) {
                
                [object setValue:value forKey:key];
//                NSLog(@"%@ %@", key, value);
                
                if ([key isEqualToString:@"href"]) {
                    [self hrefProcessingForObject:object];
                }
                
            }
            
        }

        NSDictionary *ownObjectRelationships = [self ownObjectRelationshipsForEntityName:entityName];
        
//        NSLog(@"ownObjectRelationships %@", ownObjectRelationships);
        
        for (NSString *relationship in [ownObjectRelationships allKeys]) {
            
//            NSLog(@"relationship %@", relationship);
            
            NSDictionary *relationshipDictionary = [properties objectForKey:relationship];
            NSString *destinationObjectXid = [relationshipDictionary objectForKey:@"xid"];
            
//            NSLog(@"relationshipDictionary %@, destinationObjectXid %@", relationshipDictionary, destinationObjectXid);
            
            if (destinationObjectXid) {
                
                NSManagedObject *destinationObject = [self objectForEntityName:[ownObjectRelationships objectForKey:relationship] andXid:destinationObjectXid];
                [object setValue:destinationObject forKey:relationship];
                
//                NSLog(@"relationship %@, destinationObject %@", relationship, destinationObject)
                
            }
            
        }
        
//        NSLog(@"object %@", object);
        
        [[self document] saveDocument:^(BOOL success) {}];

    }
    
}

+ (void)setRelationshipFromDictionary:(NSDictionary *)dictionary {
    
//    NSLog(@"relationship %@", dictionary);

    
    NSString *name = [dictionary objectForKey:@"name"];
    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *entityName = [@"STM" stringByAppendingString:[nameExplode objectAtIndex:1]];

    NSDictionary *serverDataModel = [(STMSyncer *)[STMSessionManager sharedManager].currentSession.syncer entitySyncInfo];

    if ([[serverDataModel allKeys] containsObject:entityName]) {
        
        NSDictionary *modelProperties = [serverDataModel objectForKey:entityName];
//        NSLog(@"modelProperties %@", modelProperties);
        
        NSString *roleOwner = [modelProperties objectForKey:@"roleOwner"];
        NSString *roleOwnerEntityName = [@"STM" stringByAppendingString:roleOwner];
        NSString *roleName = [modelProperties objectForKey:@"roleName"];
//        NSLog(@"roleOwner %@, roleName %@", roleOwner, roleName);
        
        NSDictionary *ownerRelationships = [self ownObjectRelationshipsForEntityName:roleOwnerEntityName];
//        NSLog(@"ownerRelationships %@", ownerRelationships);
        
        NSString *destinationEntityName = [ownerRelationships objectForKey:roleName];
//        NSLog(@"destinationEntityName %@", destinationEntityName);
        
        NSString *destination = [destinationEntityName stringByReplacingOccurrencesOfString:@"STM" withString:@""];
        
        NSDictionary *properties = [dictionary objectForKey:@"properties"];
        NSDictionary *ownerData = [properties objectForKey:roleOwner];
        NSDictionary *destinationData = [properties objectForKey:destination];
//        NSLog(@"ownerData %@, destinationData %@", ownerData, destinationData);
        
        NSString *ownerXid = [ownerData objectForKey:@"xid"];
        NSString *destinationXid = [destinationData objectForKey:@"xid"];
//        NSLog(@"ownerXid %@, destinationXid %@", ownerXid, destinationXid);
        
        BOOL ok = YES;
        
        if (!ownerXid || [ownerXid isEqualToString:@""] || !destinationXid || [destinationXid isEqualToString:@""]) {
            
            ok = NO;
            NSLog(@"Not ok relationship dictionary %@", dictionary);
            
        }
        
        if (ok) {
            
            NSManagedObject *ownerObject = [self objectForEntityName:roleOwnerEntityName andXid:ownerXid];
            NSManagedObject *destinationObject = [self objectForEntityName:destinationEntityName andXid:destinationXid];

            NSString *xid = [ownerXid stringByReplacingOccurrencesOfString:@"-" withString:@""];
            if ([xid isEqualToString:@"9e4addcaea4011e3944d005056851d41"]) {
//                NSLog(@"destinationEntityName %@, destinationXid %@", destinationEntityName, destinationXid);
            }
            
            NSSet *destinationSet = [ownerObject valueForKey:roleName];
            
            if ([destinationSet containsObject:destinationObject] && [destinationEntityName isEqualToString:@"STMCampaignPicture"]) {
                NSLog(@"already in set: %@, %@, %@", roleOwnerEntityName, destinationEntityName, destinationXid);
            } else {
                //            NSLog(@"BEFORE ownerObject %@, destinationObject %@", ownerObject, destinationObject);
                [[ownerObject mutableSetValueForKey:roleName] addObject:destinationObject];
                //            NSLog(@"AFTER ownerObject %@, destinationObject %@", ownerObject, destinationObject);
                //            NSLog(@"roleOwnerEntityName %@, destinationEntityName %@, roleName %@", roleOwnerEntityName, destinationEntityName, roleName);
                
                [[self document] saveDocument:^(BOOL success) {}];

            }
            
            
        }
        
    }
    
}

+ (NSManagedObject *)objectForEntityName:(NSString *)entityName andXid:(NSString *)xid {
    
    NSArray *dataModelEntityNames = [self dataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        xid = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSData *xidData = [STMFunctions dataFromString:xid];

        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];

        NSError *error;
        NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        NSManagedObject *object;
        
        if ([fetchResult lastObject]) {
        
            object = [fetchResult lastObject];
            if (![object.entity.name isEqualToString:entityName]) {
                NSLog(@"object.entity.name %@, entityName %@", object.entity.name, entityName);
            }
        
        }

        
        request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
        
        fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
//        NSManagedObject *object;
        
        if ([fetchResult lastObject]) {
            
            object = [fetchResult lastObject];
            
//            if ([xid isEqualToString:@"9e4addcaea4011e3944d005056851d41"]) {
//                NSLog(@"get object %@", object);
//            }
            
//            NSLog(@"object exist");
            
        } else {
            
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
            [object setValue:xidData forKey:@"xid"];

//            if ([xid isEqualToString:@"9e4addcaea4011e3944d005056851d41"]) {
//                NSLog(@"insert object %@", object);
//            }
            
//            NSLog(@"new object");
            
        }
        
//        NSLog(@"object %@", object);
        
        return object;
        
    } else {
        
        return nil;
        
    }
    
}

+ (NSSet *)ownObjectKeysForEntityName:(NSString *)entityName {
    
    NSEntityDescription *coreEntity = [NSEntityDescription entityForName:@"STMComment" inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreKeys = [NSSet setWithArray:[[coreEntity attributesByName] allKeys]];

    NSEntityDescription *objectEntity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    NSMutableSet *objectKeys = [NSMutableSet setWithArray:[[objectEntity attributesByName] allKeys]];

    [objectKeys minusSet:coreKeys];
    
    return objectKeys;
    
}

+ (NSDictionary *)ownObjectRelationshipsForEntityName:(NSString *)entityName {
    
    NSEntityDescription *coreEntity = [NSEntityDescription entityForName:@"STMComment" inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreRelationshipNames = [NSSet setWithArray:[[coreEntity relationshipsByName] allKeys]];
    
    NSEntityDescription *objectEntity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    NSMutableSet *objectRelationshipNames = [NSMutableSet setWithArray:[[objectEntity relationshipsByName] allKeys]];
    
    [objectRelationshipNames minusSet:coreRelationshipNames];
    
    NSMutableDictionary *objectRelationships = [NSMutableDictionary dictionary];
    
    for (NSString *relationshipName in objectRelationshipNames) {
        
        NSRelationshipDescription *relationship = [[objectEntity relationshipsByName] objectForKey:relationshipName];
        [objectRelationships setObject:[relationship destinationEntity].name forKey:relationshipName];
        
    }
    
//    NSLog(@"objectRelationships %@", objectRelationships);
    
    return objectRelationships;
    
}

+ (NSArray *)dataModelEntityNames {
    
    return [[self document].managedObjectModel.entitiesByName allKeys];
    
}

+ (void)removeAllObjects {
    
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:@"reload data" type:nil];

    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *datumFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSettings class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *settingsFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMLogMessage class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *logMessageFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];

    NSMutableSet *datumSet = [NSMutableSet setWithArray:datumFetchResult];
    NSSet *settingsSet = [NSSet setWithArray:settingsFetchResult];
    NSSet *logMessagesSet = [NSSet setWithArray:logMessageFetchResult];

    [datumSet minusSet:settingsSet];
    [datumSet minusSet:logMessagesSet];
        
    for (id datum in datumSet) {
        
        [[self document].managedObjectContext deleteObject:datum];
        
    }
    
    STMSyncer *syncer = [[STMSessionManager sharedManager].currentSession syncer];
    [syncer flushEntitySyncInfo];
    syncer.syncerState = STMSyncerRecieveData;
    
}

+ (void)hrefProcessingForObject:(NSManagedObject *)object {
    
    NSString *href = [object valueForKey:@"href"];
    
    if (href) {
        
        if ([object isKindOfClass:[STMPicture class]]) {
            
            NSURL *url = [NSURL URLWithString:href];
            NSURLSession *session = [NSURLSession sharedSession];
            [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    
                    NSLog(@"error %@", error.description);
                    
                } else {
                    
                    [object setValue:data forKeyPath:@"image"];
                    
                    UIImage *thumbnail = [STMFunctions resizeImage:[UIImage imageWithData:data] toSize:CGSizeMake(150, 150)];
                    [object setValue:UIImagePNGRepresentation(thumbnail) forKey:@"imageThumbnail"];
                    
                }
                
            }] resume];
            
        }
        
    }
    
}

+ (void)dataLoadingFinished {
    
//    [self generatePhotoReports];
    [self totalNumberOfObjects];
    
}

+ (void)generatePhotoReports {

    NSArray *outlets = [self objectsForEntityName:NSStringFromClass([STMOutlet class])];
    NSArray *campaigns = [self objectsForEntityName:NSStringFromClass([STMCampaign class])];
    
    for (STMCampaign *campaign in campaigns) {
        
        for (STMOutlet *outlet in outlets) {
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
            request.predicate = [NSPredicate predicateWithFormat:@"campaign == %@ AND outlet == %@", campaign, outlet];
            
            NSError *error;
            NSArray *photoReports = [self.document.managedObjectContext executeFetchRequest:request error:&error];
            
            if (photoReports.count == 0) {
                
                STMPhotoReport *photoReport = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMPhotoReport class]) inManagedObjectContext:self.document.managedObjectContext];
                photoReport.outlet = outlet;
                photoReport.campaign = campaign;
                
            }
            
        }
        
    }

}

+ (void)totalNumberOfObjects {
    
    NSArray *entityNames = @[NSStringFromClass([STMDatum class]),
                             NSStringFromClass([STMSettings class]),
                             NSStringFromClass([STMLogMessage class]),
                             NSStringFromClass([STMPartner class]),
                             NSStringFromClass([STMCampaign class]),
                             NSStringFromClass([STMArticle class]),
                             NSStringFromClass([STMCampaignPicture class]),
                             NSStringFromClass([STMSalesman class]),
                             NSStringFromClass([STMOutlet class]),
                             NSStringFromClass([STMPhotoReport class]),
                             NSStringFromClass([STMPhoto class])];
    
    NSUInteger totalCount = [self objectsForEntityName:NSStringFromClass([STMDatum class])].count;
    NSLog(@"total count %d", totalCount);
    
    for (NSString *entityName in entityNames) {
        
        if (![entityName isEqualToString:NSStringFromClass([STMDatum class])]) {
            
            NSUInteger count = [self objectsForEntityName:entityName].count;
            NSLog(@"%@ count %d", entityName, count);
            totalCount -= count;

        }

    }
    
    NSLog(@"unknow count %d", totalCount);
    
}

+ (NSArray *)objectsForEntityName:(NSString *)entityName {

    if ([[self dataModelEntityNames] containsObject:entityName]) {

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
        NSError *error;
        NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        return result;

    } else {
        
        return nil;
        
    }
    
}

@end