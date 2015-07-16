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
#import "STMShippingProcessController.h"

#define MAX_VOLUME_LIMIT 10000


@interface STMShipmentVolumesVC () <UIAlertViewDelegate>

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
    
    if (self.doneVolumeView.volume + self.shortageVolumeView.volume + self.excessVolumeView.volume + self.badVolumeView.volume > 0) {
        
        NSString *checkingInfo = [[STMShippingProcessController sharedInstance] checkingInfoForPosition:self.position
                                                                                         withDoneVolume:self.doneVolumeView.volume
                                                                                         shortageVolume:self.shortageVolumeView.volume
                                                                                           excessVolume:self.excessVolumeView.volume
                                                                                              badVolume:self.badVolumeView.volume];
        
        if (!checkingInfo) {
            
            [self shippingPositionAndDismiss];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:checkingInfo
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            alert.tag = 111;
            [alert show];
            
        }
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EMPTY POSITION VOLUMES TITLE", nil)
                                                        message:NSLocalizedString(@"EMPTY POSITION VOLUMES MESSAGE", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];

    }
    
}

- (void)shippingPositionAndDismiss {

    [[STMShippingProcessController sharedInstance] shippingPosition:self.position
                                                     withDoneVolume:self.doneVolumeView.volume
                                                     shortageVolume:self.shortageVolumeView.volume
                                                       excessVolume:self.excessVolumeView.volume
                                                          badVolume:self.badVolumeView.volume];
    [self dismissSelf];

}

- (void)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 111:
            
            switch (buttonIndex) {
                case 1:
                    [self shippingPositionAndDismiss];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
}

#pragma mark - views

- (void)setupTitleTextView {
    
    UIFont *font = self.titleTextView.font;
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.position.article.name attributes:attributes];
    [attributedText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n" attributes:attributes]];
    
    font = [UIFont boldSystemFontOfSize:font.pointSize];
    attributes = @{NSFontAttributeName:font};
    [attributedText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[self.position volumeText] attributes:attributes]];
    
    self.titleTextView.attributedText = attributedText;
    
//    self.titleTextView.text = [NSString stringWithFormat:@"%@ — %@", self.position.article.name, [self.position volumeText]];

//    self.titleTextView.layer.borderWidth = 1.0;
//    self.titleTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    self.titleTextView.layer.cornerRadius = 5.0;
//    self.titleTextView.layer.backgroundColor = [STM_LIGHT_LIGHT_GREY_COLOR CGColor];
    
}

- (void)initVolumeViews {
    
    for (STMShipmentVolumeView *volumeView in self.volumeViews) {
        
        [volumeView nullifyView];
        
        volumeView.packageRel = self.position.article.packageRel.integerValue;
        volumeView.volumeLimit = self.position.volume.integerValue;

        [volumeView.allCountButton setTitle:NSLocalizedString(@"ALL VOLUME BUTTON", nil) forState:UIControlStateNormal];
        [volumeView.allCountButton setTitle:@"" forState:UIControlStateDisabled];

    }

    self.excessVolumeView.volumeLimit = MAX_VOLUME_LIMIT;
    self.excessVolumeView.allCountButton.enabled = NO;
    
    self.doneVolumeView.volume = self.position.doneVolume.integerValue;
    self.excessVolumeView.volume = self.position.excessVolume.integerValue;
    self.shortageVolumeView.volume = self.position.shortageVolume.integerValue;
    self.badVolumeView.volume = self.position.badVolume.integerValue;

    self.doneVolumeView.titleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"DONE VOLUME LABEL", nil)];
    self.excessVolumeView.titleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"EXCESS VOLUME LABEL", nil)];
    self.shortageVolumeView.titleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"SHORTAGE VOLUME LABEL", nil)];
    self.badVolumeView.titleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"BAD VOLUME LABEL", nil)];
    
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

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.titleTextView flashScrollIndicators];

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
