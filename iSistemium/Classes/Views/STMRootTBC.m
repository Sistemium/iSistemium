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
#import "STMFunctions.h"
#import "STMSessionManager.h"
#import "STMSession.h"

@interface STMRootTBC () <UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *storyboardnames;
@property (nonatomic, strong) NSArray *tabImages;
@property (nonatomic, strong) NSMutableDictionary *tabs;
@property (nonatomic, strong) UIAlertView *authAlert;
@property (nonatomic, strong) STMSession *session;

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

- (STMSession *)session {
    
    return [STMSessionManager sharedManager].currentSession;
    
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
    
    self.storyboardnames = @[@"STMAuthTVC",
                             @"STMCampaigns",
                             @"STMDebts"];
    
    self.storyboardtitles = @[NSLocalizedString(@"AUTHORIZATION", nil),
                              NSLocalizedString(@"AD CAMPAIGNS", nil),
                              NSLocalizedString(@"DEBTS", nil)];
    
    self.tabImages = @[[UIImage imageNamed:@"password2-128.png"],
                       [UIImage imageNamed:@"christmas_gift-128.png"],
                       [UIImage imageNamed:@"cash_receiving-128.png"]];
    
    
//    self.tabBar.hidden = YES;
    self.tabBar.hidden = NO;
    
    [self stateChanged];
    
}

- (NSMutableDictionary *)tabs {
    
    if (!_tabs) {
        _tabs = [NSMutableDictionary dictionary];
    }
    
    return _tabs;
    
}

- (void)initAuthTab {
    
    self.tabs = nil;
    
    NSString *authTabName = self.storyboardnames[0];
    NSString *authTabTitle = self.storyboardtitles[0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:authTabName bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    vc.title = authTabTitle;
    vc.tabBarItem.image = [STMFunctions resizeImage:self.tabImages[0] toSize:CGSizeMake(30, 30)];

    [self.tabs setObject:vc forKey:authTabName];
    
    self.viewControllers = [self.tabs allValues];

}

- (void)initAllTabs {

    NSMutableArray *viewControllers = [NSMutableArray array];
    
    for (NSString *name in self.storyboardnames) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
        
        NSUInteger index = [self.storyboardnames indexOfObject:name];
        
        UIViewController *vc = [storyboard instantiateInitialViewController];
        vc.title = [self.storyboardtitles objectAtIndex:index];
        vc.tabBarItem.image = [STMFunctions resizeImage:self.tabImages[index] toSize:CGSizeMake(30, 30)];
        [viewControllers addObject:vc];

        [self.tabs setObject:vc forKey:name];
        
    }
    
    self.viewControllers = viewControllers;
    
    self.selectedIndex = 2;

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

- (void)authControllerError:(NSNotification *)notification {
        
    NSString *error = [[notification userInfo] objectForKey:@"error"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.tag = 0;
    [alertView show];
    
}

- (void)stateChanged {
    
    [self authStateChanged];
    [self syncStateChanged];
    
}

- (void)authStateChanged {
    
    [STMAuthController authController].controllerState != STMAuthSuccess ? [self initAuthTab] : [self initAllTabs];
    
}

- (void)syncStateChanged {

//    self.session.syncer.syncerState == STMSyncerIdle ? [self enableTabs] : [self disableTabs];

    [self enableTabs];
    
}

- (void)disableTabs {
    
    for (UIViewController *vc in self.viewControllers) {
        
        vc.tabBarItem.enabled = NO;
        
    }
    
}

- (void)enableTabs {

    for (UIViewController *vc in self.viewControllers) {
        
        vc.tabBarItem.enabled = YES;
        
    }
    
}

#pragma mark - notifications

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthAlert) name:@"notAuthorized" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authControllerError:) name:@"authControllerError" object:[STMAuthController authController]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authStateChanged) name:@"authControllerStateChanged" object:[STMAuthController authController]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStateChanged) name:@"syncStatusChanged" object:self.session.syncer];
    
}

- (void)removeObservers {
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notAuthorized" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
