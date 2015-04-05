//
//  STMMessageVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMMessageVC.h"

@interface STMMessageVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;


@end


@implementation STMMessageVC

- (void)tapView {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
//    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    self.imageView.image = self.image;
    self.textView.text = self.text;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    
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
