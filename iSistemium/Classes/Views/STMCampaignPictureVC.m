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

@property (nonatomic, strong) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@end


@implementation STMCampaignPictureVC

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        _scrollView.backgroundColor = [UIColor whiteColor];
        
        self.view = _scrollView;
        
    }
    return _scrollView;
    
}

- (void)setPicture:(STMCampaignPicture *)picture {
    
    if (picture != _picture) {
        _picture = picture;
    }
    
}

- (void)updatePicture {
    
    [self removeObservers];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = ([paths count] > 0) ? paths[0] : nil;
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:self.picture.imagePath];
    
    self.image = [UIImage imageWithContentsOfFile:imagePath];
    [self setupScrollView];
    
}

- (void)setupScrollView {
    
    if (self.image) {
        
        [self checkFrameOrientation];
        
        [self.spinner stopAnimating];
        
        [self.imageView removeFromSuperview];
        
        self.imageView = [[UIImageView alloc] initWithImage:self.image];
        self.scrollView.contentSize = self.imageView.frame.size;
        [self.scrollView addSubview:self.imageView];
        
#warning - Check [[UIScreen mainScreen] bounds/nativeBounds]
        
        CGRect scrollViewFrame = self.scrollView.frame;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            
        } else {

//            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//                self.scrollView.frame = CGRectMake(scrollViewFrame.origin.x, scrollViewFrame.origin.y, scrollViewFrame.size.height, scrollViewFrame.size.width);
//                scrollViewFrame = self.scrollView.frame;
//            }

            
//            if (self.isViewLoaded && self.view.window) {
//
//                UIView *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
//                scrollViewFrame =  [self.view convertRect:self.scrollView.frame fromView:nil];
//            
//            NSLog(@"IsLandscape %d", UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation));
//            NSLog(@"IsLandscape %d", UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]));
//
//                if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//                    screenFrame = CGRectMake(0, 0, screenFrame.size.height, screenFrame.size.width);
//                }
//
//            } else {
//                scrollViewFrame = self.scrollView.frame;
//            }
            
        }
        
//        CGRect scrollViewFrame = self.scrollView.frame;
        
        NSLog(@"self.index %d", self.index);
//        NSLog(@"self.imageView %@", self.imageView);
        NSLog(@"h %f w %f", scrollViewFrame.size.height, scrollViewFrame.size.width);
        
        CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        
        self.scrollView.minimumZoomScale = minScale;
        self.scrollView.maximumZoomScale = 1.0f;
        self.scrollView.zoomScale = minScale;
        
        self.imageView.frame = [self centeredFrame];

    } else {
        
        [self.spinner startAnimating];
        [self addObservers];
        [STMPicturesController hrefProcessingForObject:self.picture];

    }
    
}

- (void)checkFrameOrientation {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
    } else {

        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        CGFloat x = self.view.frame.origin.x;
        CGFloat y = self.view.frame.origin.y;

        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            
            if (height > width) {
                self.scrollView.frame = CGRectMake(x, y, height, width);
            }
            
        } else {

            if (height < width) {
                self.scrollView.frame = CGRectMake(x, y, height, width);
            }

        }

    }
    
}

- (CGRect)centeredFrame {
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    
    return frameToCenter;
    
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.imageView.frame = [self centeredFrame];
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
//    if (!self.image) [self updatePicture];

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
    
//    NSLog(@"self.view %@", self.view);
//    
//    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
//
//    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//        screenFrame = CGRectMake(0, 0, screenFrame.size.height, screenFrame.size.width);
//    }
//    self.view.frame = screenFrame;
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

//    [self addObservers];
    
    if (!self.image) [self updatePicture];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
//    [self removeObservers];
    
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
