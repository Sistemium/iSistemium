//
//  STMAddPartnerVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddPartnerVC.h"
#import "STMAddPartnerNC.h"
#import "STMUI.h"

@interface STMAddPartnerVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) STMAddPartnerNC *parentNC;

@end

@implementation STMAddPartnerVC

- (STMAddPartnerNC *)parentNC {
    
    if (!_parentNC) {
        
        if ([self.navigationController isKindOfClass:[STMAddPartnerNC class]]) {
            _parentNC = (STMAddPartnerNC *)self.navigationController;
        }
        
    }
    return _parentNC;
    
}

- (void)cancelButtonPressed {
    
    [self.parentNC dissmissSelf];
    
}

- (void)doneButtonPressed {
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.title = NSLocalizedString(@"ADD PARTNER", nil);
    self.nameLabel.text = NSLocalizedString(@"PARTNER NAME LABEL", nil);
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    [self.nameTextField becomeFirstResponder];
    
    STMUIBarButtonItemCancel *cancelButton = [[STMUIBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    STMUIBarButtonItemDone *doneButton = [[STMUIBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:nil];
    
    [self setToolbarItems:@[cancelButton, flexibleSpace, doneButton]];
    
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
