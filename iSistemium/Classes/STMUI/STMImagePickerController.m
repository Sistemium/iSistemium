//
//  STMUIImagePickerController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMImagePickerController.h"
#import "STMConstants.h"


@interface STMImagePickerController ()

@end


@implementation STMImagePickerController

- (BOOL)shouldAutorotate {
    
    return (IPHONE && SYSTEM_VERSION >= 8.0) ? NO : [super shouldAutorotate];
        
}


#pragma mark - orientation fix

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{

    if (IPHONE) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;    
    }
    
}


#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
