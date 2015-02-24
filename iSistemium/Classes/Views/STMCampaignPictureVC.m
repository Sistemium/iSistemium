//
//  STMCampaignPictureVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignPictureVC.h"
#import "STMPicturesController.h"

@interface STMCampaignPictureVC () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIView *spinnerView;

@end


@implementation STMCampaignPictureVC

- (UIView *)spinnerView {
    
    if (!_spinnerView) {
        
        UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
        [self checkFrameOrientationForView:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor whiteColor];
        view.alpha = 0.75;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = view.center;
        spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [spinner startAnimating];
        [view addSubview:spinner];
        
        _spinnerView = view;
        
    }
    
    return _spinnerView;
    
}

- (void)setPicture:(STMCampaignPicture *)picture {
    
    if (picture != _picture) {
        _picture = picture;
    }
    
}

- (void)updatePicture {
    
    [self removeObservers];

//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = ([paths count] > 0) ? paths[0] : nil;
//    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:self.picture.imagePath];
//    
//    self.image = [UIImage imageWithContentsOfFile:imagePath];

    self.image = [UIImage imageWithContentsOfFile:self.picture.imagePath];
    [self setupScrollView];
    
}

- (void)setupScrollView {
    
    if (self.image) {
        
        [self checkFrameOrientationForView:self.scrollView];
        
        [self.spinnerView removeFromSuperview];
        [self.imageView removeFromSuperview];
        
        self.imageView = [[UIImageView alloc] initWithImage:self.image];
        self.scrollView.contentSize = self.imageView.frame.size;
        [self.scrollView addSubview:self.imageView];
        
        CGRect scrollViewFrame = self.scrollView.frame;
        
        CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        
        self.scrollView.minimumZoomScale = (minScale < 1.0f) ? minScale : 1.0f;
        self.scrollView.maximumZoomScale = 1.0f;
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        
        [self centerContent];

    } else {
        
        [self.view addSubview:self.spinnerView];
        [self addObservers];
        [STMPicturesController hrefProcessingForObject:self.picture];

    }
    
}

- (void)checkFrameOrientationForView:(UIView *)view {
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
    
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

//    }
    
}

- (void)centerContent {
    
    CGFloat top = 0, left = 0;
    CGSize contentSize = self.scrollView.contentSize;
    CGSize boundsSize = self.scrollView.bounds.size;
    
    if (contentSize.width < boundsSize.width) {
        left = (boundsSize.width - contentSize.width) * 0.5f;
    }
    if (contentSize.height < boundsSize.height) {
        top = (boundsSize.height - contentSize.height) * 0.5f;
    }
    
    self.scrollView.contentInset = UIEdgeInsetsMake(top, left, top, left);
    
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note {
    
    [self checkFrameOrientationForView:self.spinnerView];
    
    CGFloat scale = self.scrollView.zoomScale;

    BOOL viewWasScaled = NO;
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        viewWasScaled = YES;
    }
    
    [self setupScrollView];
    
    if (viewWasScaled && scale > self.scrollView.minimumZoomScale) {
        self.scrollView.zoomScale = scale;
    }
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {

}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerContent];
}

#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePicture) name:@"campaignPictureUpdate" object:self.picture];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"campaignPictureUpdate" object:self.picture];
    
}

- (void)customInit {
    
    self.scrollView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
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

- (void)viewWillLayoutSubviews {
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.image) [self updatePicture];
    
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
