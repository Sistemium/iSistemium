//
//  STMRootVC.m
//  TestRootVC
//
//  Created by Maxim Grigoriev on 20/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMRootTBC.h"

#import "STMUI.h"

#import "STMSessionManager.h"
#import "STMSession.h"

#import "STMFunctions.h"
#import "STMConstants.h"

#import "STMObjectsController.h"
#import "STMTabBarViewController.h"
#import "STMClientDataController.h"
#import "STMAuthController.h"
#import "STMMessageController.h"
#import "STMCampaignController.h"

@interface STMRootTBC () <UITabBarControllerDelegate, /*UIViewControllerAnimatedTransitioning, */UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *tabs;
@property (nonatomic, strong) UIAlertView *authAlert;
@property (nonatomic, strong) UIAlertView *timeoutAlert;
@property (nonatomic, strong) STMSession *session;

@property (nonatomic, strong) NSString *appDownloadUrl;
@property (nonatomic) BOOL updateAlertIsShowing;

@property (nonatomic, strong) UIViewController *currentTappedVC;

@property (nonatomic, strong) NSMutableArray *allTabsVCs;
@property (nonatomic, strong) NSMutableArray *authVCs;

@property (nonatomic, strong) STMSpinnerView *spinnerView;

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

- (STMSpinnerView *)spinnerView {
    
    if (!_spinnerView) {
        _spinnerView = [STMSpinnerView spinnerViewWithFrame:self.view.bounds];
    }
    return _spinnerView;
    
}

- (UIViewController *)topmostVC {
    return [self topmostVCForVC:self];
}

- (UIViewController *)topmostVCForVC:(UIViewController *)vc {
    
    UIViewController *topVC = vc.presentedViewController;
    if (topVC) {
        return [self topmostVCForVC:topVC];
    } else {
        return vc;
    }
    
}

- (STMSession *)session {
    return [STMSessionManager sharedManager].currentSession;
}

- (BOOL)newAppVersionAvailable {
    
    if ([self.session.status isEqualToString:@"running"]) {

        [STMClientDataController checkAppVersion];
    
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

//    [self prepareTabs];
    
    self.tabBar.hidden = NO;
    
//    [self stateChanged];
    [self initAuthTab];
    
}

- (void)prepareTabs {

    [self nullifyTabs];
    
    if (IPAD) {
        [self setupIPadTabs];
    } else if (IPHONE) {
        [self setupIPhoneTabs];
    }

}

- (void)nullifyTabs {
    
    self.storyboardTitles = nil;
    self.allTabsVCs = nil;
    self.tabs = nil;
    self.authVCs = nil;

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

- (void)registerTabWithStoryboardParameters:(NSDictionary *)parameters {
    
    NSString *name = parameters[@"name"];
    NSString *title = parameters[@"title"];
    NSString *imageName = parameters[@"imageName"];

    if (name) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"storyboardc"];
        
        if (path) {
            
            title = (title) ? title : name;
            [self.storyboardTitles addObject:title];
            
            STMStoryboard *storyboard = [STMStoryboard storyboardWithName:name bundle:nil];
            storyboard.parameters = parameters;
            
            UIViewController *vc = [storyboard instantiateInitialViewController];
            vc.title = title;
            vc.tabBarItem.image = [STMFunctions resizeImage:[UIImage imageNamed:imageName] toSize:CGSizeMake(30, 30)];
            
            [self.allTabsVCs addObject:vc];
            
            (self.tabs)[name] = vc;
            
            if ([name hasPrefix:@"STMAuth"]) {
                [self.authVCs addObject:vc];
            }
            
        } else {
            
            NSString *logMessage = [NSString stringWithFormat:@"Storyboard %@ not found in app's bundle", name];
            [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"error"];
            
        }
        
    }

}

- (void)setupIPadTabs {
    
    NSLog(@"device is iPad");
    
    NSArray *stcTabs = [STMAuthController authController].stcTabs;

    [self setupTabs:stcTabs];
    
}

