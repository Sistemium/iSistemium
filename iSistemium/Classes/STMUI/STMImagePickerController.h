//
//  STMUIImagePickerController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMImagePickerController : UIImagePickerController

+ (STMImagePickerController *)pickerControllerWithCameraOverlayView:(UIView *)cameraOverlayView delegate:(id <UIImagePickerControllerDelegate>)delegate sourceType:(UIImagePickerControllerSourceType)sourceType;

@end
