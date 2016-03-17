//
//  STMScannerInfoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMScannerInfoVC.h"

#import "STMUI.h"


@interface STMScannerInfoVC ()

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



@end


@implementation STMScannerInfoVC

- (IBAction)beepStatusSwitchChanged:(id)sender {
}

- (IBAction)rumbleStatusSwitchChanged:(id)sender {
}

- (IBAction)reloadDataButtonPressed:(id)sender {
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
