//
//  STMPhotoReportVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportVC.h"

#import "STMFunctions.h"


@interface STMPhotoReportVC () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;


@end


@implementation STMPhotoReportVC


- (void)photoViewTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (touch.view != self.view) {
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    if (self.photoReport) {
        self.photoView.image = [UIImage imageWithContentsOfFile:[STMFunctions absolutePathForPath:self.photoReport.resizedImagePath]];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewTap)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

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
