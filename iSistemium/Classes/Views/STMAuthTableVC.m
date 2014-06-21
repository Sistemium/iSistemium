//
//  STMAuthTableVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 21/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAuthTableVC.h"
#import "STMAuthController.h"
#import "STMFunctions.h"

@interface STMAuthTableVC () <UITextFieldDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UITextField *phoneNumberField;
@property (nonatomic, strong) UITableViewCell *authSendCell;
@property (nonatomic, strong) UIColor *activeButtonColor;

@end

@implementation STMAuthTableVC


#pragma mark - cell creation

- (UITableViewCell *)emptyCell {

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
    return cell;

}

- (UITableViewCell *)authTitleCell {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"authTitleCell"];
    
    cell.textLabel.text = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);
    
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

- (UITableViewCell *)authPhoneEnterCell {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"authPhoneEnterCell"];
    
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            self.phoneNumberField = (UITextField *)view;
        }
    }
    
    self.phoneNumberField.font = [UIFont systemFontOfSize:22];
    
    self.phoneNumberField.placeholder = @"89091234567";
    self.phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumberField.borderStyle = UITextBorderStyleNone;
    self.phoneNumberField.textAlignment = NSTextAlignmentCenter;

    
    self.phoneNumberField.delegate = self;
    [self.phoneNumberField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.phoneNumberField becomeFirstResponder];
    
    return cell;
    
}

- (UITableViewCell *)authSendCell {
    
    if (!_authSendCell) {
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"authSendCell"];
        
        cell.textLabel.text = NSLocalizedString(@"SEND", nil);
        
        self.activeButtonColor = cell.textLabel.textColor;
        cell.textLabel.textColor = [STMFunctions isCorrectPhoneNumber:self.phoneNumberField.text] ? self.activeButtonColor : [UIColor lightGrayColor];

        _authSendCell = cell;

    }
    
    return _authSendCell;
    
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.phoneNumberField) {
        
        if ([STMFunctions isCorrectPhoneNumber:textField.text]) {
            
            
        }
        
        return NO;
        
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {

        self.authSendCell.textLabel.textColor = [STMFunctions isCorrectPhoneNumber:textField.text] ? self.activeButtonColor : [UIColor lightGrayColor];
        
    } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
        
        
    }
    
}


#pragma mark - notifications

- (void)authControllerError:(NSNotification *)notification {
    
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
            return 2;
            break;
            
        default:
            return 2;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 1:
            return NSLocalizedString(@"ENTER PHONE NUMBER", nil);
            break;
            
        default:
            return nil;
            break;
            
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
                    
                    return [self authPhoneEnterCell];
                    
                case 1:
                    
                    return self.authSendCell;

            }
            
    }
    
    return [self emptyCell];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
