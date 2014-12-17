//
//  STMAddPartnerVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddPartnerVC.h"
#import "STMUI.h"

@interface STMAddPartnerVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation STMAddPartnerVC

- (void)doneButtonPressed {
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.title = NSLocalizedString(@"ADD PARTNER", nil);
    self.nameLabel.text = NSLocalizedString(@"PARTNER NAME LABEL", nil);
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    [self.nameTextField becomeFirstResponder];

    STMUIBarButtonItemDone *doneButton = [[STMUIBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:nil];

    NSMutableArray *toolBarItems = [self.toolbarItems mutableCopy];
    [toolBarItems addObject:doneButton];
    [self setToolbarItems:toolBarItems];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


@end
