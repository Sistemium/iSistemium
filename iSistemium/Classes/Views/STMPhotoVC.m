//
//  STMPhotoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPhotoVC.h"

@interface STMPhotoVC ()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@end

@implementation STMPhotoVC

- (void)setPhoto:(STMPhoto *)photo {
    
    if (photo != _photo) {
        _photo = photo;
    }
    
}

- (void)showImage {
    
    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoView.image = self.image;
//    self.photoView.image = [UIImage imageWithData:self.photo.imageResized];
//    [self.photoView setNeedsDisplay];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    //    self.title = self.picture.name;
    //    NSLog(@"picture.name %@", self.picture.name);
    //    NSLog(@"self.title %@", self.title);
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
