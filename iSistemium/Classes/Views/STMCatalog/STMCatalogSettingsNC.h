//
//  STMCatalogSettingsNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCatalogSVC.h"

@interface STMCatalogSettingsNC : UINavigationController

@property (nonatomic, weak) STMCatalogSVC *catalogSVC;

- (instancetype)initWithSettings:(NSArray *)settings;

@end
