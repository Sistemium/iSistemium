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
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    [self.nameTextField becomeFirstResponder];

//    STMUIBarButtonItemDone *doneButton = [[STMUIBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:nil];
//
//    NSMutableArray *toolBarItems = [self.toolbarItems mutableCopy];
//    [toolBarItems addObject:doneButton];
//    [self setToolbarItems:toolBarItems];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


@end
