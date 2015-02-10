//
//  STMAuthNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthNC.h"
#import "STMAuthPhoneVC.h"
#import "STMAuthSMSVC.h"
#import "STMAuthSuccessVC.h"

@interface STMAuthNC () <UINavigationControllerDelegate>

@property (nonatomic, strong) STMAuthPhoneVC *phoneVC;
@property (nonatomic, strong) STMAuthSMSVC *smsVC;
@property (nonatomic, strong) STMAuthSuccessVC *successVC;

@end

@implementation STMAuthNC

+ (STMAuthNC *)sharedAuthNC {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedAuthNC = nil;
    
    dispatch_once(&pred, ^{
        _sharedAuthNC = [[self alloc] init];
    });
    
    return _sharedAuthNC;

}

- (STMAuthPhoneVC *)phoneVC {
    
    if (!_phoneVC) {
        _phoneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"authPhoneVC"];
    }
    return _phoneVC;
    
}

- (STMAuthSMSVC *)smsVC {
    
    if (!_smsVC) {
        _smsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"authSMSVC"];
    }
    return _smsVC;
    
}

- (STMAuthSuccessVC *)successVC {
    
    if (!_successVC) {
        _successVC = [self.storyboard instantiateViewControllerWithIdentifier:@"authSuccessVC"];
    }
    return _successVC;
    
}

- (void)authControllerStateChanged {
    
    switch ([STMAuthController authController].controllerState) {
            
        case STMAuthEnterPhoneNumber:
            [self setViewControllers:@[self.phoneVC] animated:YES];
            
            break;
            
        case STMAuthEnterSMSCode:
            [self setViewControllers:@[self.smsVC] animated:YES];
            
            break;
            
        case STMAuthSuccess:
            [self setViewControllers:@[self.successVC] animated:YES];
            
            break;
            
        default:
            break;
            
    }
    
}


#pragma marl - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    NSLog(@"willShowViewController: %@", viewController);
//    NSLog(@"navigationController %@", navigationController.viewControllers);
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    NSLog(@"didShowViewController: %@", viewController);
//    NSLog(@"navigationController %@", navigationController.viewControllers);
}


#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authControllerStateChanged) 
                                                 name:@"authControllerStateChanged"
                                               object:[STMAuthController authController]];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)setupViewControllers {

    [self authControllerStateChanged];
    
}

- (void)customInit {
    
    self.delegate = self;
    [self addObservers];
    [self setupViewControllers];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}


@end
