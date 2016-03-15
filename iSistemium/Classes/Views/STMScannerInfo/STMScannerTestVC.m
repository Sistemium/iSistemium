//
//  STMScannerTestVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 15/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMScannerTestVC.h"

#import <ScanAPI/ScanApiHelper.h>

#define SPINNER_VIEW_TAG 111


@interface STMScannerTestVC () <ScanApiHelperDelegate>

@property (weak, nonatomic) IBOutlet UILabel *deviceConnectionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryNotificationsStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet UIButton *getBatteryLevelButton;


@property (nonatomic, strong) ScanApiHelper *scanHelper;
@property (nonatomic, strong) NSTimer* scanApiConsumer;
@property (nonatomic, strong) DeviceInfo *deviceInfo;


@end

@implementation STMScannerTestVC

- (IBAction)getBatteryLevelButtonPressed:(id)sender {
    [self getBatteryStatusForDevice:self.deviceInfo];
}

- (UIView *)spinnerView {
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor lightGrayColor];
    view.alpha = 0.75;
    view.tag = SPINNER_VIEW_TAG;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = view.center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [spinner startAnimating];
    
    [view addSubview:spinner];
    
    return view;
    
}

- (void)removeSpinner {
    [[self.view viewWithTag:SPINNER_VIEW_TAG] removeFromSuperview];
}

- (void)startScanner {
    
    self.scanHelper = [[ScanApiHelper alloc] init];
    [self.scanHelper setDelegate:self];
    [self.scanHelper open];
    
    self.scanApiConsumer = [NSTimer scheduledTimerWithTimeInterval:.2
                                                            target:self
                                                          selector:@selector(onScanApiConsumerTimer:)
                                                          userInfo:nil
                                                           repeats:YES];
    
}

-(void)onScanApiConsumerTimer:(NSTimer *)timer {
    
    if (timer == self.scanApiConsumer){
        [self.scanHelper doScanApiReceive];
    }
    
}


#pragma mark - Battery Level Change Notifications

- (void)setBatteryLevelNotificationForDevice:(DeviceInfo *)deviceInfo {
    
    self.batteryNotificationsStatusLabel.text = @"Set battery notifications";
    
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    
    [[scanObj Property] setID:kSktScanPropIdNotificationsDevice];
    [[scanObj Property] setType:kSktScanPropTypeUlong];
    [[scanObj Property] setUlong:kSktScanNotificationsBatteryLevelChange];
    
    CommandContext *command = [[CommandContext alloc] initWithParam:NO
                                                            ScanObj:scanObj
                                                         ScanDevice:[deviceInfo getSktScanDevice]
                                                             Device:deviceInfo
                                                             Target:self
                                                           Response:@selector(onSetBatteryLevelNotification:)];
    
    [self.scanHelper addCommand:command];
    
}

- (void)onSetBatteryLevelNotification:(ISktScanObject *)scanObj {
    
    SKTRESULT result = [[scanObj Msg] Result];
    
    if (SKTSUCCESS(result)) {
        
        NSLog(@"setBatteryLevelNotification SUCCESS");
        
        self.batteryNotificationsStatusLabel.text = @"Set battery notifications success";
        
    } else {
        
        NSLog(@"setBatteryLevelNotification NOT SUCCESS");
        
        self.batteryNotificationsStatusLabel.text = (result == -15) ? @"Battery notifications not supported" : @"Set battery notifications not success";
        
    }
    
}


#pragma mark - getBatteryStatus

- (void)getBatteryStatusForDevice:(DeviceInfo *)deviceInfo {
    
    self.getBatteryLevelButton.enabled = NO;
    
    [self.view addSubview:[self spinnerView]];
    
    [self.scanHelper postGetBattery:deviceInfo
                             Target:self
                           Response:@selector(onGetBatteryStatus:)];
    
}

- (void)onGetBatteryStatus:(ISktScanObject *)scanObj {
    
    [self removeSpinner];
    
    unsigned long batteryStatus = [[scanObj Property] getUlong];
    
    unsigned char currentLevel = SKTBATTERY_GETCURLEVEL(batteryStatus);
    
    NSNumber *batteryLevel = [NSNumber numberWithUnsignedChar:currentLevel];
    
    NSLog(@"batteryLevel: %@%%", batteryLevel);
    
    self.batteryLevelLabel.text = [NSString stringWithFormat:@"Battery level: %@%%", batteryLevel];
    
    self.getBatteryLevelButton.enabled = YES;
    
}


#pragma mark - get version

- (void)getVersionForDevice:(DeviceInfo *)deviceInfo {
    
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    
    [[scanObj Property] setID:kSktScanPropIdVersionDevice];
    [[scanObj Property] setType:kSktScanPropTypeNone];
    
    CommandContext *command = [[CommandContext alloc] initWithParam:YES
                                                            ScanObj:scanObj
                                                         ScanDevice:[deviceInfo getSktScanDevice]
                                                             Device:deviceInfo
                                                             Target:self
                                                           Response:@selector(onGetVersion:)];
    
    [self.scanHelper addCommand:command];
    
}

- (void)onGetVersion:(ISktScanObject *)scanObj {
    
    SKTRESULT result = [[scanObj Msg] Result];
    
    if (SKTSUCCESS(result)) {
        
        NSLog(@"getVersion SUCCESS");
        
        ISktScanProperty *property = [scanObj Property];
        
        if ([property getType] == kSktScanPropTypeVersion) {
            
            NSString *version = [NSString stringWithFormat:@"%lx.%lx.%lx.%ld",
                                 [[property Version] getMajor],
                                 [[property Version] getMiddle],
                                 [[property Version] getMinor],
                                 [[property Version] getBuild]];
            
            NSLog(@"Version %@", version);
            
            self.deviceConnectionStatusLabel.text = [[self.deviceConnectionStatusLabel.text stringByAppendingString:@". Version: "] stringByAppendingString:version];
            
        }
        
        
    } else {
        
        NSLog(@"getVersion NOT SUCCESS");
        
    }
    
}


#pragma mark - ScanApiHelperDelegate

- (void)onDeviceArrival:(SKTRESULT)result device:(DeviceInfo *)deviceInfo {
    
    self.deviceConnectionStatusLabel.text = [NSString stringWithFormat:@"Scanner %@ connected", [deviceInfo getName]];
    
    self.deviceInfo = deviceInfo;
    
    [self getVersionForDevice:self.deviceInfo];
    [self setBatteryLevelNotificationForDevice:self.deviceInfo];
    [self getBatteryStatusForDevice:self.deviceInfo];
    
}

- (void)onDeviceRemoval:(DeviceInfo *)deviceRemoved {
    
    self.deviceConnectionStatusLabel.text = [NSString stringWithFormat:@"Scanner %@ disconnected", [deviceRemoved getName]];
    self.batteryLevelLabel.text = @"N/A";
    self.batteryNotificationsStatusLabel.text = @"N/A";
    self.getBatteryLevelButton.enabled = NO;
    
}



#pragma mark - view lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.getBatteryLevelButton.enabled = NO;
    
    [self startScanner];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
