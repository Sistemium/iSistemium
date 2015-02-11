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
@property (nonatomic) float totalEntityCount;

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
        
        if (syncer.syncerState == STMSyncerIdle) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.progressBar.hidden = YES;
                    
                });
                
            });
            
        } else {
            
            self.progressBar.hidden = NO;
            self.totalEntityCount = (float)[STMEntityController stcEntities].allKeys.count;
            
        }
                
    }
    
}

- (void)entityCountdownChange:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[STMSyncer class]]) {
        
//        float totalCount = (float)[STMEntityController stcEntities].allKeys.count;
        float countdownValue = [(notification.userInfo)[@"countdownValue"] floatValue];
        
        self.progressBar.progress = (self.totalEntityCount - countdownValue) / self.totalEntityCount;
        
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

    [nc addObserver:self
           selector:@selector(syncerStatusChanged:)
               name:@"syncStatusChanged"
             object:[[STMSessionManager sharedManager].currentSession syncer]];
    
    [nc addObserver:self
           selector:@selector(entityCountdownChange:)
               name:@"entityCountdownChange"
             object:[[STMSessionManager sharedManager].currentSession syncer]];

}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)customInit {
    
    self.navigationItem.title = NSLocalizedString(@"SISTEMIUM", nil);
    [self addObservers];
    
    [super customInit];

}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.nameLabel.text = [STMAuthController authController].userName;
    self.phoneNumberLabel.text = [STMAuthController authController].phoneNumber;
    self.progressBar.progress = 0.0;
    self.progressBar.hidden = YES;

    [super viewWillAppear:animated];
    
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
