//
//  STMCatalogSettingsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"

@interface STMCatalogSettingsTVC : STMFetchedResultsControllerTVC

@property (nonatomic, strong) NSArray *settings;

- (instancetype)initWithSettings:(NSArray *)settings;

@end
