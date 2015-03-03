//
//  STMPhotoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPhotoVC.h"

@interface STMPhotoVC () <UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deletePhotoButton;

@end

@implementation STMPhotoVC

- (void)setPhoto:(STMPhoto *)photo {
    
    if (photo != _photo) {
        _photo = photo;
    }
    
}

- (IBAction)deleteButtonPressed:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE PHOTO", nil) message:NSLocalizedString(@"R U SURE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alertView.tag = 1;
    [alertView show];
    
}

- (void)showImage {
    
    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoView.image = self.image;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewTap)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
}

- (void)photoViewTap {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoViewTap" object:self];
    
}

- (void)checkFrameOrientationForView:(UIView *)view {

    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    CGFloat x = view.frame.origin.x;
    CGFloat y = view.frame.origin.y;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        if (height > width) {
            view.frame = CGRectMake(x, y, height, width);
        }
        
    } else {
        
        if (height < width) {
            view.frame = CGRectMake(x, y, height, width);
        }
        
    }
    
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note {
    [self checkFrameOrientationForView:self.view];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (touch.view != self.view) {
        
        return NO;

    } else {
        
        return YES;
        
    }
    
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
            
        case 0:
            break;
            
        case 1:

            if (buttonIndex == 1) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deletePhoto" object:self userInfo:@{@"photo2delete": self.photo}];
                
            }

            break;
            
        default:
            break;
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    [self checkFrameOrientationForView:self.view];
    
    [self showImage];
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

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
