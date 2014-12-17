//
//  STMAddPartnerVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddPartnerVC.h"

@interface STMAddPartnerVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation STMAddPartnerVC

- (void)customInit {
    
    self.title = NSLocalizedString(@"ADD PARTNER", nil);
    self.nameLabel.text = NSLocalizedString(@"PARTNER NAME LABEL", nil);
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    [self.nameTextField becomeFirstResponder];
    
    NSLog(@"height %f, width %f", self.view.frame.size.height, self.view.frame.size.width);
    
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
