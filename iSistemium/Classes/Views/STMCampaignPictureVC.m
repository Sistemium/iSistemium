//
//  STMCampaignPictureVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignPictureVC.h"

@interface STMCampaignPictureVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIImage *image;

@end

@implementation STMCampaignPictureVC


- (void)setPicture:(STMCampaignPicture *)picture {
    
    if (picture != _picture) {
        _picture = picture;
    }
    
}

- (void)showImage {
    
    if (!self.image) {
        
        [self.spinner startAnimating];
        
    } else {

        [self.picture removeObserver:self forKeyPath:@"resizedImagePath"];
        [self.spinner stopAnimating];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = self.image;

    }

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    self.image = [UIImage imageWithContentsOfFile:self.picture.resizedImagePath];
    [self showImage];

    [object removeObserver:self forKeyPath:@"resizedImagePath" context:nil];
    
}

#pragma mark - view lifecycle

- (void)customInit {

    [self.picture addObserver:self forKeyPath:@"resizedImagePath" options:NSKeyValueObservingOptionNew context:nil];
    self.image = [UIImage imageWithContentsOfFile:self.picture.resizedImagePath];
    [self showImage];
    
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
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
