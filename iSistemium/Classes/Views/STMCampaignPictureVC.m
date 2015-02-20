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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@end

@implementation STMCampaignPictureVC


- (void)setPicture:(STMCampaignPicture *)picture {
    
    if (picture != _picture) {
        _picture = picture;
    }
    
}

- (void)updatePicture {
    
    self.image = [UIImage imageWithContentsOfFile:self.picture.imagePath];
    [self setupScrollView];
    
}

- (void)setupScrollView {
    
    if (self.image) {
        
        [self.spinner stopAnimating];
        
        [self.imageView removeFromSuperview];
        
        self.imageView = [[UIImageView alloc] initWithImage:self.image];
        self.scrollView.contentSize = self.imageView.frame.size;
        
        [self.scrollView addSubview:self.imageView];
        
#warning - Check [[UIScreen mainScreen] bounds/nativeBounds]
        
        UIView *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;

        CGRect scrollViewFrame =  [rootView convertRect:self.scrollView.frame fromView:nil];
        CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        
        self.scrollView.minimumZoomScale = minScale;
        self.scrollView.maximumZoomScale = 1.0f;
        self.scrollView.zoomScale = minScale;
        
    } else {
        
        [self.spinner startAnimating];
        [STMPicturesController hrefProcessingForObject:self.picture];

    }
    
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    NSLog(@"scale %f", scale);
    NSLog(@"self.scrollView.zoomScale %f", self.scrollView.zoomScale);
    
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

    [self addObservers];
    
    if (!self.image) self.image = [UIImage imageWithContentsOfFile:self.picture.imagePath];
    
    NSLog(@"self.picture.imagePath %@", self.picture.imagePath);
    NSLog(@"self.image %@",self.image);
    
    [self setupScrollView];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self removeObservers];
    
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
