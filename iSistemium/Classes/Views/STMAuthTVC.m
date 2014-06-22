//
//  STMAuthTableVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 21/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAuthTVC.h"
#import "STMAuthController.h"
#import "STMFunctions.h"
#import "STMRootTBC.h"

@interface STMAuthTVC () <UITextFieldDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UITableViewCell *authSendCell;
@property (nonatomic, strong) UITableViewCell *authInfoEnterCell;
@property (nonatomic, strong) UIColor *activeButtonColor;
@property (nonatomic, strong) UIButton *phoneButton;

@end

@interface STMAuthTVCell : UITableViewCell

@end

@implementation STMAuthTVCell

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
}

@end

@implementation STMAuthTVC


#pragma mark - cell creation

- (UITableViewCell *)emptyCell {

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
    return cell;

}

- (UITableViewCell *)authTitleCell {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"authTitleCell"];
    
    if ([STMAuthController authController].controllerState == STMAuthSuccess) {
        
        cell.textLabel.text = NSLocalizedString(@"SISTEMIUM", nil);

    } else {
        cell.textLabel.text = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);
    }
    
    return cell;

}

- (UITableViewCell *)authSpinnerCell {

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"authSpinnerCell"];
    
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            self.spinner = (UIActivityIndicatorView *)view;
        }
    }

    self.spinner.hidden = YES;
    
    return cell;
    
}

- (UITableViewCell *)authInfoEnterCell {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"authInfoEnterCell"];
    
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            self.inputField = (UITextField *)view;
        }
    }
    
    self.inputField.font = [UIFont systemFontOfSize:22];
    
    if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
        
        self.inputField.placeholder = @"89091234567";
        if ([STMAuthController authController].phoneNumber) {
            self.inputField.text = [STMAuthController authController].phoneNumber;
            [self textFieldDidChange:self.inputField];
        }
        
    } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
        
        self.inputField.placeholder = @"XXXX";
        self.inputField.text = nil;
        
    }
    
    self.inputField.keyboardType = UIKeyboardTypeNumberPad;
    self.inputField.borderStyle = UITextBorderStyleNone;
    self.inputField.textAlignment = NSTextAlignmentCenter;
    
    self.inputField.delegate = self;
    [self.inputField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.inputField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
    
    return cell;
    
}

- (UITableViewCell *)authSendCell {
    
    if (!_authSendCell) {
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"authSendCell"];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.text = NSLocalizedString(@"SEND", nil);
        
        self.activeButtonColor = cell.textLabel.textColor;

        cell.textLabel.textColor = [STMFunctions isCorrectPhoneNumber:self.inputField.text] ? self.activeButtonColor : [UIColor lightGrayColor];

        _authSendCell = cell;

    }
    
    return _authSendCell;
    
}

- (STMAuthTVCell *)authPhoneNumberCell {
    
    STMAuthTVCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"authPhoneNumberCell"];
    
    for (UIView *view in cell.contentView.subviews) {
        
        if ([view isKindOfClass:[UILabel class]]) {
            
            [(UILabel *)view setText:[STMAuthController authController].phoneNumber];
            
        } else if ([view isKindOfClass:[UIButton class]]) {
            
            self.phoneButton = (UIButton *)view;
            [self.phoneButton addTarget:self action:@selector(phoneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            
            if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
                
                [self.phoneButton setTitle:NSLocalizedString(@"CHANGE", nil) forState:UIControlStateNormal];
                
            } else if ([STMAuthController authController].controllerState == STMAuthSuccess) {
                
                [self.phoneButton setTitle:NSLocalizedString(@"LOGOUT", nil) forState:UIControlStateNormal];

            }
            
        }
        
    }
    
    return cell;
    
}

- (void)phoneButtonPressed {

    if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
        
        [STMAuthController authController].controllerState = STMAuthEnterPhoneNumber;
        
    } else if ([STMAuthController authController].controllerState == STMAuthSuccess) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOGOUT", nil) message:NSLocalizedString(@"R U SURE TO LOGOUT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alertView.tag = 2;
        [alertView show];
        
    }
    
}

- (UITableViewCell *)tabSelectCell {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"tabSelectCell"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = NSLocalizedString(@"AD CAMPAIGNS", nil);
    
    self.activeButtonColor = cell.textLabel.textColor;
    cell.textLabel.textColor = ([STMAuthController authController].controllerState == STMAuthSuccess) ? self.activeButtonColor : [UIColor lightGrayColor];
    
    return cell;
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
            
        case 0:
//            [self.authInfoTextField becomeFirstResponder];
            break;
            
        case 1:
//            if (buttonIndex == 1) {
//                self.changePhoneNumberButton.enabled = NO;
//                self.requestSMSCodeButton.enabled = NO;
//                [self.authController requestNewSMSCode];
//            }
            break;
            
        case 2:
            if (buttonIndex == 1) {
//                [self.changePhoneNumberButton setTitle:NSLocalizedString(@"CHANGE", nil) forState:UIControlStateNormal];
                [[STMAuthController authController] logout];
            }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.inputField) {
        
        if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
            
            if ([STMFunctions isCorrectPhoneNumber:textField.text]) {
                
                [self sendButtonPressed];
                
            }

        } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
            
            if ([STMFunctions isCorrectSMSCode:textField.text]) {
                
                [self sendButtonPressed];
                
            }

        }
        
        return NO;
        
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {

        if ([STMFunctions isCorrectPhoneNumber:textField.text]) {
            
            self.authSendCell.textLabel.textColor = self.activeButtonColor;
            
        } else {
            
            self.authSendCell.textLabel.textColor = [UIColor lightGrayColor];
            
        }

        
    } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {

        if ([STMFunctions isCorrectSMSCode:textField.text]) {
            
            self.authSendCell.textLabel.textColor = self.activeButtonColor;
            
        } else {
            
            self.authSendCell.textLabel.textColor = [UIColor lightGrayColor];
            
        }
        
    }
    
}