- (void)setupIPhoneTabs {
    
    NSLog(@"device is iPhone");

    NSArray *iPhoneStcTabs = [self iPhoneStcTabsForStcTabs:[STMAuthController authController].stcTabs];
    
    [self setupTabs:iPhoneStcTabs];
    
}

- (NSArray *)iPhoneStcTabsForStcTabs:(NSArray *)stcTabs {

    NSString *iPhoneStoryboards = [[NSBundle mainBundle] pathForResource:@"iphoneTabs" ofType:@"json"];
    NSData *iPhoneTabsData = [NSData dataWithContentsOfFile:iPhoneStoryboards];
    
    NSMutableDictionary *iPhoneTabsJSON = [NSJSONSerialization JSONObjectWithData:iPhoneTabsData options:NSJSONReadingMutableContainers error:nil];
    NSArray *nullKeys = [iPhoneTabsJSON allKeysForObject:[NSNull null]];
    [iPhoneTabsJSON removeObjectsForKeys:nullKeys];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name IN %@", iPhoneTabsJSON.allKeys];
    stcTabs = [stcTabs filteredArrayUsingPredicate:predicate];
    
    NSMutableArray *iPhoneStcTabs = [NSMutableArray array];
    
    for (NSDictionary *stcTab in stcTabs) {
        
        NSMutableDictionary *tab = [stcTab mutableCopy];
        tab[@"name"] = iPhoneTabsJSON[stcTab[@"name"]];
        [iPhoneStcTabs addObject:tab];
        
    }
    
    return iPhoneStcTabs;

}

- (void)setupTabs:(NSArray *)stcTabs {
    
    if ([STMAuthController authController].controllerState != STMAuthSuccess) {
        
        [self registerTabWithStoryboardParameters:@{@"name": @"STMAuth",
                                                    @"title": NSLocalizedString(@"AUTHORIZATION", nil),
                                                    @"imageName": @"password2-128.png"}];
        
    } else {
        
        for (NSDictionary *parameters in stcTabs) {
            
            NSString *minBuild = parameters[@"minBuild"];
            NSString *maxBuild = parameters[@"maxBuild"];
            BOOL isDebug = [parameters[@"ifdef"] isEqualToString:@"DEBUG"];
            
            if (minBuild && ([BUILD_VERSION integerValue] < [minBuild integerValue])) continue;
            if (maxBuild && ([BUILD_VERSION integerValue] > [maxBuild integerValue])) continue;
            
            if (isDebug) {
#ifdef DEBUG
                [self registerTabWithStoryboardParameters:parameters];
#endif
            } else {
                
                [self registerTabWithStoryboardParameters:parameters];
                
            }
            
        }
        
    }

}

- (void)initAuthTab {

    NSString *logMessage = @"init auth tab";
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"debug"];

    [self prepareTabs];
    
    self.viewControllers = self.authVCs;
    
}

- (void)initAllTabs {
    
    NSString *logMessage = @"init all tabs";
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"debug"];

    [self prepareTabs];
    
    [self showUnreadMessageCount];
    [self showUnreadCampaignCount];
    
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
        [self currentTabBarItemDidTapped];
        self.currentTappedVC = nil;

        return NO;
        
    } else {
    
        return YES;

    }
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
//    if (self.currentTappedVC) {
//        
//        [self currentTabBarItemDidTapped];
//        self.currentTappedVC = nil;
//        
//    }

}

/*  *** animation transition for tab switching ***

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
*/


#pragma mark - alertView & delegate

- (UIAlertView *)authAlert {
    
    if (!_authAlert) {
        
        _authAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                message:NSLocalizedString(@"U R NOT AUTH", nil)
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
        
    }
    return _authAlert;
    
}

- (void)showAuthAlert {
    
    if (!self.authAlert.visible && [STMAuthController authController].controllerState != STMAuthEnterPhoneNumber) {
        [self.authAlert show];
        [self showTabWithName:@"STMAuthTVC"];
    }
    
}

- (UIAlertView *)timeoutAlert {
    
    if (!_timeoutAlert) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                            message:NSLocalizedString(@"TIMEOUT ERROR", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        
        alertView.tag = 2;

        _timeoutAlert = alertView;
        
    }
    return _timeoutAlert;
    
}

