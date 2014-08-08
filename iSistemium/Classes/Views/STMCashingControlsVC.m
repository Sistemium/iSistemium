//
//  STMCashingControlsVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCashingControlsVC.h"
#import "STMConstants.h"

@interface STMCashingControlsVC ()

@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIButton *cashingButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *summLabel;
@property (weak, nonatomic) IBOutlet UITextField *debtSummTextField;
@property (weak, nonatomic) IBOutlet UILabel *remainderLabel;



@end

@implementation STMCashingControlsVC


- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        
        if (_outlet) {
            
            self.remainderLabel.text = [NSString stringWithFormat:@"%@", self.tableVC.totalSum];
            [self showControls];
            [self.controlsView endEditing:YES];
            
        }
        
    }
    
}

- (IBAction)cashingButtonPressed:(id)sender {

    [self showCashingControls];

    [self.tableVC.tableView setEditing:YES animated:YES];
    
}

- (IBAction)cancelButtonPressed:(id)sender {

    [self.tableVC.tableView setEditing:NO animated:YES];

    [self showCashingButton];
    
}

- (IBAction)doneButtonPressed:(id)sender {

    [self.tableVC.tableView setEditing:NO animated:YES];

    [self showCashingButton];

}

- (void)hideControls {
    
    self.controlsView.hidden = YES;
    
}

- (void)showControls {
    
    self.controlsView.hidden = NO;
    [self showCashingButton];
    
}


- (void)showCashingButton {
    
    self.cashingButton.hidden = NO;
    self.datePicker.hidden = YES;
    self.cancelButton.hidden = YES;
    self.doneButton.hidden = YES;
    self.summLabel.hidden = YES;
    self.remainderLabel.hidden = YES;
    self.debtSummTextField.hidden = YES;
    
}

- (void)showCashingControls {

    self.cashingButton.hidden = YES;
    self.datePicker.hidden = NO;
    self.cancelButton.hidden = NO;
    self.doneButton.hidden = NO;
    self.summLabel.hidden = NO;
    self.remainderLabel.hidden = NO;
    self.debtSummTextField.hidden = NO;

}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGFloat keyboardHeight = [self keyboardHeightFrom:[notification userInfo]];
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    [self moveTextFieldViewByDictance:keyboardHeight-tabBarHeight];
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {

    CGFloat keyboardHeight = [self keyboardHeightFrom:[notification userInfo]];
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    [self moveTextFieldViewByDictance:tabBarHeight-keyboardHeight];

}

- (CGFloat)keyboardHeightFrom:(NSDictionary *)info {
    
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardRect = [[[UIApplication sharedApplication].delegate window] convertRect:keyboardRect fromView:self.view];
    
    return keyboardRect.size.height;

}

- (void)moveTextFieldViewByDictance:(CGFloat)distance {

    const float movementDuration = 0.3f;

    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, -distance);
    [UIView commitAnimations];
    
    CGRect tableVCFrame = self.tableVC.tableView.frame;
    CGFloat newHeight = tableVCFrame.size.height - distance;

    self.tableVC.tableView.frame = CGRectMake(tableVCFrame.origin.x, tableVCFrame.origin.y, tableVCFrame.size.width, newHeight);
    
}

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self addObservers];
    
    if (!self.outlet) {
        [self hideControls];
    }
    
    [self.cashingButton setTitle:NSLocalizedString(@"CASHING", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    self.summLabel.text = @"0.00";
    self.remainderLabel.text = [NSString stringWithFormat:@"%@", self.tableVC.totalSum];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