- (void)sendButtonPressed {
    
    self.authSendCell.textLabel.textColor = [UIColor lightGrayColor];
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
    
    if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
        
        [[STMAuthController authController] sendPhoneNumber:self.inputField.text];
        
    } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
        
        [[STMAuthController authController] sendSMSCode:self.inputField.text];
        
    }
    
}

#pragma mark - notifications

- (void)authControllerError:(NSNotification *)notification {
    
    [self.inputField resignFirstResponder];
    
    NSString *error = [[notification userInfo] objectForKey:@"error"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.tag = 0;
    [alertView show];

}

- (void)authControllerStateChanged {
    
    [self.tableView reloadData];
    
}

#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authControllerError:) name:@"authControllerError" object:[STMAuthController authController]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authControllerStateChanged) name:@"authControllerStateChanged" object:[STMAuthController authController]];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"authControllerError" object:[STMAuthController authController]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"authControllerStateChanged" object:[STMAuthController authController]];
    
}

- (void)customInit {
    
    [self addObservers];
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
                
                return 2;
                
            } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
                
                return 3;
                
            } else if ([STMAuthController authController].controllerState == STMAuthSuccess) {
                
                return 3;
                
            } else {
                
                return 0;
                
            }
            break;
            
        case 1:

            if ([STMAuthController authController].controllerState == STMAuthSuccess) {
                
                return 1;
                
            } else {
                
                return 2;
                
            }
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 1:
            
            if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
                
                return NSLocalizedString(@"ENTER PHONE NUMBER", nil);
                
            } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
                
                return NSLocalizedString(@"ENTER SMS CODE", nil);
                
            } else {
                
                return nil;
                
            }
            
            break;
            
        default:
            return nil;
            break;
            
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
        
        return [self cellForEnterPhoneLayoutAtIndexPath:indexPath];
        
    } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
        
        return [self cellForEnterSMSCodeLayoutAtIndexPath:indexPath];
        
    } else if ([STMAuthController authController].controllerState == STMAuthSuccess) {
        
        return [self cellForAuthSuccessLayoutAtIndexPath:indexPath];
        
    }
    
    return [self emptyCell];

}


- (UITableViewCell *)cellForEnterPhoneLayoutAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
            
        case 0:
            switch (indexPath.row) {
                    
                case 0:
                    return [self authTitleCell];
                    
                case 1:
                    return [self authSpinnerCell];
                    
            }
            
        case 1:
            switch (indexPath.row) {
                    
                case 0:
                    return [self authInfoEnterCell];
                    
                case 1:
                    self.authSendCell = nil;
                    return self.authSendCell;
                    
            }
            
    }
    
    return [self emptyCell];

}

- (UITableViewCell *)cellForEnterSMSCodeLayoutAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
            
        case 0:
            switch (indexPath.row) {
                    
                case 0:
                    return [self authTitleCell];
                    
                case 1:
                    return [self authSpinnerCell];
                
                case 2:
                    return [self authPhoneNumberCell];
                    
            }
            
        case 1:
            switch (indexPath.row) {
                    
                case 0:
                    return [self authInfoEnterCell];
                    
                case 1:
                    return self.authSendCell;
                    
            }
            
    }
    
    return [self emptyCell];
    
}

- (UITableViewCell *)cellForAuthSuccessLayoutAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
            
        case 0:
            switch (indexPath.row) {
                    
                case 0:
                    return [self authTitleCell];
                    
                case 1:
                    return [self authPhoneNumberCell];
                    
                case 2:
                    return [self authSpinnerCell];
                    
            }
            
        case 1:
            switch (indexPath.row) {
                    
                case 0:
                    return [self tabSelectCell];
                    
            }
            
    }
    
    return [self emptyCell];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"select cell section %d, row %d", indexPath.section, indexPath.row);
    
    NSIndexPath *sendButtonIndexPath = [self.tableView indexPathForCell:self.authSendCell];
    
    if ([sendButtonIndexPath compare:indexPath] == NSOrderedSame) {
        
        if (self.authSendCell.textLabel.textColor == self.activeButtonColor) {
            [self sendButtonPressed];
        }
        
    }
    
    if ([STMAuthController authController].controllerState == STMAuthSuccess && indexPath.section == 1) {
        
        [[STMRootTBC sharedRootVC] showTabAtIndex:indexPath.row+1];
        
    }

    return indexPath;
    
}

@end
