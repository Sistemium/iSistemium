//
//  STMRootVC.m
//  TestRootVC
//
//  Created by Maxim Grigoriev on 20/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMRootTBC.h"
#import "STMAuthController.h"
#import "STMAuthTVC.h"

@interface STMRootTBC () <UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *storyboardnames;
@property (nonatomic, strong) NSMutableDictionary *tabs;
@property (nonatomic, strong) UIAlertView *authAlert;

@end

@implementation STMRootTBC

+ (STMRootTBC *)sharedRootVC {
    
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
    
    [self addObservers];

    self.delegate = self;
    
    self.storyboardnames = @[@"STMAuthTVC",@"STMCampaigns"];
    
    for (NSString *name in self.storyboardnames) {
        
//        if ([name isEqualToString:@"STMAuth"]) {
//            
//            STMAuthTVC *authTVC = [[STMAuthTVC alloc] initWithStyle:UITableViewStyleGrouped];
//            authTVC.title = name;
//            [self.tabs setObject:authTVC forKey:name];
//            
//        } else {
        
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
            UIViewController *vc = [storyboard instantiateInitialViewController];
            vc.title = name;
            [self.tabs setObject:vc forKey:name];
            
//        }
        
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

- (void)flushTabs {
    
    [self customInit];
    
}

- (void)showTabWithName:(NSString *)tabName {
    
    UIViewController *vc = [self.tabs objectForKey:tabName];
    
    if (vc) {
        
        [self setSelectedViewController:vc];
        
    }
    
}

- (void)showTabAtIndex:(NSUInteger)index {
    
    UIViewController *vc = [self.tabs objectForKey:self.storyboardnames[index]];
    
    if (vc) {
        
        [self setSelectedViewController:vc];
        
    }

}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    return self;
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.5;
    
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [toViewController.view layoutIfNeeded];
    
    [UIView transitionFromView:fromViewController.view
                        toView:toViewController.view
                      duration:[self transitionDuration:transitionContext]
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
                        [transitionContext completeTransition:YES];
                    }];

}


#pragma mark - alertView & delegate

- (UIAlertView *)authAlert {
    
    if (!_authAlert) {
        
        _authAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"U R NOT AUTH", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
    }
    
    return _authAlert;
    
}

- (void)showAuthAlert {
    
    if (!self.authAlert.visible && [STMAuthController authController].controllerState != STMAuthEnterPhoneNumber) {
        [self.authAlert show];
        [self showTabWithName:@"STMAuthTVC"];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
}

#pragma mark - notifications

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthAlert) name:@"notAuthorized" object:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notAuthorized" object:nil];
    
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
    
//    if ([STMAuthController authController].controllerState == STMAuthSuccess) {
//        [self showTabWithName:@"STMCampaigns"];
//    } else {
//        [self showTabWithName:@"STMAuthTVC"];
//    }

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
