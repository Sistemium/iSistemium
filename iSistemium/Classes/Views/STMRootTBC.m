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
#import "STMObjectsController.h"
#import "STMTabBarViewController.h"
#import "STMClientDataController.h"
#import "STMConstants.h"

@interface STMRootTBC () <UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *tabs;
@property (nonatomic, strong) UIAlertView *authAlert;
@property (nonatomic, strong) STMSession *session;

@property (nonatomic, strong) NSString *appDownloadUrl;
@property (nonatomic) BOOL updateAlertIsShowing;

@property (nonatomic, strong) UIViewController *currentTappedVC;

@property (nonatomic, strong) NSMutableArray *allTabsVCs;
@property (nonatomic, strong) NSMutableArray *authVCs;

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

- (BOOL)newAppVersionAvailable {
    
    if ([self.session.status isEqualToString:@"running"]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [[defaults objectForKey:@"newAppVersionAvailable"] boolValue];

    } else {
        
        return NO;
        
    }
    
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self customInit];
        
    }
    
    return self;
    
}

- (void)customInit {

    [self addObservers];

    self.delegate = self;
    
    if (IPAD) {
        [self setupIPadTabs];
    } else if (IPHONE) {
        [self setupIPhoneTabs];
    }
    
    self.tabBar.hidden = NO;
    
    [self stateChanged];
    
}

- (NSMutableArray *)allTabsVCs {
    
    if (!_allTabsVCs) {
        _allTabsVCs = [NSMutableArray array];
    }
    return _allTabsVCs;
    
}

- (NSMutableArray *)authVCs {
    
    if (!_authVCs) {
        _authVCs = [NSMutableArray array];
    }
    return _authVCs;
    
}

- (NSMutableDictionary *)tabs {
    
    if (!_tabs) {
        _tabs = [NSMutableDictionary dictionary];
    }
    
    return _tabs;
    
}

- (NSMutableArray *)storyboardTitles {
    
    if (!_storyboardTitles) {
        _storyboardTitles = [NSMutableArray array];
    }
    return _storyboardTitles;
    
}

- (void)registerTabWithName:(NSString *)name title:(NSString *)title image:(UIImage *)image {
    
    if (name) {
        
        (title) ? [self.storyboardTitles addObject:title] : [self.storyboardTitles addObject:name];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
        UIViewController *vc = [storyboard instantiateInitialViewController];
        vc.title = title;
        vc.tabBarItem.image = [STMFunctions resizeImage:image toSize:CGSizeMake(30, 30)];

        [self.allTabsVCs addObject:vc];
        
        (self.tabs)[name] = vc;
        
        if ([name hasPrefix:@"STMAuth"]) {
            [self.authVCs addObject:vc];
        }
                
    }
    
}

- (void)setupIPadTabs {
    
    NSLog(@"device is iPad");
    
    [self registerTabWithName:@"STMAuth"
                        title:NSLocalizedString(@"AUTHORIZATION", nil)
                        image:[UIImage imageNamed:@"password2-128.png"]];

    [self registerTabWithName:@"STMCampaigns"
                        title:NSLocalizedString(@"AD CAMPAIGNS", nil)
                        image:[UIImage imageNamed:@"christmas_gift-128.png"]];

    [self registerTabWithName:@"STMDebts"
                        title:NSLocalizedString(@"OUTLETS", nil)
                        image:[UIImage imageNamed:@"cash_receiving-128.png"]];

    [self registerTabWithName:@"STMUncashing"
                        title:NSLocalizedString(@"UNCASHING", nil)
                        image:[UIImage imageNamed:@"banknotes-128.png"]];

    [self registerTabWithName:@"STMMessages"
                        title:NSLocalizedString(@"MESSAGES", nil)
                        image:[UIImage imageNamed:@"message-128.png"]];

    [self registerTabWithName:@"STMWebView"
                        title:NSLocalizedString(@"IORDERS", nil)
                        image:[UIImage imageNamed:@"purchase_order-128.png"]];

#ifdef DEBUG
    
    [self registerTabWithName:@"STMSettings"
                        title:NSLocalizedString(@"SETTINGS", nil)
                        image:[UIImage imageNamed:@"settings3-128.png"]];

    [self registerTabWithName:@"STMLogs"
                        title:NSLocalizedString(@"LOGS", nil)
                        image:[UIImage imageNamed:@"archive-128.png"]];
    
#endif

}

- (void)setupIPhoneTabs {
    
    NSLog(@"device is iPhone");

    [self registerTabWithName:@"STMAuth"
                        title:NSLocalizedString(@"AUTHORIZATION", nil)
                        image:[UIImage imageNamed:@"password2-128.png"]];

    [self registerTabWithName:@"STMMessages"
                        title:NSLocalizedString(@"MESSAGES", nil)
                        image:[UIImage imageNamed:@"message-128.png"]];

#ifdef DEBUG
    
    [self registerTabWithName:@"STMSettings"
                        title:NSLocalizedString(@"SETTINGS", nil)
                        image:[UIImage imageNamed:@"settings3-128.png"]];
    
//    [self registerTabWithName:@"STMLogs"
//                        title:NSLocalizedString(@"LOGS", nil)
//                        image:[UIImage imageNamed:@"archive-128.png"]];
    
#endif

}

- (void)initAuthTab {
    self.viewControllers = self.authVCs;
}

