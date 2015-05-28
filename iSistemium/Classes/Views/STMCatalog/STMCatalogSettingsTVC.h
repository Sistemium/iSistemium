//
//  STMCatalogSettingsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMCatalogSettingsNC.h"


@interface STMCatalogSettingsTVC : STMFetchedResultsControllerTVC

@property (nonatomic, strong) NSArray *settings;
@property (nonatomic, weak) STMCatalogSettingsNC *parentNC;

- (instancetype)initWithSettings:(NSArray *)settings;

- (void)updateParameters:(NSDictionary *)newParameters;

@end
