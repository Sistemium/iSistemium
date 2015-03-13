//
//  STMAuthSuccessVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthSuccessVC.h"
#import "STMSessionManager.h"
#import "STMSyncer.h"
#import "STMEntityController.h"

@interface STMAuthSuccessVC () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *sendDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveDateLabel;
@property (nonatomic) float totalEntityCount;
@property (weak, nonatomic) IBOutlet UILabel *numberOfObjectLabel;
@property (nonatomic) int previousNumberOfObjects;

@end


@implementation STMAuthSuccessVC

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
                    
                });
                
            });
            
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
        
        self.numberOfObjectLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"RECEIVE", nil), numberOfObjects, NSLocalizedString(numberOfObjectsString, nil)];
        
        self.previousNumberOfObjects = numberOfObjects.intValue;
        
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
           selector:@selector(newAppVersionAvailable:)
               name:@"newAppVersionAvailable"
             object:nil];

}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)customInit {
    
    self.navigationItem.title = NSLocalizedString(@"SISTEMIUM", nil);

    self.numberOfObjectLabel.text = @"";
    
    [self updateSyncDatesLabels];
    [self addObservers];
    
    [super customInit];

}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.nameLabel.text = [STMAuthController authController].userName;
    self.phoneNumberLabel.text = [STMAuthController authController].phoneNumber;
//    self.progressBar.progress = 0.0;
    self.progressBar.hidden = ([[STMSessionManager sharedManager].currentSession syncer].syncerState == STMSyncerIdle);

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
