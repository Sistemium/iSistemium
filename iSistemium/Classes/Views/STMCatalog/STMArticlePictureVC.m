//
//  STMArticlePictureVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticlePictureVC.h"
#import "STMPicturesController.h"


@interface STMArticlePictureVC ()

@property (weak, nonatomic) IBOutlet UIImageView *closeButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) STMArticlePicture *picture;


@end

@implementation STMArticlePictureVC


- (void)closeButtonPressed {
    
    [self.pageVC dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void)setupImage {
    
    if (self.article.pictures.count > 0) {
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES];
        STMArticlePicture *picture = [self.article.pictures sortedArrayUsingDescriptors:@[sortDescriptor]][0];
        self.picture = picture;
        
        if (picture.imagePath) {
            
            [[self.pictureView viewWithTag:555] removeFromSuperview];
            self.pictureView.image = [UIImage imageWithContentsOfFile:[STMFunctions absolutePathForPath:picture.imagePath]];
            
            [self removeObservers];
            
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
            
            [self addObservers];
            
<<<<<<< HEAD
            NSManagedObjectID *pictureID = picture.objectID;
=======
//            picture is sended to background thread
//            you should dispatch_get_main_queue in downloadConnectionForObject: for picture manipulation
>>>>>>> iphoneDebts
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [STMPicturesController downloadConnectionForObjectID:pictureID];
            });

        }
        
    } else {
        self.pictureView.image = [UIImage imageNamed:@"wine_bottle-512.png"];
    }

}


#pragma mark - view lifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(setupImage)
               name:@"downloadPicture"
             object:self.picture];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
        
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
    
    [self addObservers];
    
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
