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

- (instancetype)initWithSettings:(NSDictionary *)settings {
    
    STMCatalogSettingsTVC *rootViewController = [[STMCatalogSettingsTVC alloc] initWithSettings:settings];
    
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        
        CGFloat navBarHeight = self.navigationBar.frame.size.height;
        CGFloat height = rootViewController.view.frame.size.height;
        CGFloat width = rootViewController.view.frame.size.width;
        
        self.view.frame = CGRectMake(0, 0, width, height + navBarHeight);
        
    }
    return self;
    
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
