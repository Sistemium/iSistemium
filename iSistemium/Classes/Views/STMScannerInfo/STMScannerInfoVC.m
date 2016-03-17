//
//  STMScannerInfoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMScannerInfoVC.h"

#import "STMUI.h"
#import "STMBarCodeScanner.h"
#import "STMSoundController.h"


@interface STMScannerInfoVC () <STMBarCodeScannerDelegate>

@property (weak, nonatomic) IBOutlet STMLabel *scannerStatusLabel;
@property (weak, nonatomic) IBOutlet STMLabel *beepStatusLabel;
@property (weak, nonatomic) IBOutlet UISwitch *beepStatusSwitch;
@property (weak, nonatomic) IBOutlet STMLabel *rumbleStatusLabel;
@property (weak, nonatomic) IBOutlet UISwitch *rumbleStatusSwitch;
@property (weak, nonatomic) IBOutlet STMLabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet STMLabel *batteryLevel;
@property (weak, nonatomic) IBOutlet STMLabel *lastScannedBarcodeLabel;
@property (weak, nonatomic) IBOutlet STMLabel *lastScannedBarcode;
@property (weak, nonatomic) IBOutlet UIButton *reloadDataButton;

@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;


@end


@implementation STMScannerInfoVC

- (IBAction)beepStatusSwitchChanged:(id)sender {
}

- (IBAction)rumbleStatusSwitchChanged:(id)sender {
}

- (IBAction)reloadDataButtonPressed:(id)sender {
}


#pragma mark - barcode scanning

- (void)startBarcodeScanning {
    [self startIOSModeScanner];
}

- (void)startIOSModeScanner {
    
    self.iOSModeBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerIOSMode];
    self.iOSModeBarCodeScanner.delegate = self;
    [self.iOSModeBarCodeScanner startScan];
    
    if ([self.iOSModeBarCodeScanner isDeviceConnected]) {
        [self scannerIsConnected];
    }
    
}

- (void)stopBarcodeScanning {
    [self stopIOSModeScanner];
}

- (void)stopIOSModeScanner {
    
    [self.iOSModeBarCodeScanner stopScan];
    self.iOSModeBarCodeScanner = nil;
    
    [self scannerIsDisconnected];
    
}

- (void)scannerIsConnected {
    
    [self addBarcodeImage];
    [self requestScannerData];
    
}

- (void)requestScannerData {
    
    [self.iOSModeBarCodeScanner getBeepStatus];
    [self.iOSModeBarCodeScanner getRumbleStatus];
    [self.iOSModeBarCodeScanner getBatteryStatus];
    
}

- (void)scannerIsDisconnected {
    
    self.beepStatusSwitch.enabled = NO;
    self.beepStatusSwitch.on = NO;
    self.rumbleStatusSwitch.enabled = NO;
    self.rumbleStatusSwitch.on = NO;
    self.reloadDataButton.enabled = NO;

    self.batteryLevel.text = nil;
    self.lastScannedBarcode.text = nil;

    [self removeBarcodeImage];

}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCodeScan:(STMBarCodeScan *)barCodeScan withType:(STMBarCodeScannedType)type {
    
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type {
    
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error {
    
}

- (void)deviceArrivalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE ARRIVAL", nil)];
        
        [self scannerIsConnected];
        
    }
    
}

- (void)deviceRemovalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE REMOVAL", nil)];
        
        [self scannerIsDisconnected];
        
    }
    
}

- (void)receiveScannerBeepStatus:(BOOL)isBeepEnable {
    
    self.beepStatusSwitch.enabled = YES;
    [self.beepStatusSwitch setOn:isBeepEnable animated:YES];
    
}

- (void)receiveScannerRumbleStatus:(BOOL)isRumbleEnable {
    
    self.rumbleStatusSwitch.enabled = YES;
    [self.rumbleStatusSwitch setOn:isRumbleEnable animated:YES];
    
}

- (void)receiveBatteryLevel:(NSNumber *)batteryLevel {

    self.batteryLevel.text = [NSString stringWithFormat:@"%@%%", batteryLevel];
    self.batteryLevel.textColor = (batteryLevel.intValue <= 20) ? [UIColor redColor] : [UIColor blackColor];
    
}


#pragma mark - barcode image

- (void)addBarcodeImage {
    
    UIImage *image = [STMFunctions resizeImage:[UIImage imageNamed:@"barcode.png"] toSize:CGSizeMake(25, 25)];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
}

- (void)removeBarcodeImage {
    self.navigationItem.titleView = nil;
}


#pragma mark - view lifecycle

- (void)customInit {

    self.scannerStatusLabel.text = NSLocalizedString(@"NO SCANNER AVAILABLE", nil);
    self.beepStatusLabel.text = NSLocalizedString(@"SCANNER BEEP", nil);
    self.rumbleStatusLabel.text = NSLocalizedString(@"SCANNER RUMBLE", nil);
    self.batteryLevelLabel.text = NSLocalizedString(@"SCANNER BATTERY", nil);
    self.batteryLevel.text = nil;
    self.lastScannedBarcodeLabel.text = NSLocalizedString(@"LAST SCANNED BARCODE", nil);
    self.lastScannedBarcode.text = nil;

    self.beepStatusSwitch.enabled = NO;
    self.beepStatusSwitch.on = NO;
    self.rumbleStatusSwitch.enabled = NO;
    self.rumbleStatusSwitch.on = NO;
    
    [self.reloadDataButton setTitle:NSLocalizedString(@"RELOAD SCANNER DATA", nil) forState:UIControlStateNormal];
    self.reloadDataButton.enabled = NO;
    
    [self startBarcodeScanning];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
