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


@end


@implementation STMShipmentVolumesVC

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

#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationController.navigationBarHidden = YES;

    [self setupTitleTextView];
    
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
