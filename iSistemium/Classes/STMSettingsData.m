//
//  STMSettingsData.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSettingsData.h"
#import <CoreLocation/CoreLocation.h>
#import <KiteJSONValidator/KiteJSONValidator.h>

@implementation STMSettingsData

+ (NSDictionary *)settingsFromFileName:(NSString *)settingsFileName withSchemaName:(NSString *)schemaName {
    
    NSString *schemaPath = [[NSBundle mainBundle] pathForResource:schemaName ofType:@"json"];
    NSData *schemaData = [NSData dataWithContentsOfFile:schemaPath];
    
    NSString *settingsPath = [[NSBundle mainBundle] pathForResource:settingsFileName ofType:@"json"];
    NSData *settingsData = [NSData dataWithContentsOfFile:settingsPath];

    return [self settingsFromData:settingsData withSchema:schemaData];
    
}


+ (NSDictionary *)settingsFromData:(NSData *)settingsData withSchema:(NSData *)schemaData {
    
    KiteJSONValidator *JSONValidator = [[KiteJSONValidator alloc] init];
    
    if ([JSONValidator validateJSONData:settingsData withSchemaData:schemaData]) {
        
        NSMutableDictionary *settingsValues = [NSMutableDictionary dictionary];
        NSMutableDictionary *settingsControls = [NSMutableDictionary dictionary];
        
        NSError *error;
        NSDictionary *settingsJSON = [NSJSONSerialization JSONObjectWithData:settingsData options:NSJSONReadingMutableContainers error:&error];
        
        NSMutableArray *settingsControlGroupNames = [NSMutableArray array];
        
        for (NSDictionary *group in [settingsJSON objectForKey:@"defaultSettings"]) {
            
            NSString *groupName = [group valueForKey:@"group"];
            
            NSMutableDictionary *settingsValuesGroup = [NSMutableDictionary dictionary];
            NSMutableArray *settingsControlsGroup = [NSMutableArray array];
            
            for (NSDictionary *settingItem in [group valueForKey:@"data"]) {
                
                NSString *itemName = [settingItem valueForKey:@"name"];
                id itemValue = [settingItem valueForKey:@"value"];
                
                itemValue = [itemValue isKindOfClass:[NSString class]] ? itemValue : [itemValue stringValue];
                
                [settingsValuesGroup setValue:itemValue forKey:itemName];
                
                NSString *itemControlType = [settingItem valueForKey:@"control"];
                
                if (itemControlType) {
                    
                    NSString *itemMinValue = [[settingItem valueForKey:@"min"] stringValue];
                    NSString *itemMaxValue = [[settingItem valueForKey:@"max"] stringValue];
                    NSString *itemStepValue = [[settingItem valueForKey:@"step"] stringValue];
                    
                    itemMinValue = itemMinValue ? itemMinValue : @"";
                    itemMaxValue = itemMaxValue ? itemMaxValue : @"";
                    itemStepValue = itemStepValue ? itemStepValue : @"";
                    
                    [settingsControlsGroup addObject:@[itemControlType, itemMinValue, itemMaxValue, itemStepValue, itemName]];
                    
                    NSLog(@"%@", itemName);
                    
                }
                
            }
            
            if (settingsValuesGroup.count > 0) {
                [settingsValues setObject:settingsValuesGroup forKey:groupName];
            }
            if (settingsControlsGroup.count > 0) {
                [settingsControls setObject:settingsControlsGroup forKey:groupName];
                [settingsControlGroupNames addObject:groupName];
            }
            
        }
        
        [settingsControls setObject:settingsControlGroupNames forKey:@"groupNames"];
        
        return [NSDictionary dictionaryWithObjectsAndKeys:settingsValues, @"values", settingsControls, @"controls", nil];
        
    } else {
        
        NSLog(@"settingsData not confirm schema");
        return nil;
        
    }

}

@end
