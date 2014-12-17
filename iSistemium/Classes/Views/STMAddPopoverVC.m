//
//  STMAddPopoverVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddPopoverVC.h"
#import "STMAddPopoverNC.h"
#import "STMUI.h"

@interface STMAddPopoverVC ()

@property (nonatomic, strong) STMAddPopoverNC *parentNC;

@end


@implementation STMAddPopoverVC

- (STMAddPopoverNC *)parentNC {
    
    if (!_parentNC) {
        
        if ([self.navigationController isKindOfClass:[STMAddPopoverNC class]]) {
            _parentNC = (STMAddPopoverNC *)self.navigationController;
        }
        
    }
    return _parentNC;
    
}

- (void)cancelButtonPressed {
    
    [self.parentNC dissmissSelf];
    
}

- (void)doneButtonPressed {
    
    [self.view endEditing:NO];
    
}

- (BOOL)textFieldIsFilled:(UITextField *)textField {
    
    NSString *textFieldString = textField.text;
    
    textFieldString = [textFieldString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return ![textFieldString isEqualToString:@""];
    
}

#pragma mark - view lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    STMUIBarButtonItemCancel *cancelButton = [[STMUIBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    STMUIBarButtonItemDone *doneButton = [[STMUIBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    
    [self setToolbarItems:@[cancelButton, flexibleSpace, doneButton]];
    
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


@end
