//
//  STMCampaignDescriptionVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 04/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCampaignDescriptionVC.h"

@interface STMCampaignDescriptionVC ()
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation STMCampaignDescriptionVC




#pragma mark - view lifecycle

- (void)customInit {
    
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.text = self.descriptionText;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

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
