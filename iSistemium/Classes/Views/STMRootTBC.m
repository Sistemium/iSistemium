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

@interface STMRootTBC () <UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *tabs;
@property (nonatomic, strong) UIAlertView *authAlert;
@property (nonatomic, strong) UIAlertView *timeoutAlert;
@property (nonatomic, strong) STMSession *session;

@property (nonatomic, strong) NSString *appDownloadUrl;
@property (nonatomic) BOOL updateAlertIsShowing;

@property (nonatomic, strong) UIViewController *currentTappedVC;

@property (nonatomic, strong) NSMutableDictionary *allTabsVCs;
@property (nonatomic, strong) NSMutableArray *currentTabsVCs;
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
        _spinnerView = [STMSpinnerView spinnerViewWithFrame:self.view.frame];
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
    self.currentTabsVCs = nil;
    self.allTabsVCs = nil;
    self.tabs = nil;
    self.authVCs = nil;

}

- (NSMutableDictionary *)allTabsVCs {
    
    if (!_allTabsVCs) {
        _allTabsVCs = [NSMutableDictionary dictionary];
    }
    return _allTabsVCs;
    
}

- (NSMutableArray *)currentTabsVCs {
    
    if (!_currentTabsVCs) {
        _currentTabsVCs = [NSMutableArray array];
    }
    return _currentTabsVCs;
    
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

- (NSArray *)siblingsForViewController:(UIViewController *)vc {
    
    NSArray *siblings = nil;
    
    for (NSArray *tabs in self.allTabsVCs.allValues) {
        
        if ([tabs containsObject:vc] && tabs.count > 1) {
            siblings = [tabs mutableCopy];
        }
        
    }
    
    return siblings;
    
}

- (void)replaceVC:(UIViewController *)currentVC withVC:(UIViewController *)vc {
    
    NSUInteger index = [self.currentTabsVCs indexOfObject:currentVC];
    
    [self.currentTabsVCs replaceObjectAtIndex:index withObject:vc];
    
    [self showTabs];
    
}

- (void)registerTabWithStoryboardParameters:(NSDictionary *)parameters atIndex:(NSUInteger)index{
    
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
            
            if (!self.allTabsVCs[@(index)]) {
            
                self.allTabsVCs[@(index)] = @[vc];
                [self.currentTabsVCs addObject:vc];

            } else {
                
                NSMutableArray *tabs = [self.allTabsVCs[@(index)] mutableCopy];
                [tabs addObject:vc];
                self.allTabsVCs[@(index)] = tabs;
                
            }
            
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
                                                    @"imageName": @"password2-128.png"} atIndex:0];
        
    } else {
        
        stcTabs = [self testStcTabs];
        
//        NSLog(@"stcTabs %@", stcTabs);
        
        for (id tabsItem in stcTabs) {
            
            NSUInteger index = [stcTabs indexOfObject:tabsItem];
            
            if ([tabsItem isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *parameters = (NSDictionary *)tabsItem;
            
                NSString *minBuild = parameters[@"minBuild"];
                NSString *maxBuild = parameters[@"maxBuild"];
                BOOL isDebug = [parameters[@"ifdef"] isEqualToString:@"DEBUG"];
                
                if (minBuild && ([BUILD_VERSION integerValue] < [minBuild integerValue])) continue;
                if (maxBuild && ([BUILD_VERSION integerValue] > [maxBuild integerValue])) continue;
                
                if (isDebug) {
#ifdef DEBUG
                    [self registerTabWithStoryboardParameters:parameters atIndex:index];
#endif
                } else {
                    
                    [self registerTabWithStoryboardParameters:parameters atIndex:index];
                    
                }

            } else if ([tabsItem isKindOfClass:[NSArray class]]) {
                
                for (NSDictionary *parameters in tabsItem) {
                    
                    NSString *minBuild = parameters[@"minBuild"];
                    NSString *maxBuild = parameters[@"maxBuild"];
                    BOOL isDebug = [parameters[@"ifdef"] isEqualToString:@"DEBUG"];
                    
                    if (minBuild && ([BUILD_VERSION integerValue] < [minBuild integerValue])) continue;
                    if (maxBuild && ([BUILD_VERSION integerValue] > [maxBuild integerValue])) continue;
                    
                    if (isDebug) {
#ifdef DEBUG
                        [self registerTabWithStoryboardParameters:parameters atIndex:index];
#endif
                    } else {
                        
                        [self registerTabWithStoryboardParameters:parameters atIndex:index];
                        
                    }
                    
                }
                
            }
            
        }
        
    }

}

