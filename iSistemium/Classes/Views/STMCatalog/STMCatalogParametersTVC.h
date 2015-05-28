//
//  STMCatalogParametersTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMCatalogSettingsTVC.h"


@interface STMCatalogParametersTVC : STMFetchedResultsControllerTVC

@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, weak) STMCatalogSettingsTVC *settingsTVC;

@end
