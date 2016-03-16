//
//  STMUncashingHandOverVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/10/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMUncashingSVC.h"
#import "STMUncashingProcessController.h"

@interface STMUncashingHandOverVC : UIViewController

@property (nonatomic, strong) STMUncashingSVC *splitVC;
@property (nonatomic, strong) NSDecimalNumber *uncashingSum;
@property (nonatomic, strong) NSString *uncashingType;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) STMUncashingPlace *currentUncashingPlace;
@property (nonatomic, strong) UIImage *pictureImage;
@property (nonatomic) UIImagePickerControllerSourceType selectedSourceType;
@property (nonatomic, strong) STMImagePickerController *imagePickerController;
@property (nonatomic, strong) UIView *spinnerView;

- (void)doneButtonPressed;
- (void)dismissInfoPopover;
- (void)confirmButtonPressed;
- (void)deletePhoto;
- (void)customInit;
- (void)showInfoPopover;
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)imageSourceType;

@end