- (void)showTimeoutAlert {
    
    if (!self.timeoutAlert.visible) {
        [self.timeoutAlert show];
    }
    
}

- (void)checkTimeoutAlert {
    
    if (self.timeoutAlert.visible) {
        if (self.session.syncer.syncerState != STMSyncerIdle) [self.timeoutAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {

        if (buttonIndex == 1) {
            
            NSLog(@"self.appDownloadUrl %@", self.appDownloadUrl);
            NSURL *updateURL = [NSURL URLWithString:self.appDownloadUrl];
            [[UIApplication sharedApplication] openURL:updateURL];

        } else {
            

        }
        
        self.updateAlertIsShowing = NO;
        
    } else if (alertView.tag == 2) {

        if (buttonIndex == 1) [self.session.syncer setSyncerState:self.session.syncer.timeoutErrorSyncerState];
    
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
    
//    [STMAuthController authController].controllerState != STMAuthSuccess ? [self initAuthTab] : [self initAllTabs];
    
    if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
        
        [self initAuthTab];
        
    } else if ([STMAuthController authController].controllerState == STMAuthSuccess) {

        [self.view addSubview:self.spinnerView];
        
    }
    
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    
    if ([self.session.status isEqualToString:@"running"]) {
        [self initAllTabs];
    }
    
}


- (void)syncStateChanged {

    NSInteger badgeNumber = ([self.session.status isEqualToString:@"running"]) ? [STMMessageController unreadMessagesCount] : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;

    [self checkTimeoutAlert];
    
}

- (void)syncerInitSuccessfully {
    
    [self removeSpinner];
    
}

- (void)syncerTimeoutError {
    
#ifdef DEBUG

    [self showTimeoutAlert];
    
#endif

}

- (void)showUnreadMessageCount {
    
    UIViewController *vc = (self.tabs)[@"STMMessages"];
    
    if (vc) {
        
        NSUInteger unreadCount = [STMMessageController unreadMessagesCount];
        NSString *badgeValue = unreadCount == 0 ? nil : [NSString stringWithFormat:@"%lu", (unsigned long)unreadCount];
        vc.tabBarItem.badgeValue = badgeValue;
        [UIApplication sharedApplication].applicationIconBadgeNumber = [badgeValue integerValue];
        
    }

}

- (void)showUnreadCampaignCount {
    
    UIViewController *vc = (self.tabs)[@"STMCampaigns"];
    
    if (vc) {
        
        NSUInteger unreadCount = [STMCampaignController numberOfUnreadCampaign];
        NSString *badgeValue = unreadCount == 0 ? nil : [NSString stringWithFormat:@"%lu", (unsigned long)unreadCount];
        vc.tabBarItem.badgeValue = badgeValue;
//        [UIApplication sharedApplication].applicationIconBadgeNumber = [badgeValue integerValue];
        
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

- (void)setDocumentReady {
    
    [STMClientDataController checkAppVersion];
    [STMMessageController showMessageVCsIfNeeded];
    
}

- (void)documentNotReady {

    [self removeSpinner];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:NSLocalizedString(@"DOCUMENT_ERROR", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    
}

- (void)removeSpinner {
    
    [self.spinnerView removeFromSuperview];
    self.spinnerView = nil;

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
           selector:@selector(syncerInitSuccessfully)
               name:@"Syncer init successfully"
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
           selector:@selector(showUnreadCampaignCount)
               name:@"gotNewCampaignPicture"
             object:nil];

    [nc addObserver:self
           selector:@selector(showUnreadCampaignCount)
               name:@"gotNewCampaign"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(showUnreadCampaignCount)
               name:@"campaignPictureIsRead"
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
    
    [nc addObserver:self
           selector:@selector(documentNotReady)
               name:@"documentNotReady"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(syncerTimeoutError)
               name:@"NSURLErrorTimedOut"
             object:self.session.syncer];
    
    [nc addObserver:self
           selector:@selector(sessionStatusChanged:)
               name:@"sessionStatusChanged"
             object:self.session];

}

- (void)removeObservers {
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
