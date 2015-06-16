//
//  STMArticlePictureVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticlePictureVC.h"

#define IMAGE_PATH_KEY @"imagePath"


@interface STMArticlePictureVC ()

@property (weak, nonatomic) IBOutlet UIImageView *closeButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSMutableArray *picturesUnderObserving;


@end

@implementation STMArticlePictureVC

- (NSMutableArray *)picturesUnderObserving {
    
    if (!_picturesUnderObserving) {
        _picturesUnderObserving = [NSMutableArray array];
    }
    return _picturesUnderObserving;
    
}


- (void)closeButtonPressed {
    
    [self.pageVC dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void)setupImage {
    
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
            
            [picture addObserver:self forKeyPath:IMAGE_PATH_KEY options:NSKeyValueObservingOptionNew context:nil];
            [self.picturesUnderObserving addObject:picture];

        }
        
    } else {
        self.pictureView.image = [UIImage imageNamed:@"wine_bottle-512.png"];
    }

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [self setupImage];
    [self.picturesUnderObserving removeObject:object];
    [object removeObserver:self forKeyPath:keyPath context:context];
    
}


#pragma mark - view lifecycle

- (void)removeObservers {
    
    for (NSManagedObject *object in self.picturesUnderObserving) {
        [object removeObserver:self forKeyPath:IMAGE_PATH_KEY context:nil];
    }
    
}

- (void)customInit {
    
    if (self.article) {
        
        self.titleLabel.text = self.article.name;

        [self setupImage];

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
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self removeObservers];
    
    [super viewWillDisappear:animated];
    
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
