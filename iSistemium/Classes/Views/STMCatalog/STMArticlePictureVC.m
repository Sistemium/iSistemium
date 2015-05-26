//
//  STMArticlePictureVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticlePictureVC.h"

@interface STMArticlePictureVC ()

@property (weak, nonatomic) IBOutlet UIImageView *closeButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;



@end

@implementation STMArticlePictureVC

- (void)closeButtonPressed {
    
    [self.pageVC dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    if (self.article) {
        
        self.titleLabel.text = self.article.name;

        if (self.article.pictures.count > 0) {
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES];
            STMArticlePicture *picture = [self.article.pictures sortedArrayUsingDescriptors:@[sortDescriptor]][0];
            
            if (picture.imagePath) {
                
                [[self.pictureView viewWithTag:555] removeFromSuperview];
                self.pictureView.image = [UIImage imageWithContentsOfFile:[STMFunctions absolutePathForPath:picture.imagePath]];
                
            } else {
                
                UIView *view = [[UIView alloc] initWithFrame:self.pictureView.bounds];
                view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                view.backgroundColor = [UIColor whiteColor];
                view.alpha = 0.75;
                view.tag = 555;
                
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                spinner.center = view.center;
                spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                [spinner startAnimating];
                
                [view addSubview:spinner];
                
                [self.pictureView addSubview:view];
                
            }
            
        } else {
            self.pictureView.image = [UIImage imageNamed:@"wine_bottle-512.png"];
        }

    }
    
    self.closeButtonView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonPressed)];
    [self.closeButtonView addGestureRecognizer:tap];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
//    [self.view setNeedsLayout];
//    [self.view layoutIfNeeded];

//    [self.view setNeedsDisplay];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
