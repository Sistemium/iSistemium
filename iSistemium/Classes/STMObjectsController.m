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
        //    NSLog(@"xid %@", xid);
        
        NSManagedObject *object = [self objectForEntityName:entityName andXid:xid];
        
        NSDictionary *properties = [dictionary objectForKey:@"properties"];
        
        NSSet *ownObjectKeys = [self ownObjectKeysForEntityName:entityName];
        
        for (NSString *key in ownObjectKeys) {
            
            id value = [properties objectForKey:key];
            [object setValue:value forKey:key];
            
        }
        
        NSDictionary *ownObjectRelationships = [self ownObjectRelationshipsForEntityName:entityName];
        
        for (NSString *relationship in [ownObjectRelationships allKeys]) {
            
            NSDictionary *relationshipDictionary = [properties objectForKey:relationship];
            NSString *destinationObjectXid = [relationshipDictionary objectForKey:@"xid"];
            
            if (destinationObjectXid) {
                
                NSManagedObject *destinationObject = [self objectForEntityName:[ownObjectRelationships objectForKey:relationship] andXid:destinationObjectXid];
                [object setValue:destinationObject forKey:relationship];
                
            }
            
        }
        
//    NSLog(@"object %@", object);
        
        [[self document] saveDocument:^(BOOL success) {}];

    }
    
}

+ (void)setRelationshipFromDictionary:(NSDictionary *)dictionary {
    
//    NSLog(@"relationship %@", dictionary);
    
    NSString *name = [dictionary objectForKey:@"name"];
    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *entityName = [@"STM" stringByAppendingString:[nameExplode objectAtIndex:1]];

    NSDictionary *serverDataModel = [(STMSyncer *)[STMSessionManager sharedManager].currentSession.syncer serverDataModel];
    
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
        
        NSManagedObject *ownerObject = [self objectForEntityName:roleOwnerEntityName andXid:ownerXid];
        NSManagedObject *destinationObject = [self objectForEntityName:destinationEntityName andXid:destinationXid];
        
        [[ownerObject mutableSetValueForKey:roleName] addObject:destinationObject];
//        NSLog(@"ownerObject %@, destinationObject %@", ownerObject, destinationObject);
        
        [[self document] saveDocument:^(BOOL success) {}];
        
    }
    
}

+ (NSManagedObject *)objectForEntityName:(NSString *)entityName andXid:(NSString *)xid {
    
    NSArray *dataModelEntityNames = [self dataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        xid = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSData *xidData = [STMFunctions dataFromString:xid];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
        
        NSError *error;
        NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        NSManagedObject *object;
        
        if ([fetchResult lastObject]) {
            
            object = [fetchResult lastObject];
            
        } else {
            
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
            [object setValue:xidData forKey:@"xid"];
            
        }
        
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


@end