- (NSArray *)testStcTabs {
    
    return @[
                @{
                    @"imageName": @"checked_user-128.png",
                    @"name": @"STMProfile",
                    @"title": @"Profile"
                },
                @{
                    @"imageName": @"christmas_gift-128.png",
                    @"name": @"STMCampaigns",
                    @"title": @"Campaign"
                },
                @{
                    @"imageName": @"cash_receiving-128.png",
                    @"name": @"STMDebts",
                    @"title": @"Debts"
                },
                @{
                    @"imageName": @"banknotes-128.png",
                    @"name": @"STMUncashing",
                    @"title": @"Uncashing"
                },
//                {
//                    imageName = "message-128.png";
//                    name = STMMessages;
//                    title = "\U0421\U043e\U043e\U0431\U0449\U0435\U043d\U0438\U044f";
//                },
//                {
//                    imageName = "Dossier Folder-100.png";
//                    minBuild = 70;
//                    name = STMCatalog;
//                    title = "\U041a\U0430\U0442\U0430\U043b\U043e\U0433";
//                },
//                {
//                    imageName = "bill-128.png";
//                    minBuild = 70;
//                    name = STMOrders;
//                    title = "\U0417\U0430\U043a\U0430\U0437\U044b";
//                },
//                {
//                    authCheck = "localStorage.getItem('r50.accessToken')";
//                    imageName = "purchase_order-128.png";
//                    name = STMWebView;
//                    title = "\U041f\U0440\U043e\U0447\U0435\U0435";
//                    url = "https://sis.bis100.ru/r50/beta/tp/";
//                },
                @[
                    @{
                        @"ifdef": @"DEBUG",
                        @"imageName": @"settings3-128.png",
                        @"name": @"STMSettings",
                        @"title": @"Settings"
                        },
                    @{
                        @"ifdef": @"DEBUG",
                        @"imageName": @"archive-128.png",
                        @"name": @"STMLogs",
                        @"title": @"Logs"
                        }
                ]
                ];
    
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
    
    [self showTabs];
    
}

- (void)showTabs {
    
    self.viewControllers = self.currentTabsVCs;
    
    NSArray *tabBarControlsArray = [self tabBarControlsArray];
    
    for (UIViewController *vc in self.viewControllers) {
        
        if ([vc conformsToProtocol:@protocol(STMTabBarViewController)]) {
            
            NSUInteger siblingsCount = [self siblingsForViewController:vc].count;
            
            if (siblingsCount > 1 || [(id <STMTabBarViewController>)vc shouldShowOwnActionSheet]) {
                
                NSUInteger index = [self.viewControllers indexOfObject:vc];
                UIControl *tabBarControl = tabBarControlsArray[index];
                [self addMoreMarkLabelToControl:tabBarControl];
                
            }
            
        }
        
    }
    
}

- (NSArray *)tabBarControlsArray {
    
    NSMutableArray *tabBarControlsArray = [NSMutableArray array];
    
    for (UIView *view in self.tabBar.subviews) {
        
        if ([view isKindOfClass:[UIControl class]]) {
            
            UIControl *controlView = (UIControl *)view;
            [tabBarControlsArray addObject:controlView];
            
        }
        
    }
    
    NSComparator frameComparator = ^NSComparisonResult(id obj1, id obj2) {
        
        CGRect frame1 = [(UIView *)obj1 frame];
        CGRect frame2 = [(UIView *)obj2 frame];
        
        if (frame1.origin.x > frame2.origin.x) return (NSComparisonResult)NSOrderedDescending;
        
        if (frame1.origin.x < frame2.origin.x) return (NSComparisonResult)NSOrderedAscending;
        
        return (NSComparisonResult)NSOrderedSame;
        
    };
    
    [tabBarControlsArray sortUsingComparator:frameComparator];

    return tabBarControlsArray;
    
}

- (void)addMoreMarkLabelToControl:(UIControl *)controlView {
    
    UILabel *moreMarkLabel=[[UILabel alloc]init];
    moreMarkLabel.font = [UIFont systemFontOfSize:14];
    moreMarkLabel.text = @"▲";
    moreMarkLabel.textAlignment=NSTextAlignmentCenter;
    moreMarkLabel.frame=CGRectMake(4, 2, 16, 16);
    moreMarkLabel.textColor=[UIColor lightGrayColor];
    [controlView addSubview:moreMarkLabel];

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
    
//    NSString *logMessage = [NSString stringWithFormat:@"shouldSelect tab %@", viewController.tabBarItem.title];
//    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"debug"];

    return YES;
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    if (self.currentTappedVC) {
        
        [self currentTabBarItemDidTapped];
        self.currentTappedVC = nil;
        
    }
    
//    NSString *logMessage = [NSString stringWithFormat:@"didSelect tab %@", viewController.tabBarItem.title];
//    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"debug"];

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

    [UIApplication sharedApplication].applicationIconBadgeNumber = [STMMessageController unreadMessagesCount];
    [self checkTimeoutAlert];
    
}

- (void)syncerInitSuccessfully {
    [self.spinnerView removeFromSuperview];
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
    
    [self.spinnerView removeFromSuperview];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:NSLocalizedString(@"DOCUMENT_ERROR", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    
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
