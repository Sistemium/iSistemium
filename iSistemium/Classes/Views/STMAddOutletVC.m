//
//  STMAddOutletVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddOutletVC.h"
#import "STMPartnerController.h"
#import "STMOutletController.h"

@interface STMAddOutletVC ()

@property (weak, nonatomic) IBOutlet UILabel *partnerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;


@end


@implementation STMAddOutletVC

- (NSString *)partnerName {
    
    if (!_partnerName) {
        
        _partnerName = (self.partner) ? self.partner.name : nil;
        
    }
    
    return _partnerName;
    
}

- (void)doneButtonPressed {
    
    [super doneButtonPressed];
    
    if ([self textFieldIsFilled:self.nameTextField]) {
        
        [self.nameTextField resignFirstResponder];
        [self saveOutlet];
        
    } else {
        
        [self.nameTextField becomeFirstResponder];
        
    }

}

- (void)saveOutlet {
    
    NSLog(@"self.nameTextField.text %@", self.nameTextField.text);
    
    self.partner = (!self.partner) ? [STMPartnerController addPartnerWithName:self.partnerName] : self.partner;
    [STMOutletController addOutletWithShortName:self.nameTextField.text forPartner:self.partner];
    
    [self.parentNC dismissSelf];

}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.title = NSLocalizedString(@"ADD OUTLET", nil);
    self.partnerNameLabel.text = self.partnerName;
    self.nameTextField.delegate = self;
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    [self.nameTextField becomeFirstResponder];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


@end
