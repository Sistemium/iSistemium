//
//  STMAuthSuccessVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthSuccessVC.h"
#import "STMSessionManager.h"
#import "STMSession.h"
#import "STMLocationTracker.h"
#import "STMSyncer.h"
#import "STMEntityController.h"

@interface STMAuthSuccessVC () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *sendDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfObjectLabel;
@property (weak, nonatomic) IBOutlet UIImageView *uploadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (weak, nonatomic) IBOutlet UILabel *lastLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationSystemStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationAppStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationWarningLabel;

@property (nonatomic) float totalEntityCount;
@property (nonatomic) int previousNumberOfObjects;

@property (nonatomic, strong) STMLocationTracker *locationTracker;


@end


@implementation STMAuthSuccessVC

- (STMLocationTracker *)locationTracker {
    return [(STMSession *)[STMSessionManager sharedManager].currentSession locationTracker];
}

- (void)backButtonPressed {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOGOUT", nil) message:NSLocalizedString(@"R U SURE TO LOGOUT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alertView.tag = 0;
    alertView.delegate = self;
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
                    
                    [self.uploadImageView setTintColor:ACTIVE_BLUE_COLOR];
                    [self.downloadImageView setTintColor:ACTIVE_BLUE_COLOR];

                });
                
            });
            
        } else {
            
            self.progressBar.hidden = NO;
            self.totalEntityCount = 1;

            [self.uploadImageView setTintColor:[UIColor lightGrayColor]];
            [self.downloadImageView setTintColor:[UIColor lightGrayColor]];

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
    
}

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
    
    if ([notification.object isKindOfClass:[STMSyncer class]]) {
        
        STMSyncer *syncer = (STMSyncer *)notification.object;
        
        NSUInteger numberOfUnsyncedObjects = [syncer numbersOfUnsyncedObjects];
        
    }

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
    
    [self showUpdateButton];
    
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
            
        case 0:
            if (buttonIndex == 1) {
                [[STMAuthController authController] logout];
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

#pragma mark - view lifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    STMSyncer *syncer = [[STMSessionManager sharedManager].currentSession syncer];

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
    
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)customInit {
    
    self.navigationItem.title = [STMFunctions currentAppVersion];

    self.uploadImageView.image = [self.uploadImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.downloadImageView.image = [self.downloadImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    
    self.numberOfObjectLabel.text = @"";
    
    [self updateSyncDatesLabels];
    [self addObservers];
    
    [super customInit];

}

- (void)viewDidLoad {
    [super viewDidLoad];
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
