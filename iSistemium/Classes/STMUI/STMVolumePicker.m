//
//  STMVolumePicker.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVolumePicker.h"

#import "STMSessionManager.h"


@interface STMVolumePicker() <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic) NSInteger selectedBoxCount;


@end


@implementation STMVolumePicker

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self customInit];
    }
    return self;
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self customInit];
    }
    
    return self;
    
}

- (void)customInit {
    
    self.delegate = self;
    self.dataSource = self;

}

- (void)setSelectedVolume:(NSInteger)selectedVolume {
    
    if (selectedVolume > self.volume) {
        selectedVolume = self.volume;
    }
    
    _selectedVolume = selectedVolume;
    
    self.selectedBoxCount = (self.packageRel > 0) ? self.selectedVolume / self.packageRel : 0;
    
    [self selectRow:self.selectedBoxCount inComponent:0 animated:YES];
    [self selectRow:self.selectedVolume inComponent:2 animated:YES];
    
}


#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            return (self.packageRel > 0) ? (self.volume / self.packageRel) + 1 : 1;
            break;
            
        case 1:
            return 1;
            break;
            
        case 2:
            return self.volume + 1;
            break;
            
        case 3:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            return @(row).stringValue;
            break;
            
        case 1:
            return NSLocalizedString(@"VOLUME UNIT1", nil);
            break;
            
        case 2:
            return (self.packageRel > 0) ? @(row % self.packageRel).stringValue : @(row).stringValue;
            break;
            
        case 3: {
            
            NSDictionary *appSettings = [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"appSettings"];
            BOOL enableShowBottles = [appSettings[@"enableShowBottles"] boolValue];
            
            return (enableShowBottles) ? NSLocalizedString(@"VOLUME UNIT2", nil) : NSLocalizedString(@"VOLUME UNIT3", nil);
            
        }
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            self.selectedVolume = self.selectedVolume + (row - self.selectedBoxCount) * self.packageRel;
            break;
            
        case 2:
            self.selectedVolume = row;
            break;
            
        default:
            break;
    }
    
}


@end
