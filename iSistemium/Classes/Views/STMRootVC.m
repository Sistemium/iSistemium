//
//  STMRootVC.m
//  TestRootVC
//
//  Created by Maxim Grigoriev on 20/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMRootVC.h"
#import "STMAuthController.h"
#import "STMAuthTVC.h"

@interface STMRootVC () <UITabBarControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *tabs;

@end

@implementation STMRootVC

+ (STMRootVC *)sharedRootVC {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedRootVC = nil;
    
    dispatch_once(&pred, ^{
        _sharedRootVC = [[self alloc] init];
    });
    
    return _sharedRootVC;
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [self customInit];
        
    }
    
    return self;
    
}

- (void)customInit {
    
    self.delegate = self;
    
    NSArray *storyboardnames = @[@"STMAuthTVC",@"STMCampaigns"];
    
    for (NSString *name in storyboardnames) {
        
        if ([name isEqualToString:@"STMAuth"]) {
            
            STMAuthTVC *authTVC = [[STMAuthTVC alloc] initWithStyle:UITableViewStyleGrouped];
            authTVC.title = name;
            [self.tabs setObject:authTVC forKey:name];
            
        } else {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
            UIViewController *vc = [storyboard instantiateInitialViewController];
            vc.title = name;
            [self.tabs setObject:vc forKey:name];
            
        }
        
    }
    
    self.viewControllers = [self.tabs allValues];
    
    self.tabBar.hidden = YES;
    
}

- (NSMutableDictionary *)tabs {
    
    if (!_tabs) {
        _tabs = [NSMutableDictionary dictionary];
    }
    
    return _tabs;
    
}

- (void)showTabWithName:(NSString *)tabName {
    
    UIViewController *vc = [self.tabs objectForKey:tabName];
    
    if (vc) {
        
        [self setSelectedViewController:vc];
        
    }
    
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}


#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if ([STMAuthController authController].controllerState == STMAuthSuccess) {
//        [self showTabWithName:@"STMCampaigns"];
    } else {
        [self showTabWithName:@"STMAuth"];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
