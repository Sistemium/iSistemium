//
//  STMScannerInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMScannerInfoTVC.h"

#import "STMBarCodeScanner.h"
#import "STMSoundController.h"


@interface STMScannerInfoTVC () <STMBarCodeScannerDelegate>

@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;

@property (nonatomic, strong) UISwitch *beepSwitch;
@property (nonatomic, strong) UISwitch *rumbleSwitch;
@property (nonatomic, strong) STMLabel *batteryLabel;

@property (nonatomic, strong) NSIndexPath *beepStatusCellIndexPath;
@property (nonatomic, strong) NSIndexPath *rumbleStatusCellIndexPath;
@property (nonatomic, strong) NSIndexPath *batteryStatusCellIndexPath;

@property (nonatomic) BOOL isRequestingScannerData;
@property (nonatomic) NSUInteger scannerDataCountdown;


@end


@implementation STMScannerInfoTVC

- (BOOL)isInActiveTab {
    return [self.tabBarController.selectedViewController isEqual:self.navigationController];
}

+ (UISwitch *)cellSwitchWithTarget:(STMScannerInfoTVC *)target {
    
    UISwitch *cellSwitch = [[UISwitch alloc] init];
    cellSwitch.enabled = NO;
    cellSwitch.on = NO;
    
    [cellSwitch addTarget:target action:@selector(cellSwitchDidSwitched:) forControlEvents:UIControlEventValueChanged];
    
    return cellSwitch;
    
}

- (UISwitch *)beepSwitch {
    
    if (!_beepSwitch) {
        _beepSwitch = [[self class] cellSwitchWithTarget:self];
    }
    return _beepSwitch;
    
}

- (UISwitch *)rumbleSwitch {
    
    if (!_rumbleSwitch) {
        _rumbleSwitch = [[self class] cellSwitchWithTarget:self];
    }
    return _rumbleSwitch;
    
}

- (void)cellSwitchDidSwitched:(id)sender {
    
    [self.iOSModeBarCodeScanner setBeepStatus:self.beepSwitch.on
                              andRumbleStatus:self.rumbleSwitch.on];
    
}

- (NSIndexPath *)beepStatusCellIndexPath {
    
    if (!_beepStatusCellIndexPath) {
        _beepStatusCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return _beepStatusCellIndexPath;
    
}

- (NSIndexPath *)rumbleStatusCellIndexPath {
    
    if (!_rumbleStatusCellIndexPath) {
        _rumbleStatusCellIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    return _rumbleStatusCellIndexPath;
    
}

- (NSIndexPath *)batteryStatusCellIndexPath {
    
    if (!_batteryStatusCellIndexPath) {
        _batteryStatusCellIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    }
    return _batteryStatusCellIndexPath;
    
}


#pragma mark - table data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.iOSModeBarCodeScanner isDeviceConnected] ? self.iOSModeBarCodeScanner.scannerName : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.iOSModeBarCodeScanner isDeviceConnected] ? 3 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.accessoryView = nil;
    
    if ([indexPath compare:self.beepStatusCellIndexPath] == NSOrderedSame) {
        
        [self.iOSModeBarCodeScanner isDeviceConnected] ? [self fillBeepStatusCell:cell] : [self fillNoScannerCell:cell];
        
    } else if ([indexPath compare:self.rumbleStatusCellIndexPath] == NSOrderedSame) {
        
        [self fillRumbleStatusCell:cell];
        
    } else if ([indexPath compare:self.batteryStatusCellIndexPath] == NSOrderedSame) {
        
        [self fillBatteryStatusCell:cell];
        
    } else {
        
        cell.textLabel.text = @(indexPath.row).stringValue;
        
    }
    
    return cell;
    
}

- (void)fillNoScannerCell:(UITableViewCell *)cell {
    cell.textLabel.text = NSLocalizedString(@"NO SCANNER AVAILABLE", nil);
}

- (void)fillBeepStatusCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = NSLocalizedString(@"SCANNER BEEP", nil);
    
    if (self.beepSwitch.enabled) {
        
        cell.accessoryView = self.beepSwitch;
        
    } else {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        cell.accessoryView = spinner;
        
    }
    
}

- (void)fillRumbleStatusCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = NSLocalizedString(@"SCANNER RUMBLE", nil);
    
    if (self.rumbleSwitch.enabled) {
        
        cell.accessoryView = self.rumbleSwitch;
        
    } else {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        cell.accessoryView = spinner;
        
    }
    
}

- (void)fillBatteryStatusCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = NSLocalizedString(@"SCANNER BATTERY", nil);
    
    if (self.batteryLabel) {
        
        cell.accessoryView = self.batteryLabel;
        
    } else {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        cell.accessoryView = spinner;
        
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

//    if (indexPath.row == 2 && [self.iOSModeBarCodeScanner isDeviceConnected] && !self.isRequestingScannerData) {
//        
//        self.scannerDataCountdown = 1;
//        [self.iOSModeBarCodeScanner getBatteryStatus];
//        
//    }
    
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
    
    [self.tableView reloadData];

}

- (void)requestScannerData {
    
    self.isRequestingScannerData = YES;
    self.scannerDataCountdown = 3;
    
    [self.iOSModeBarCodeScanner getBeepStatus];
    [self.iOSModeBarCodeScanner getRumbleStatus];
    [self.iOSModeBarCodeScanner getBatteryStatus];

}

- (void)scannerIsDisconnected {

    self.beepSwitch.enabled = NO;
    self.rumbleSwitch.enabled = NO;
    self.batteryLabel = nil;

    [self removeBarcodeImage];
    [self.tableView reloadData];

}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
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
    
    self.beepSwitch.enabled = YES;
    [self.beepSwitch setOn:isBeepEnable animated:YES];
    
    [self.tableView reloadRowsAtIndexPaths:@[self.beepStatusCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self countdownScannerData];
    
}

- (void)receiveScannerRumbleStatus:(BOOL)isRumbleEnable {
    
    self.rumbleSwitch.enabled = YES;
    [self.rumbleSwitch setOn:isRumbleEnable animated:YES];

    [self.tableView reloadRowsAtIndexPaths:@[self.rumbleStatusCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];

    [self countdownScannerData];

}

- (void)receiveBatteryLevel:(NSNumber *)batteryLevel {
    
    if (!self.batteryLabel) {
        
        self.batteryLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
        self.batteryLabel.textAlignment = NSTextAlignmentRight;
        self.batteryLabel.adjustsFontSizeToFitWidth = YES;

    }
    
    self.batteryLabel.text = [NSString stringWithFormat:@"%@%%", batteryLevel];
    self.batteryLabel.textColor = (batteryLevel.intValue <= 20) ? [UIColor redColor] : [UIColor blackColor];

    [self.tableView reloadRowsAtIndexPaths:@[self.batteryStatusCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self countdownScannerData];

}

- (void)countdownScannerData {
    
    self.scannerDataCountdown--;
    
    self.isRequestingScannerData = (self.scannerDataCountdown > 0);
    
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
    
    [super customInit];
    
    self.navigationItem.title = self.title;
        
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [self startBarcodeScanning];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([self.iOSModeBarCodeScanner isDeviceConnected] && !self.isRequestingScannerData) {
        
//        self.scannerDataCountdown = 1;
//        [self.iOSModeBarCodeScanner getBatteryStatus];
        
//        [self requestScannerData];
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
