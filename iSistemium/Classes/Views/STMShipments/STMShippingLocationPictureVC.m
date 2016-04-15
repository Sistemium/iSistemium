//
//  STMShippingLocationPictureVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShippingLocationPictureVC.h"
#import "STMPicturesController.h"

@interface STMShippingLocationPictureVC () <UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deletePhotoButton;



@end

@implementation STMShippingLocationPictureVC

- (STMSpinnerView *)spinnerView {
    
    if (!_spinnerView) {
        _spinnerView = [STMSpinnerView spinnerViewWithFrame:self.view.frame indicatorStyle:UIActivityIndicatorViewStyleGray backgroundColor: [UIColor clearColor] alfa:1.0];
    }
    return _spinnerView;
    
}

- (void)setPhoto:(STMShippingLocationPicture *)photo {
    
    if (photo != _photo) {
        _photo = photo;
    }
    
}

- (IBAction)deleteButtonPressed:(id)sender {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE PHOTO", nil)
                                                            message:NSLocalizedString(@"R U SURE", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alertView.tag = 1;
        [alertView show];
        
    }];
    
}

- (void)showImage {
    self.deletePhotoButton.enabled = true;
    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoView.image = [UIImage imageWithContentsOfFile:[STMFunctions absolutePathForPath:self.photo.resizedImagePath]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewTap)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    [self.spinnerView removeFromSuperview];
    [self removeObservers];
    
}

- (void)addSpinner {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewTap)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    self.deletePhotoButton.enabled = false;
    [self.view addSubview:self.spinnerView];
    [self addObservers];
    NSManagedObjectID *pictureID = self.photo.objectID;
    [STMPicturesController downloadConnectionForObjectID:pictureID];
    
}

- (void)photoViewTap {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoViewTap" object:self];
    
}

- (void)checkFrameOrientationForView:(UIView *)view {
    
    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    CGFloat x = view.frame.origin.x;
    CGFloat y = view.frame.origin.y;
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        
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

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(showImage)
               name:@"downloadPicture"
             object:self.photo];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self checkFrameOrientationForView:self.view];
    
    if (self.photo.imageThumbnail) [self showImage];
    else{
        [self addSpinner];
    }
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
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
