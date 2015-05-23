//
//  STMProfileVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 04/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMProfileVC.h"

#import "STMSessionManager.h"
#import "STMSession.h"

#import "STMLocationTracker.h"
#import "STMSyncer.h"
#import "STMEntityController.h"
#import "STMPicturesController.h"

#import "STMAuthController.h"
#import "STMRootTBC.h"

#import "STMUI.h"
#import "STMFunctions.h"

#import <Reachability/Reachability.h>


@interface STMProfileVC () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *sendDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfObjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationSystemStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationAppStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationWarningLabel;
@property (weak, nonatomic) IBOutlet UIButton *unloadedPicturesButton;

@property (weak, nonatomic) UIImageView *syncImageView;

@property (nonatomic) float totalEntityCount;
@property (nonatomic) int previousNumberOfObjects;

@property (nonatomic, strong) Reachability *internetReachability;

@property (nonatomic) BOOL downloadAlertWasShown;

@end

@implementation STMProfileVC

- (STMLocationTracker *)locationTracker {
    return [(STMSession *)[STMSessionManager sharedManager].currentSession locationTracker];
}

- (STMSyncer *)syncer {
    return [[STMSessionManager sharedManager].currentSession syncer];
}

- (void)backButtonPressed {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOGOUT", nil)
                                                        message:NSLocalizedString(@"R U SURE TO LOGOUT", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alertView.tag = 1;
    [alertView show];
    
}

- (void)syncerStatusChanged:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[STMSyncer class]]) {
        
        STMSyncer *syncer = notification.object;
        
        STMSyncerState fromState = [notification.userInfo[@"from"] intValue];
        
        if (syncer.syncerState == STMSyncerIdle) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.progressBar.hidden = YES;
                    
                });
                
            });
            
            if (!self.downloadAlertWasShown) [self showDownloadAlert];
            
        } else {
            
            self.progressBar.hidden = NO;
            self.totalEntityCount = 1;
            
        }
        
        if (fromState == STMSyncerReceiveData) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                sleep(5);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self hideNumberOfObjects];
                    
                });
                
            });
            
        }
        
    }
    
    [self updateSyncDatesLabels];
    [self updateCloudImages];
    [self updateUnloadedPicturesButton];
    
}


#pragma mark - cloud images for sync button

- (void)updateCloudImages {
    
    [self setImageForSyncImageView];
    [self setColorForSyncImageView];
    
}

- (void)setImageForSyncImageView {
    
    STMSyncer *syncer = [self syncer];
    BOOL hasObjectsToUpload = ([syncer numbersOfUnsyncedObjects] > 0);
    
    NSString *imageName;
    
    switch (syncer.syncerState) {
        case STMSyncerIdle: {
            imageName = (hasObjectsToUpload) ? @"Upload To Cloud-100" : @"Download From Cloud-100";
            break;
        }
        case STMSyncerSendData: {
            imageName = @"Upload To Cloud-100";
            break;
        }
        case STMSyncerSendDataOnce: {
            imageName = @"Upload To Cloud-100";
            break;
        }
        case STMSyncerReceiveData: {
            imageName = @"Download From Cloud-100";
            break;
        }
        default: {
            imageName = @"Download From Cloud-100";
            break;
        }
    }
    
    self.syncImageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
}

- (void)setColorForSyncImageView {
    
    [self removeGestureRecognizersFromCloudImages];
    
    STMSyncer *syncer = [self syncer];
    BOOL hasObjectsToUpload = ([syncer numbersOfUnsyncedObjects] > 0);
    UIColor *color = (hasObjectsToUpload) ? [UIColor redColor] : ACTIVE_BLUE_COLOR;
    SEL cloudTapSelector = (hasObjectsToUpload) ? @selector(uploadCloudTapped) : @selector(downloadCloudTapped);
    
    NetworkStatus networkStatus = [self.internetReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        
        color = [color colorWithAlphaComponent:0.3];
        [self.syncImageView setTintColor:color];
        
    } else {
        
        if (syncer.syncerState == STMSyncerIdle) {
            
            [self.syncImageView setTintColor:color];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:cloudTapSelector];
            [self.syncImageView addGestureRecognizer:tap];
            
        } else {
            
            [self.syncImageView setTintColor:[UIColor lightGrayColor]];
            
        }
        
    }
    
}

