//
//  STMNavigationController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMNavigationController.h"
#import "STMAuthController.h"

@interface STMNavigationController () <UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *authAlert;

@end

@implementation STMNavigationController


#pragma mark - alertView & delegate

- (UIAlertView *)authAlert {
    
    if (!_authAlert) {
        
        _authAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"U R NOT AUTH", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
    }
    
    return _authAlert;
    
}

- (void)showAuthAlert {

    if (!self.authAlert.visible && [STMAuthController authController].controllerState != STMAuthEnterPhoneNumber) {
        [self.authAlert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self popToRootViewControllerAnimated:YES];
    
}

#pragma mark - notifications

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthAlert) name:@"notAuthorized" object:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notAuthorized" object:nil];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self addObservers];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
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
