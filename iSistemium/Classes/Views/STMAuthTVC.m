//
//  STMAuthTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 20/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAuthTVC.h"
#import "STMAuthController.h"
#import "STMFunctions.h"

#define PHONE_PLACEHOLDER @"89091234567"

@interface STMAuthTVC () <UITextFieldDelegate>

@end

@implementation STMAuthTVC


#pragma mark - cell create

- (UITableViewCell *)defaultCell {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"defaultCell"];
    
    cell.textLabel.text = @"text";
    cell.detailTextLabel.text = @"detailedText";
    
    return cell;

}

- (UITableViewCell *)titleCell {
    
    static NSString *cellIdentifier = @"titleCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = NSLocalizedString(@"ENTER TO SISTEMIUM", nil);
    cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;

    return cell;
    
}

- (UITableViewCell *)phoneNumberCell {

    static NSString *cellIdentifier = @"phoneNumberCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    UITextField *textField = [self phoneNumberTextField];
    
    [cell.contentView addSubview:textField];
    [cell.contentView addSubview:[self phoneNumberButton]];
    
    [self textFieldDidChange:textField];
    
    return cell;

}

- (UITextField *)phoneNumberTextField {
    
    UIFont *font = [UIFont systemFontOfSize:22];
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect frame;
    frame.size = [PHONE_PLACEHOLDER sizeWithAttributes:attributes];
    frame.origin = CGPointMake(160, 10);
    
    UITextField *phoneField = [[UITextField alloc] initWithFrame:frame];
    phoneField.font = font;
    phoneField.placeholder = PHONE_PLACEHOLDER;
    phoneField.delegate = self;
    phoneField.keyboardType = UIKeyboardTypeNumberPad;
    [phoneField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [phoneField becomeFirstResponder];
    
    return phoneField;
    
}

- (UIButton *)phoneNumberButton {
    
    NSString *title = NSLocalizedString(@"SEND", nil);

    UIFont *font = [UIFont systemFontOfSize:22];
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect frame;
    frame.size = [title sizeWithAttributes:attributes];
    frame.origin = CGPointMake(320, 10);

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(phoneNumberButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
    
}

- (void)phoneNumberButtonPressed {
    
    if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
        NSLog(@"send phone number");
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField.placeholder isEqualToString:PHONE_PLACEHOLDER]) {
        
        if ([STMFunctions isCorrectPhoneNumber:textField.text]) {
            
            [self phoneNumberButtonPressed];
            
        }
        
        return NO;
        
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    UIView *superview = textField.superview.superview.superview;
    UITableViewCell *cell = [superview isKindOfClass:[UITableViewCell class]] ? (UITableViewCell *)superview : nil;

    UIButton *button;
    
    for (UIView *view in cell.contentView.subviews) {
        
        if ([view isKindOfClass:[UIButton class]]) {
            button = (UIButton *)view;
        }
        
    }
    
    if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
        
        button.enabled = [STMFunctions isCorrectPhoneNumber:textField.text];
        
    } else if ([STMAuthController authController].controllerState == STMAuthEnterSMSCode) {
        
        button.enabled = [STMFunctions isCorrectSMSCode:textField.text];
        
    }
    
}


#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
            return 1;
            break;
            
        case 1:
            
            if ([STMAuthController authController].controllerState == STMAuthEnterPhoneNumber) {
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
        case 0:
            return nil;
            break;
            
        case 1:
            return NSLocalizedString(@"ENTER PHONE NUMBER", nil);
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    return nil;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
            
        case 0:
            
            return [self titleCell];
            break;
            
        case 1:
            
            return [self phoneNumberCell];
            break;
            
        default:

            return [self defaultCell];
            break;
            
    }
    
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