- (void)removeGestureRecognizersFromCloudImages {
    [self removeGestureRecognizersFrom:self.syncImageView];
}

- (void)removeGestureRecognizersFrom:(UIView *)view {
    
    for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
        [view removeGestureRecognizer:gesture];
    }
    
}

- (void)uploadCloudTapped {
    [self syncer].syncerState = STMSyncerSendDataOnce;
}

- (void)downloadCloudTapped {
    [self syncer].syncerState = STMSyncerReceiveData;
}


#pragma mark -

- (void)entitiesReceivingDidFinish {
    self.totalEntityCount = (float)[STMEntityController stcEntities].allKeys.count;
}

- (void)entityCountdownChange:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[STMSyncer class]]) {
        
        float countdownValue = [(notification.userInfo)[@"countdownValue"] floatValue];
        self.progressBar.progress = (self.totalEntityCount - countdownValue) / self.totalEntityCount;
        
    }
    
}

- (void)getBunchOfObjects:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[STMSyncer class]]) {
        
        NSNumber *numberOfObjects = notification.userInfo[@"count"];
        
        numberOfObjects = @(self.previousNumberOfObjects + numberOfObjects.intValue);
        
        NSString *pluralType = [STMFunctions pluralTypeForCount:numberOfObjects.intValue];
        NSString *numberOfObjectsString = [pluralType stringByAppendingString:@"OBJECTS"];
        
        NSString *receiveString = ([pluralType isEqualToString:@"1"]) ? NSLocalizedString(@"RECEIVE1", nil) : NSLocalizedString(@"RECEIVE", nil);
        
        self.numberOfObjectLabel.text = [NSString stringWithFormat:@"%@ %@ %@", receiveString, numberOfObjects, NSLocalizedString(numberOfObjectsString, nil)];
        
        self.previousNumberOfObjects = numberOfObjects.intValue;
        
    }
    
}

- (void)syncerDidChangeContent:(NSNotification *)notification {
    [self updateCloudImages];
}

- (void)hideNumberOfObjects {
    
    if ([[[STMSessionManager sharedManager].currentSession syncer] syncerState] != STMSyncerReceiveData) {
        
        self.previousNumberOfObjects = 0;
        self.numberOfObjectLabel.text = @"";
        
    }
    
}

- (void)showUpdateButton {
    
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UPDATE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(updateButtonPressed)];
    
    [updateButton setTintColor:[UIColor redColor]];
    
    self.navigationItem.rightBarButtonItem = updateButton;
    
}

- (void)updateButtonPressed {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateButtonPressed" object:nil];
    
}

- (void)newAppVersionAvailable:(NSNotification *)notification {
    
    //    [self showUpdateButton];
    
}

- (void)updateSyncDatesLabels {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [@"sendDate" stringByAppendingString:[STMAuthController authController].userID];
    NSString *sendDateString = [defaults objectForKey:key];
    
    key = [@"receiveDate" stringByAppendingString:[STMAuthController authController].userID];
    NSString *receiveDateString = [defaults objectForKey:key];
    
    if (sendDateString) {
        self.sendDateLabel.text = [NSLocalizedString(@"SEND DATE", nil) stringByAppendingString:sendDateString];
    } else {
        self.sendDateLabel.text = nil;
    }
    
    if (receiveDateString) {
        self.receiveDateLabel.text = [NSLocalizedString(@"RECEIVE DATE", nil) stringByAppendingString:receiveDateString];
    } else {
        self.receiveDateLabel.text = nil;
    }
    
}

