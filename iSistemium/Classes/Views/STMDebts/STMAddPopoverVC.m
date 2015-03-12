//
//  STMAddPopoverVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddPopoverVC.h"
#import "STMUI.h"

@interface STMAddPopoverVC ()

@property (nonatomic, strong) NSString *initialTextFieldText;

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
    
    [self.parentNC dismissSelf];
    
}

- (void)doneButtonPressed {
    
    [self.view endEditing:NO];
    
}

- (BOOL)textFieldIsFilled:(UITextField *)textField {
    
    NSString *textFieldString = textField.text;
    
    textFieldString = [textFieldString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return ![textFieldString isEqualToString:@""];
    
}

- (id)firstResponder {
    
    if (self.isFirstResponder) return self;
    
    for (UIView *subView in self.view.subviews) {
        if ([subView isFirstResponder]) return subView;
    }
    
    return nil;
    
}

#pragma mark - keyboard toolbar buttons

- (void)toolbarDoneButtonPressed {
    
    [self.view endEditing:NO];
    
}

- (void)toolbarCancelButtonPressed {
    
    id firstResponder = [self firstResponder];
    
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        [(UITextField *)firstResponder setText:self.initialTextFieldText];
    }
    
    [self toolbarDoneButtonPressed];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    self.initialTextFieldText = textField.text;

    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(toolbarCancelButtonPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toolbarDoneButtonPressed)];
    
    [cancelButton setTintColor:[UIColor redColor]];
    
    [toolbar setItems:@[cancelButton,flexibleSpace,doneButon] animated:YES];
    
    textField.inputAccessoryView = toolbar;
    
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [textField selectAll:nil];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}


#pragma mark - view lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    STMBarButtonItemCancel *cancelButton = [[STMBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    STMBarButtonItemDone *doneButton = [[STMBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    
    [self setToolbarItems:@[cancelButton, flexibleSpace, doneButton]];
    
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


@end
