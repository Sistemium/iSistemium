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


#pragma mark - view lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    STMUIBarButtonItemCancel *cancelButton = [[STMUIBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:@[cancelButton, flexibleSpace]];
    
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


@end