- (void)setupUnloadedPicturesButton {
    
    [self.unloadedPicturesButton setTitleColor:ACTIVE_BLUE_COLOR forState:UIControlStateNormal];
    [self.unloadedPicturesButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
}

- (void)updateUnloadedPicturesButton {

    self.unloadedPicturesButton.enabled = ([self syncer].syncerState == STMSyncerIdle);
    
    NSUInteger unloadedPicturesCount = [[STMPicturesController sharedController] unloadedPicturesCount];
    
    NSString *title = @"";
    
    if (unloadedPicturesCount > 0) {
        
        NSString *pluralString = [STMFunctions pluralTypeForCount:unloadedPicturesCount];
        NSString *picturesCount = [NSString stringWithFormat:@"%@UPICTURES", pluralString];
        title = [NSString stringWithFormat:@"%lu %@ %@", (unsigned long)unloadedPicturesCount, NSLocalizedString(picturesCount, nil), NSLocalizedString(@"WAITING FOR DOWNLOAD", nil)];
        
    }
    
    [self.unloadedPicturesButton setTitle:title forState:UIControlStateNormal];
    
    UIColor *titleColor = [STMPicturesController sharedController].downloadQueue.suspended ? [UIColor redColor] : ACTIVE_BLUE_COLOR;
    [self.unloadedPicturesButton setTitleColor:titleColor forState:UIControlStateNormal];
    
}

- (void)unloadedPicturesCountDidChange {
    [self updateUnloadedPicturesButton];
}

- (IBAction)unloadedPicturesButtonPressed:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = NSLocalizedString(@"UNLOADED PICTURES", nil);
    actionSheet.delegate = self;

    if ([STMPicturesController sharedController].downloadQueue.suspended) {
    
        actionSheet.tag = 1;
        [actionSheet addButtonWithTitle:NSLocalizedString(@"DOWNLOAD NOW", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"DOWNLOAD LATER", nil)];

    } else {

        actionSheet.tag = 2;
        [actionSheet addButtonWithTitle:NSLocalizedString(@"DOWNLOAD STOP", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"CLOSE", nil)];

    }

    [actionSheet showInView:self.view];

}

- (void)checkDownloadingConditions {
    
    STMSettingsController *settingsController = [[STMSessionManager sharedManager].currentSession settingsController];
    BOOL enableDownloadViaWWAN = [[settingsController currentSettingsForGroup:@"appSettings"][@"enableDownloadViaWWAN"] boolValue];
    
    NetworkStatus networkStatus = [self.internetReachability currentReachabilityStatus];
    
#warning - don't forget to comment next line
    networkStatus = ReachableViaWWAN;
    
    if (networkStatus == ReachableViaWWAN && !enableDownloadViaWWAN) {
        
        [self showWWANAlert];
        
    } else {
        [self startPicturesDownloading];
    }

}

- (void)startPicturesDownloading {
    
    [STMPicturesController checkPhotos];
    [STMPicturesController sharedController].downloadQueue.suspended = NO;
    [self updateUnloadedPicturesButton];

}

- (void)stopPicturesDownloading {
    
    [STMPicturesController sharedController].downloadQueue.suspended = YES;
    [self updateUnloadedPicturesButton];

}

- (void)showDownloadAlert {
    
    NSUInteger unloadedPicturesCount = [[STMPicturesController sharedController] unloadedPicturesCount];
    
    if (unloadedPicturesCount > 0) {
        
        NSString *pluralString = [STMFunctions pluralTypeForCount:unloadedPicturesCount];
        NSString *picturesCount = [NSString stringWithFormat:@"%@UPICTURES", pluralString];
        NSString *title = [NSString stringWithFormat:@"%lu %@ %@. %@", (unsigned long)unloadedPicturesCount, NSLocalizedString(picturesCount, nil), NSLocalizedString(@"WAITING FOR DOWNLOAD", nil), NSLocalizedString(@"DOWNLOAD IT NOW?", nil)];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UNLOADED PICTURES", nil)
                                                        message:title
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        alert.tag = 2;
        [alert show];
        
        self.downloadAlertWasShown = YES;

    }
    
}

- (void)showWWANAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UNLOADED PICTURES", nil)
                                                    message:NSLocalizedString(@"NO WIFI MESSAGE", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                          otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    alert.tag = 3;
    [alert show];
    
}

- (void)showEnableWWANActionSheet {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = 3;
    actionSheet.title = NSLocalizedString(@"ENABLE WWAN MESSAGE", nil);
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"ENABLE WWAN ALWAYS", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"ENABLE WWAN ONCE", nil)];
    [actionSheet showInView:self.view];
    
}

- (void)enableWWANDownloading {
    
    STMSettingsController *settingsController = [[STMSessionManager sharedManager].currentSession settingsController];

    [settingsController setNewSettings:@{@"enableDownloadViaWWAN": @(YES)} forGroup:@"appSettings"];
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {

        case 1:
            if (buttonIndex == 0) {
                [self checkDownloadingConditions];
            }
            break;
            
        case 2:
            if (buttonIndex == 0) {
                [self stopPicturesDownloading];
            }
            break;

        case 3:
            if (buttonIndex == 0) {
                
                [self enableWWANDownloading];
                [self startPicturesDownloading];
                
            } else if (buttonIndex == 1) {

                [self startPicturesDownloading];

            }
            break;

        default:
            break;
    }
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
            
        case 1:
            if (buttonIndex == 1) {
                [[STMAuthController authController] logout];
            }
            break;

        case 2:
            if (buttonIndex == 1) {
                [self checkDownloadingConditions];
            }
            break;

        case 3:
            if (buttonIndex == 1) {
                [self showEnableWWANActionSheet];
            }
            break;

        default:
            break;
            
    }
    
}


