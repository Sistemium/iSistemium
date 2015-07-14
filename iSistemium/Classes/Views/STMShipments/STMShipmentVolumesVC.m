//
//  STMShipmentVolumesVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 14/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentVolumesVC.h"
#import "STMShipmentVolumeView.h"
#import "STMConstants.h"


@interface STMShipmentVolumesVC ()

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet STMShipmentVolumeView *doneVolumeView;
@property (weak, nonatomic) IBOutlet STMShipmentVolumeView *excessVolumeView;
@property (weak, nonatomic) IBOutlet STMShipmentVolumeView *shortageVolumeView;
@property (weak, nonatomic) IBOutlet STMShipmentVolumeView *badVolumeView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) NSArray *volumeViews;

@end


@implementation STMShipmentVolumesVC

- (NSArray *)volumeViews {
    
    if (!_volumeViews) {
        _volumeViews = @[self.doneVolumeView, self.excessVolumeView, self.shortageVolumeView, self.badVolumeView];
    }
    return _volumeViews;
    
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissSelf];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissSelf];
}

- (void)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupTitleTextView {
    
    self.titleTextView.text = [NSString stringWithFormat:@"%@ — %@", self.position.article.name, [self.position infoText]];

//    self.titleTextView.layer.borderWidth = 1.0;
//    self.titleTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.titleTextView.layer.cornerRadius = 5.0;
    self.titleTextView.layer.backgroundColor = [STM_LIGHT_LIGHT_GREY_COLOR CGColor];
    
}

- (void)initVolumeViews {
    
    for (STMShipmentVolumeView *volumeView in self.volumeViews) {
        
        [volumeView nullifyView];
        volumeView.packageRel = self.position.article.packageRel.integerValue;

        [volumeView.allCountButton setTitle:NSLocalizedString(@"ALL VOLUME BUTTON", nil) forState:UIControlStateNormal];
        [volumeView.allCountButton setTitle:@"" forState:UIControlStateDisabled];

    }

    self.doneVolumeView.volumeLimit = self.position.volume.integerValue;
    self.shortageVolumeView.volumeLimit = self.position.volume.integerValue;
    self.badVolumeView.volumeLimit = self.position.volume.integerValue;

    self.doneVolumeView.titleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"DONE VOLUME BUTTON", nil)];
    self.excessVolumeView.titleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"EXCESS VOLUME BUTTON", nil)];
    self.shortageVolumeView.titleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"SHORTAGE VOLUME BUTTON", nil)];
    self.badVolumeView.titleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"BAD VOLUME BUTTON", nil)];
    
    self.excessVolumeView.allCountButton.enabled = NO;
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationController.navigationBarHidden = YES;

    [self setupTitleTextView];
    [self initVolumeViews];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillDisappear:(BOOL)animated {

    self.navigationController.navigationBarHidden = NO;
    
    [super viewWillDisappear:animated];

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
