//
//  STMSettingsController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 1/24/13.
//  Copyright (c) 2013 Maxim V. Grigoriev. All rights reserved.
//

#import "STMSettingsController.h"
#import "STMSetting.h"
#import "STMSession.h"
#import "STMSettingsData.h"

@interface STMSettingsController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedSettingsResultController;

@end

@implementation STMSettingsController


#pragma mark - class methods

+ (STMSettingsController *)initWithSettings:(NSDictionary *)startSettings {
    
    STMSettingsController *settingsController = [[STMSettingsController alloc] init];
    settingsController.startSettings = [startSettings mutableCopy];
    return settingsController;
    
}

- (NSDictionary *)defaultSettings {
    
    return  self.session.defaultSettings;
    
}

- (NSString *)normalizeValue:(NSString *)value forKey:(NSString *)key {
    
    NSArray *positiveDoubleValues = [NSArray arrayWithObjects:@"trackDetectionTime", @"trackSeparationDistance", @"fetchLimit", @"syncInterval", @"deviceMotionUpdateInterval", nil];
    
    NSArray *boolValues = [NSArray arrayWithObjects:@"localAccessToSettings", @"deviceMotionUpdate", nil];
    NSArray *boolValueSuffixes = [NSArray arrayWithObjects:@"TrackerAutoStart", nil];
    
    NSArray *URIValues = [NSArray arrayWithObjects:@"restServerURI", @"xmlNamespace", @"recieveDataServerURI", @"sendDataServerURI", nil];

    NSArray *timeValues = [NSArray arrayWithObjects:nil];
    NSArray *timeValueSuffixes = [NSArray arrayWithObjects:@"TrackerStartTime", @"TrackerFinishTime", nil];
    
    if ([positiveDoubleValues containsObject:key]) {
        if ([self isPositiveDouble:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else  if ([boolValues containsObject:key] || [self key:key hasSuffixFromArray:boolValueSuffixes]) {
        if ([self isBool:value]) {
            return [NSString stringWithFormat:@"%d", [value boolValue]];
        }
        
    } else if ([URIValues containsObject:key]) {
        if ([self isValidURI:value]) {
            return value;
        }
        
    } else if ([timeValues containsObject:key] || [self key:key hasSuffixFromArray:timeValueSuffixes]) {
        if ([self isValidTime:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else if ([key isEqualToString:@"desiredAccuracy"]) {
        double dValue = [value doubleValue];
        if (dValue == -2 || dValue == -1 || dValue == 10 || dValue == 100 || dValue == 1000 || dValue == 3000) {
            return [NSString stringWithFormat:@"%f", dValue];
        }
        
    } else if ([key isEqualToString:@"distanceFilter"]) {
        double dValue = [value doubleValue];
        if (dValue == -1 || dValue >= 0) {
            return [NSString stringWithFormat:@"%f", dValue];
        }
        
    } else if ([key isEqualToString:@"timeFilter"] || [key isEqualToString:@"requiredAccuracy"]) {
        double dValue = [value doubleValue];
        if (dValue >= 0) {
            return [NSString stringWithFormat:@"%f", dValue];
        }
        
    }
    
    return nil;
}

- (BOOL)isPositiveDouble:(NSString *)value {
    return ([value doubleValue] > 0);
}

- (BOOL)isBool:(NSString *)value {
    double dValue = [value doubleValue];
    return (dValue == 0 || dValue == 1);
}

- (BOOL)isValidTime:(NSString *)value {
    double dValue = [value doubleValue];
    return (dValue >= 0 && dValue <= 24);
}

- (BOOL)isValidURI:(NSString *)value {
    return ([value hasPrefix:@"http://"] || [value hasPrefix:@"https://"]);
}

- (BOOL)key:(NSString *)key hasSuffixFromArray:(NSArray *)array {
    
    BOOL result = NO;
    
    for (NSString *suffix in array) {
        result |= [key hasSuffix:suffix];
    }
    
    return result;
    
}


#pragma mark - instance methods

- (void)setSession:(id<STMSession>)session {
    
    _session = session;

    NSError *error;
    if (![self.fetchedSettingsResultController performFetch:&error]) {
        NSLog(@"settingsController performFetch error %@", error);
    } else {
        [self checkSettings];
    }
    
}

- (NSFetchedResultsController *)fetchedSettingsResultController {
    
    if (!_fetchedSettingsResultController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSetting class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:NO selector:@selector(compare:)]];
        _fetchedSettingsResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedSettingsResultController.delegate = self;
        
    }
    
    return _fetchedSettingsResultController;
    
}

- (NSArray *)currentSettings {
    return self.fetchedSettingsResultController.fetchedObjects;
}

- (NSMutableDictionary *)currentSettingsForGroup:(NSString *)group {
    
    NSMutableDictionary *settingsDictionary = [NSMutableDictionary dictionary];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.group == %@", group];
    NSArray *groupSettings = [[self currentSettings] filteredArrayUsingPredicate:predicate];
    
    for (STMSetting *setting in groupSettings) {
        [settingsDictionary setValue:setting.value forKey:setting.name];
    }
    
//    NSLog(@"settings for %@: %@", group, settingsDictionary);
    
    return settingsDictionary;
    
}

- (void)checkSettings {
    
    NSDictionary *defaultSettings = [self defaultSettings];
    //        NSLog(@"defaultSettings %@", defaultSettings);
    
    for (NSString *settingsGroupName in [defaultSettings allKeys]) {
        //            NSLog(@"settingsGroup %@", settingsGroupName);
        
        NSDictionary *settingsGroup = [defaultSettings valueForKey:settingsGroupName];
        
        for (NSString *settingName in [settingsGroup allKeys]) {
            //                NSLog(@"setting %@ %@", settingName, [settingsGroup valueForKey:settingName]);
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@", settingName];
            STMSetting *settingToCheck = [[[self currentSettings] filteredArrayUsingPredicate:predicate] lastObject];

            NSString *settingValue = [settingsGroup valueForKey:settingName];
            
            if ([[self.startSettings allKeys] containsObject:settingName]) {
                
                NSString *nValue = [self normalizeValue:[self.startSettings valueForKey:settingName] forKey:settingName];
                
                if (nValue) {
                    settingValue = nValue;
                } else {
                    NSLog(@"value %@ is not correct for %@", [self.startSettings valueForKey:settingName], settingName);
                    [self.startSettings removeObjectForKey:settingName];
                }
                
            }

            if (!settingToCheck) {
                
//                    NSLog(@"settingName %@", settingName);
                STMSetting *newSetting = (STMSetting *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMSetting class]) inManagedObjectContext:self.session.document.managedObjectContext];
                newSetting.group = settingsGroupName;
                newSetting.name = settingName;
                newSetting.value = settingValue;
                [newSetting addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
                
//                NSLog(@"newSetting %@", newSetting);

            } else {
                
                [settingToCheck addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
                
                if ([[self.startSettings allKeys] containsObject:settingName]) {
                    if (![settingToCheck.value isEqualToString:settingValue]) {
                        settingToCheck.value = settingValue;
//                        NSLog(@"new value");
                    }
                }
                
            }
            
        }
        
    }
    
    [[(STMSession *)self.session document] saveDocument:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsLoadComplete" object:self];
        }
    }];

}

- (NSString *)setNewSettings:(NSDictionary *)newSettings forGroup:(NSString *)group {

    NSString *value;
    
    for (NSString *settingName in [newSettings allKeys]) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.group == %@ && SELF.name == %@", group, settingName];
        STMSetting *setting = [[[self currentSettings] filteredArrayUsingPredicate:predicate] lastObject];
        value = [self normalizeValue:[newSettings valueForKey:settingName] forKey:settingName];
        
        if (value) {
            
            if (!setting) {
                
                setting = (STMSetting *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMSetting class]) inManagedObjectContext:self.session.document.managedObjectContext];
                setting.group = group;
                setting.name = settingName;
                
            }
            
            setting.value = value;
            
        } else {
            
            NSLog(@"wrong value %@ for setting %@", [newSettings valueForKey:settingName], settingName);
            value = setting.value;
            
        }
        
    }
    
    return value;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"observeChangeValueForObject %@", object);
//    NSLog(@"old value %@", [change valueForKey:NSKeyValueChangeOldKey]);
//    NSLog(@"new value %@", [change valueForKey:NSKeyValueChangeNewKey]);
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"controllerDidChangeContent");
    [[(STMSession *)self.session document] saveDocument:^(BOOL success) {
        if (success) {
            NSLog(@"save settings success");
        }
    }];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSLog(@"controller didChangeObject");
//    NSLog(@"anObject %@", anObject);
    
    if ([anObject isKindOfClass:[STMSetting class]]) {
       
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@SettingsChanged", [anObject valueForKey:@"group"]] object:self.session userInfo:[NSDictionary dictionaryWithObject:[anObject valueForKey:@"value"] forKey:[anObject valueForKey:@"name"]]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChanged" object:self.session userInfo:[NSDictionary dictionaryWithObject:anObject forKey:@"changedObject"]];
        
    }
        
    if (type == NSFetchedResultsChangeDelete) {
        
//        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
//        NSLog(@"NSFetchedResultsChangeInsert");
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
//        NSLog(@"NSFetchedResultsChangeUpdate");
        
    }
    
}


@end
