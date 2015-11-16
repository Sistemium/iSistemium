//
//  STMPhotoReportVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportVC.h"

#import "STMFunctions.h"


@interface STMPhotoReportVC () <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;


@end


@implementation STMPhotoReportVC

- (IBAction)deleteButtonPressed:(id)sender {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE PHOTO", nil) message:NSLocalizedString(@"R U SURE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alertView.tag = 1;
        [alertView show];
        
    }];
    
}

- (void)photoViewTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
            
        case 1:
            
            if (buttonIndex == 1) {
                
                [self.parentVC deletePhotoReport:self.photoReport];
                [self dismissViewControllerAnimated:YES completion:nil];

            }
            
            break;
            
        default:
            break;
    }

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
