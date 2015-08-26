//
//  STMCatalogSettingsNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogSettingsNC.h"
#import "STMCatalogSettingsTVC.h"

@interface STMCatalogSettingsNC ()

@end

@implementation STMCatalogSettingsNC

- (instancetype)initWithSettings:(NSArray *)settings {
    
    STMCatalogSettingsTVC *rootViewController = [[STMCatalogSettingsTVC alloc] initWithSettings:settings];
    rootViewController.parentNC = self;
    
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        
        CGFloat navBarHeight = self.navigationBar.frame.size.height;
        CGFloat height = rootViewController.view.frame.size.height;
        CGFloat width = rootViewController.view.frame.size.width;
        
        self.view.frame = CGRectMake(0, 0, width, height + navBarHeight);
        
    }
    return self;
    
}

- (void)updateSettings:(NSArray *)newSettings {
    [self.catalogSVC updateSettings:newSettings];
}

- (void)dismissSelf {
    [self.catalogSVC.detailTVC dismissCatalogSettingsPopover];
}


#pragma mark - view lifecycle

- (void)customInit {
        
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
