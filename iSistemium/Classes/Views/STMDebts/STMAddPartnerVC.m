//
//  STMAddPartnerVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddPartnerVC.h"
#import "STMAddOutletVC.h"
#import "STMUI.h"

@interface STMAddPartnerVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation STMAddPartnerVC

- (void)doneButtonPressed {
    
    [super doneButtonPressed];
    
    if ([self textFieldIsFilled:self.nameTextField]) {
        [self performSegueWithIdentifier:@"showAddOutlet" sender:self];
    } else {
        [self.nameTextField becomeFirstResponder];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showAddOutlet"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMAddOutletVC class]]) {
            
            STMAddOutletVC *addOutletVC = (STMAddOutletVC *)segue.destinationViewController;
            addOutletVC.partnerName = self.nameTextField.text;
            
        }
        
    }
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.title = NSLocalizedString(@"ADD PARTNER", nil);
    self.nameLabel.text = NSLocalizedString(@"PARTNER NAME LABEL", nil);

    [self.navigationItem setTitle:NSLocalizedString(@"PARTNER", nil)];

    self.nameTextField.delegate = self;
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.nameTextField becomeFirstResponder];    
    
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


@end
