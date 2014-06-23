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

+ (void)totalNumberOfObjects {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    
    NSError *error;
    NSArray *datumFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"datumFetchResult.count %d", datumFetchResult.count);
    
    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSettings class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *settingsFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"settingsFetchResult.count %d", settingsFetchResult.count);

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMLogMessage class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *logMessageFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"logMessageFetchResult.count %d", logMessageFetchResult.count);

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPartner class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *partnerFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"partnerFetchResult.count %d", partnerFetchResult.count);

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaign class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *campaignFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"campaignFetchResult.count %d", campaignFetchResult.count);

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *articleFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"articleFetchResult.count %d", articleFetchResult.count);

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaignPicture class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *campaignPictureFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"campaignPictureFetchResult.count %d", campaignPictureFetchResult.count);

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSalesman class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *salesmanPictureFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"salesmanPictureFetchResult.count %d", salesmanPictureFetchResult.count);

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *outletPictureFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"outletPictureFetchResult.count %d", outletPictureFetchResult.count);

    NSLog(@"unknown count %d", datumFetchResult.count - settingsFetchResult.count - logMessageFetchResult.count - partnerFetchResult.count - campaignFetchResult.count - articleFetchResult.count - campaignPictureFetchResult.count - salesmanPictureFetchResult.count - outletPictureFetchResult.count);

}

@end
