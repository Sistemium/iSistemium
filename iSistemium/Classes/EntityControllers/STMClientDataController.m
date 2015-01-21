//
//  STMClientDataController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 15/01/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAppDelegate.h"
#import "STMClientDataController.h"
#import "STMClientData.h"
#import "STMAuthController.h"
#import "STMEntityDescription.h"
#import "STMSetting.h"
#import "STMObjectsController.h"

@implementation STMClientDataController


+ (STMAppDelegate *)appDelegate {
    return (STMAppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - clientData properties

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)buildType {
    
    #ifdef DEBUG
        return @"debug";
    #else
        return @"release";
    #endif
    
}

+ (NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

+ (NSData *)deviceToken {
    return [self appDelegate].deviceToken;
}

+(NSString *)deviceTokenError {
    return [self appDelegate].deviceTokenError;
}

+ (NSDate *)lastAuth {
    return [STMAuthController authController].lastAuth;
}

+ (NSString *)locationServiceStatus {
    return [[self session].locationTracker locationServiceStatus];
}

+ (NSString *)tokenHash {
    return [STMAuthController authController].tokenHash;
}

+ (NSString *)notificationTypes {
    return [[self appDelegate] currentNotificationTypes];
}


#pragma mark - checking client state

+ (void)checkClientData {
    
    STMClientData *clientData = [self clientData];
    
    if (clientData) {
        
        NSSet *keys = [STMObjectsController ownObjectKeysForEntityName:NSStringFromClass([STMClientData class])];
        
        for (NSString *key in keys) {
            
            SEL selector = NSSelectorFromString(key);
            
            if ([self respondsToSelector:selector]) {
                
// next 3 lines — implementation of id value = [self performSelector:selector] w/o warning
                IMP imp = [self methodForSelector:selector];
                id (*func)(id, SEL) = (void *)imp;
                id value = func(self, selector);
                
                if (![value isEqual:[clientData valueForKey:key]]) {
                    [clientData setValue:value forKey:key];
//                    NSLog(@"%@ was changed", key);
                }
                
            }
            
        }

    }
    
//    NSLog(@"clientData %@", clientData);

}

+ (STMClientData *)clientData {
    
    if ([self document].managedObjectContext) {
        
        NSString *entityName = NSStringFromClass([STMClientData class]);
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        
        NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:nil];
        STMClientData *clientData = [fetchResult lastObject];
        
        if (!clientData) {
            clientData = [STMEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
        }
        
        return clientData;
        
    } else {
        
        return nil;
        
    }
    
}

+ (void)checkAppVersion {
    
    if ([self document].managedObjectContext) {
        
        STMClientData *clientData = [self clientData];
        
        if (clientData) {
            
            NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
            if (![bundleVersion isEqualToString:clientData.appVersion]) {
                clientData.appVersion = bundleVersion;
            }
            
            NSString *entityName = NSStringFromClass([STMSetting class]);
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
            request.predicate = [NSPredicate predicateWithFormat:@"name == %@", @"availableVersion"];
            
            NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:nil];
            STMSetting *availableVersionSetting = [fetchResult lastObject];
            
            if (availableVersionSetting) {
                
                NSNumber *availableVersion = [NSNumber numberWithInteger:[availableVersionSetting.value integerValue]];
                NSNumber *currentVersion = [NSNumber numberWithInteger:[clientData.appVersion integerValue]];
                
                [self compareAvailableVersion:availableVersion withCurrentVersion:currentVersion];
                
            }
            
        }
        
    }
    
}

+ (void)compareAvailableVersion:(NSNumber *)availableVersion withCurrentVersion:(NSNumber *)currentVersion {
    
    if ([availableVersion compare:currentVersion] == NSOrderedDescending) {
        
        NSString *entityName = NSStringFromClass([STMSetting class]);

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"name == %@", @"appDownloadUrl"];
        
        NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:nil];
        STMSetting *appDownloadUrlSetting = [fetchResult lastObject];
        
        if (appDownloadUrlSetting) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"newAppVersionAvailable"];
            [defaults setObject:availableVersion forKey:@"availableVersion"];
            [defaults setObject:appDownloadUrlSetting.value forKey:@"appDownloadUrl"];
            [defaults synchronize];
            
            NSDictionary *userInfo = @{@"availableVersion": availableVersion, @"appDownloadUrl":appDownloadUrlSetting.value};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newAppVersionAvailable"
                                                                object:nil
                                                              userInfo:userInfo];
            
        }
        
    } else {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"newAppVersionAvailable"];
        [defaults removeObjectForKey:@"availableVersion"];
        [defaults removeObjectForKey:@"appDownloadUrl"];
        [defaults synchronize];
        
    }

}


@end
