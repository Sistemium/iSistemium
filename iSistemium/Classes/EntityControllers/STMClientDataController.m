//
//  STMClientDataController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 15/01/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMClientDataController.h"
#import "STMClientData.h"
#import "STMAuthController.h"
#import "STMEntityDescription.h"
#import "STMSetting.h"

@implementation STMClientDataController


#pragma mark - checking client state

+ (void)checkClientData {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL clientDataWaitingForSync = [[defaults objectForKey:@"clientDataWaitingForSync"] boolValue];
    
    STMClientData *clientData = [self clientData];
    
    if (clientData) {
        
        NSString *tokenHash = clientData.tokenHash;
        if (!tokenHash) {
            tokenHash = [STMAuthController authController].tokenHash;
            clientDataWaitingForSync = YES;
        }
        
        NSString *deviceName = clientData.deviceName;
        if (!deviceName) {
            deviceName = [[UIDevice currentDevice] name];
            clientDataWaitingForSync = YES;
        }
        
        if (clientDataWaitingForSync && clientData) {
            
            NSData *deviceToken = [defaults objectForKey:@"deviceToken"];
            if (deviceToken && deviceToken != clientData.deviceToken) {
                clientData.deviceToken = deviceToken;
            }
            
            NSDate *lastAuth = [defaults objectForKey:@"lastAuth"];
            if (lastAuth && lastAuth != clientData.lastAuth) {
                clientData.lastAuth = lastAuth;
            }
            
            clientData.tokenHash = tokenHash;
            clientData.deviceName = deviceName;
            
#ifdef DEBUG
            
            clientData.buildType = @"debug";
            
#else
            
            clientData.buildType = @"release";
            
#endif
            
        }
        
    }
    
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