#pragma mark - labels setup

- (void)setupLabels {
    
    self.nameLabel.text = [STMAuthController authController].userName;
    self.phoneNumberLabel.text = [STMAuthController authController].phoneNumber;
    self.progressBar.hidden = ([[STMSessionManager sharedManager].currentSession syncer].syncerState == STMSyncerIdle);
    
    self.locationWarningLabel.text = @"";
    
    BOOL autoStart = self.locationTracker.trackerAutoStart;
    
    (autoStart) ? [self setupLocationLabels] : [self hideLocationLabels];
    
}

- (void)hideLocationLabels {
    
    self.lastLocationLabel.text = @"";
    self.locationAppStatusLabel.text = @"";
    self.locationSystemStatusLabel.text = @"";
    self.locationWarningLabel.text = @"";
    
}

- (void)setupLocationLabels {
    
    [self setupLastLocationLabel];
    [self setupLocationSystemStatusLabel];
    [self setupLocationAppStatusLabel];
    
}

- (void)setupLastLocationLabel {
    
    NSString *lastLocationTime;
    NSString *lastLocationLabelText;
    
    
    if (self.locationTracker.lastLocation) {
        
        lastLocationTime = [[STMFunctions dateMediumTimeShortFormatter] stringFromDate:self.locationTracker.lastLocation.timestamp];
        lastLocationLabelText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LAST LOCATION", nil), lastLocationTime];
        
    } else {
        
        lastLocationLabelText = NSLocalizedString(@"NO LAST LOCATION", nil);
        
    }
    
    self.lastLocationLabel.textColor = [UIColor blackColor];
    self.lastLocationLabel.text = lastLocationLabelText;
    
}

- (void)setupLocationSystemStatusLabel {
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedAlways:
                self.locationSystemStatusLabel.textColor = [UIColor greenColor];
                self.locationSystemStatusLabel.text = NSLocalizedString(@"LOCATIONS ON", nil);
                break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                self.locationSystemStatusLabel.textColor = [UIColor brownColor];
                self.locationSystemStatusLabel.text = NSLocalizedString(@"LOCATIONS BACKGROUND OFF", nil);
                break;
                
            default:
                self.locationSystemStatusLabel.textColor = [UIColor redColor];
                self.locationSystemStatusLabel.text = NSLocalizedString(@"LOCATIONS OFF", nil);
                break;
        }
        
    } else {
        
        self.locationSystemStatusLabel.textColor = [UIColor redColor];
        self.locationSystemStatusLabel.text = NSLocalizedString(@"LOCATIONS OFF", nil);
        
    }
    
}

- (void)setupLocationAppStatusLabel {
    
    BOOL locationIsTracking = self.locationTracker.tracking;
    BOOL autoStart = self.locationTracker.trackerAutoStart;
    double startTime = self.locationTracker.trackerStartTime;
    double finishTime = self.locationTracker.trackerFinishTime;
    double currentTime = [STMFunctions currentTimeInDouble];
    
    if (autoStart && startTime && finishTime) {
        
        if (currentTime > startTime && currentTime < finishTime) {
            
            if (locationIsTracking) {
                
                NSString *finishTimeString = [[STMFunctions noDateShortTimeFormatter] stringFromDate:[STMFunctions dateFromDouble:finishTime]];
                NSString *labelText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"LOCATION IS TRACKING UNTIL", nil), finishTimeString];
                self.locationAppStatusLabel.text = labelText;
                self.locationAppStatusLabel.textColor = [UIColor blackColor];
                
            } else {
                
                self.locationAppStatusLabel.text = NSLocalizedString(@"LOCATION SHOULD BE TRACKING BUT NOT", nil);
                self.locationAppStatusLabel.textColor = [UIColor redColor];
                
            }
            
        } else {
            
            if (!locationIsTracking) {
                
                NSString *startTimeString = [[STMFunctions noDateShortTimeFormatter] stringFromDate:[STMFunctions dateFromDouble:startTime]];
                NSString *labelText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"LOCATION WILL TRACKING AT", nil), startTimeString];
                self.locationAppStatusLabel.text = labelText;
                self.locationAppStatusLabel.textColor = [UIColor blackColor];
                
            } else {
                
                self.locationAppStatusLabel.text = NSLocalizedString(@"LOCATION SHOULD NOT BE TRACKING BUT GOING ON", nil);
                self.locationAppStatusLabel.textColor = [UIColor redColor];
                
            }
            
        }
        
    } else {
        
        self.locationAppStatusLabel.text = NSLocalizedString(@"WRONG LOCATION TIMERS SETTINGS", nil);
        self.locationAppStatusLabel.textColor = [UIColor redColor];
        
    }
    
}