- (void)initAllTabs {

    UIViewController *messageVC = self.tabs[@"STMMessage"];
    
    if (messageVC) {
        
        NSUInteger unreadCount = [STMObjectsController unreadMessagesCount];
        NSString *badgeValue = (unreadCount == 0) ? nil : [NSString stringWithFormat:@"%lu", (unsigned long)unreadCount];
        messageVC.tabBarItem.badgeValue = badgeValue;
        [UIApplication sharedApplication].applicationIconBadgeNumber = [badgeValue integerValue];

    }
    
    self.viewControllers = self.allTabsVCs;

}

- (void)showTabWithName:(NSString *)tabName {
    
    UIViewController *vc = (self.tabs)[tabName];
    if (vc) {
        [self setSelectedViewController:vc];
    }
    
}

- (void)showTabAtIndex:(NSUInteger)index {
    
    UIViewController *vc = self.viewControllers[index];
    if (vc) {
        [self setSelectedViewController:vc];
    }

}

- (void)currentTabBarItemDidTapped {
    
    if ([self.currentTappedVC conformsToProtocol:@protocol(STMTabBarViewController)]) {
        
        [(id <STMTabBarViewController>)self.currentTappedVC showActionSheetFromTabBarItem];
        
    }
    
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    if ([viewController isEqual:self.selectedViewController]) {
        self.currentTappedVC = viewController;
    }
    
//    NSLog(@"shouldSelect viewController.tabBarItem.title %@", viewController.tabBarItem.title);

    return YES;
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    if (self.currentTappedVC) {
        
        [self currentTabBarItemDidTapped];
        self.currentTappedVC = nil;
        
    }
    
//    NSLog(@"didSelect viewController.tabBarItem.title %@", viewController.tabBarItem.title);

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
    
    [UIView transitionFromView:fromViewController.view
                        toView:toViewController.view
                      duration:[self transitionDuration:transitionContext]
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
                        [transitionContext completeTransition:YES];
                        [toViewController.view layoutIfNeeded];
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
    
    if (alertView.tag == 1) {

        if (buttonIndex == 1) {
            
            NSLog(@"self.appDownloadUrl %@", self.appDownloadUrl);
            NSURL *updateURL = [NSURL URLWithString:self.appDownloadUrl];
//            NSURL *updateURL = [NSURL URLWithString:@"http://www.iptm.ru"];
            [[UIApplication sharedApplication] openURL:updateURL];

        } else {
            

        }
        
        self.updateAlertIsShowing = NO;
        
    }
    
}

//- (void)authControllerError:(NSNotification *)notification {
//        
//    NSString *error = [notification userInfo][@"error"];
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    alertView.tag = 0;
//    [alertView show];
//    
//}

- (void)stateChanged {
    
    [self authStateChanged];
    [self syncStateChanged];
    
}

- (void)authStateChanged {
    
    [STMAuthController authController].controllerState != STMAuthSuccess ? [self initAuthTab] : [self initAllTabs];
    
}

- (void)syncStateChanged {

    [UIApplication sharedApplication].applicationIconBadgeNumber = [STMObjectsController unreadMessagesCount];
    
}

- (void)showUnreadMessageCount {
    
    UIViewController *vc = (self.tabs)[@"STMMessages"];
    
    if (vc) {
        
        NSUInteger unreadCount = [STMObjectsController unreadMessagesCount];
        NSString *badgeValue = unreadCount == 0 ? nil : [NSString stringWithFormat:@"%lu", (unsigned long)unreadCount];
        vc.tabBarItem.badgeValue = badgeValue;
        [UIApplication sharedApplication].applicationIconBadgeNumber = [badgeValue integerValue];
        
    }

}

- (void)newAppVersionAvailable:(NSNotification *)notification {

    if (!self.updateAlertIsShowing) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSNumber *appVersion = [defaults objectForKey:@"availableVersion"];
        self.appDownloadUrl = [defaults objectForKey:@"appDownloadUrl"];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UPDATE AVAILABLE", nil)
                                                            message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"VERSION", nil), appVersion]
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                  otherButtonTitles:NSLocalizedString(@"UPDATE", nil), nil];
        
        alertView.tag = 1;
        
//        UIViewController *vc = (self.tabs)[@"STMAuthTVC"];
        UIViewController *vc = [self.authVCs lastObject];
        vc.tabBarItem.badgeValue = @"!";
        
        self.updateAlertIsShowing = YES;
        
        [alertView show];

    }

}

- (void) setDocumentReady {
    [STMClientDataController checkAppVersion];
}

#pragma mark - notifications

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(showAuthAlert)
               name:@"notAuthorized"
             object:nil];
    
//    [nc addObserver:self
//           selector:@selector(authControllerError:)
//               name:@"authControllerError"
//             object:[STMAuthController authController]];
    
    [nc addObserver:self
           selector:@selector(authStateChanged)
               name:@"authControllerStateChanged"
             object:[STMAuthController authController]];
    
    [nc addObserver:self
           selector:@selector(syncStateChanged)
               name:@"syncStatusChanged"
             object:self.session.syncer];
    
    [nc addObserver:self
           selector:@selector(showUnreadMessageCount)
               name:@"gotNewMessage"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(showUnreadMessageCount)
               name:@"messageIsRead"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(newAppVersionAvailable:)
               name:@"newAppVersionAvailable"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(newAppVersionAvailable:)
               name:@"updateButtonPressed"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(setDocumentReady)
               name:@"documentReady"
             object:nil];
    
}

- (void)removeObservers {
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notAuthorized" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - view lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