- (void)currentAccuracyUpdated:(NSNotification *)notification {
    
    BOOL isAccuracySufficient = [notification.userInfo[@"isAccuracySufficient"] boolValue];
    
    if (isAccuracySufficient) {
        
        self.locationWarningLabel.text = @"";
        
    } else {
        
        self.locationWarningLabel.textColor = [UIColor brownColor];
        self.locationWarningLabel.text = NSLocalizedString(@"ACCURACY IS NOT SUFFICIENT", nil);
        
    }
    
}

- (void)locationTrackerStatusChanged {
    [self performSelector:@selector(setupLocationAppStatusLabel) withObject:nil afterDelay:5];
}


#pragma mark - Reachability

- (void)startReachability {
    
    //    Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
}

- (void)reachabilityChanged:(NSNotification *)notification {
    [self updateCloudImages];
}


#pragma mark - view lifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    STMSyncer *syncer = [self syncer];
    
    [nc addObserver:self
           selector:@selector(syncerStatusChanged:)
               name:@"syncStatusChanged"
             object:syncer];
    
    [nc addObserver:self
           selector:@selector(entityCountdownChange:)
               name:@"entityCountdownChange"
             object:syncer];
    
    [nc addObserver:self
           selector:@selector(entitiesReceivingDidFinish)
               name:@"entitiesReceivingDidFinish"
             object:syncer];
    
    [nc addObserver:self
           selector:@selector(getBunchOfObjects:)
               name:@"getBunchOfObjects"
             object:syncer];
    
    [nc addObserver:self
           selector:@selector(syncerDidChangeContent:)
               name:@"syncerDidChangeContent"
             object:syncer];
    
    [nc addObserver:self
           selector:@selector(newAppVersionAvailable:)
               name:@"newAppVersionAvailable"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(setupLabels)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(setupLastLocationLabel)
               name:@"lastLocationUpdated"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(currentAccuracyUpdated:)
               name:@"currentAccuracyUpdated"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(setupLocationLabels)
               name:[NSString stringWithFormat:@"locationTimersInit"]
             object:nil];
    
    [nc addObserver:self
           selector:@selector(hideLocationLabels)
               name:[NSString stringWithFormat:@"locationTimersRelease"]
             object:nil];
    
    [nc addObserver:self
           selector:@selector(locationTrackerStatusChanged)
               name:[NSString stringWithFormat:@"locationTrackerStatusChanged"]
             object:nil];
    
    [nc addObserver:self
           selector:@selector(reachabilityChanged:)
               name:kReachabilityChangedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(unloadedPicturesCountDidChange)
               name:@"unloadedPicturesCountDidChange"
             object:[STMPicturesController sharedController]];
    
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)customInit {
    
    self.navigationItem.title = [STMFunctions currentAppVersion];
    
    self.numberOfObjectLabel.text = @"";
    
    UIImage *image = [STMFunctions resizeImage:[UIImage imageNamed:@"exit-128.png"] toSize:CGSizeMake(22, 22)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonPressed)];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    self.syncImageView = imageView;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    
    [self updateCloudImages];
    [self updateSyncDatesLabels];
    [self setupUnloadedPicturesButton];
    [self updateUnloadedPicturesButton];
    
    [self addObservers];
    [self startReachability];
        
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [self setupLabels];
    
    [super viewWillAppear:animated];
    
    if ([STMRootTBC sharedRootVC].newAppVersionAvailable) {
        [[STMRootTBC sharedRootVC] newAppVersionAvailable:nil];
    }
    
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
