//
//  STMUncashingHandOverVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/10/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingHandOverVC.h"
#import "STMCashing.h"
#import "STMUncashingInfoVC.h"
#import "STMUncashingPhotoVC.h"
#import "STMConstants.h"
#import "STMUI.h"
#import "STMUncashingPlaceController.h"
#import "STMFunctions.h"
#import "STMObjectsController.h"
#import "STMImagePickerController.h"

@interface STMUncashingHandOverVC () <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingSumLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelector;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *uncashingPlaceButton;
@property (weak, nonatomic) IBOutlet UILabel *uncashingPlaceLabel;

@property (nonatomic, strong) NSString *initialCommentText;
@property (nonatomic) BOOL viaBankOffice;
@property (nonatomic) BOOL viaCashDesk;
@property (nonatomic, strong) UIView *cameraOverlayView;

@property (nonatomic, strong) UIPopoverController *uncashingInfoPopover;
@property (nonatomic) BOOL infoPopoverIsVisible;

@property (nonatomic, strong) NSArray *uncashingPlaces;

@property (nonatomic, strong) STMUncashingPlace *defaultUncashingPlace;

@property (nonatomic, strong) NSMutableArray *availableSourceTypes;


@end


@implementation STMUncashingHandOverVC

//@synthesize uncashingType = _uncashingType;

- (STMImagePickerController *)imagePickerController {
    
    if (!_imagePickerController) {
        
        STMImagePickerController *imagePickerController = [[STMImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        imagePickerController.sourceType = self.selectedSourceType;
        
        if (imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            imagePickerController.showsCameraControls = NO;
            
            [[NSBundle mainBundle] loadNibNamed:@"STMCameraOverlayView" owner:self options:nil];
            self.cameraOverlayView.backgroundColor = [UIColor clearColor];
            self.cameraOverlayView.autoresizesSubviews = YES;
            self.cameraOverlayView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            if (SYSTEM_VERSION >= 8.0) {
                
                UIView *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
                CGRect originalFrame = [[UIScreen mainScreen] bounds];
                CGRect screenFrame = [rootView convertRect:originalFrame fromView:nil];
                self.cameraOverlayView.frame = screenFrame;
                
            }
            
            imagePickerController.cameraOverlayView = self.cameraOverlayView;
            
        }
        
        _imagePickerController = imagePickerController;
        
    }
    
    return _imagePickerController;
    
}

- (NSMutableArray *)availableSourceTypes {
    
    if (!_availableSourceTypes) {
        _availableSourceTypes = [NSMutableArray array];
    }
    return _availableSourceTypes;
    
}

- (UIView *)spinnerView {
    
    if (!_spinnerView) {
        
        UIView *view = [[UIView alloc] initWithFrame:self.splitViewController.view.frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor grayColor];
        view.alpha = 0.75;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = view.center;
        spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [spinner startAnimating];
        [view addSubview:spinner];
        
        _spinnerView = view;
        
    }
    
    return _spinnerView;
    
}

- (UIPopoverController *)uncashingInfoPopover {
    
    if (!_uncashingInfoPopover) {
        
        STMUncashingInfoVC *uncashingInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"uncashingInfoPopover"];
        uncashingInfoVC.parentVC = self;
        uncashingInfoVC.sum = self.uncashingSum;
        uncashingInfoVC.type = self.uncashingType;
        uncashingInfoVC.comment = self.commentText;
        uncashingInfoVC.image = self.pictureImage;
        uncashingInfoVC.place = self.currentUncashingPlace;
        
        _uncashingInfoPopover = [[UIPopoverController alloc] initWithContentViewController:uncashingInfoVC];
        _uncashingInfoPopover.delegate = self;
        
    }
    
    return _uncashingInfoPopover;
    
}

- (void)setViaBankOffice:(BOOL)viaBankOffice {
    
    if (_viaBankOffice != viaBankOffice) {

        if (viaBankOffice) {
            
            if (self.pictureImage) {
                
                [self showImageThumbnail];
                self.viaCashDesk = NO;
                
            } else {
            
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ATTENTION", nil) message:NSLocalizedString(@"BANK CHECK PHOTO", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                    alert.tag = 2;
                    [alert show];
                    
                }];

            }
            
            self.uncashingType = BANK_OFFICE_TYPE;
            
        }
        
        _viaBankOffice = viaBankOffice;
        
    }
    
}

- (void)setViaCashDesk:(BOOL)viaCashDesk {
    
    if (_viaCashDesk != viaCashDesk) {
     
        if (viaCashDesk) {
            
            self.viaBankOffice = NO;
            self.typeSelector.selectedSegmentIndex = 0;
            
            [self hideImageThumbnail];
            
            if (self.defaultUncashingPlace) {
                
                self.currentUncashingPlace = self.defaultUncashingPlace;
                
            } else {
            
                [self uncashingPlaceButtonPressed:nil];

            }
            
            self.uncashingType = CASH_DESK_TYPE;
            
        }
        
        _viaCashDesk = viaCashDesk;
        
    }
    
}

- (void)setUncashingSum:(NSDecimalNumber *)uncashingSum {
    
    if (_uncashingSum != uncashingSum) {
        
        _uncashingSum = uncashingSum;
        
        [STMUncashingProcessController sharedInstance].uncashingSum = uncashingSum;
        
    }
    
}

- (void)setUncashingType:(NSString *)uncashingType {
    
    if (_uncashingType != uncashingType) {
        
        _uncashingType = uncashingType;
        
        [STMUncashingProcessController sharedInstance].uncashingType = uncashingType;
        
    }
    
}

- (void)setCommentText:(NSString *)commentText {
    
    if (_commentText != commentText) {
        
        _commentText = commentText;
        
        [STMUncashingProcessController sharedInstance].commentText = commentText;
        
    }
    
}

- (void)setPictureImage:(UIImage *)pictureImage {
    
    if (_pictureImage != pictureImage) {
        
        _pictureImage = pictureImage;
        
        (pictureImage) ? [self showImageThumbnail] : [self hideImageThumbnail];
        
        [STMUncashingProcessController sharedInstance].pictureImage = pictureImage;
        
    }
    
}

- (void)setCurrentUncashingPlace:(STMUncashingPlace *)currentUncashingPlace {
    
    if (_currentUncashingPlace != currentUncashingPlace) {
        
        _currentUncashingPlace = currentUncashingPlace;
        
        [self.uncashingPlaceButton setTitle:currentUncashingPlace.name forState:UIControlStateNormal];
        self.uncashingPlaceButton.hidden = (!currentUncashingPlace);
        
        [STMUncashingProcessController sharedInstance].currentUncashingPlace = currentUncashingPlace;
        
    }
    
}

- (NSArray *)uncashingPlaces {
    
    if (!_uncashingPlaces) {
        
        _uncashingPlaces = [[STMUncashingPlaceController sharedController] uncashingPlaces];
        
    }
    
    return _uncashingPlaces;
    
}

- (STMUncashingPlace *)defaultUncashingPlace {
    
    if (!_defaultUncashingPlace) {
        
        NSDictionary *appSettings = [[[STMSessionManager sharedManager].currentSession settingsController] currentSettingsForGroup:@"appSettings"];
        NSString *defaultUncashingPlaceXid = [appSettings valueForKey:@"defaultUncashingPlace"];
        NSData *xidData = [STMFunctions dataFromString:[defaultUncashingPlaceXid stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        NSManagedObject *object = [STMObjectsController objectForXid:xidData entityName:NSStringFromClass([STMUncashingPlace class])];

        if ([object isKindOfClass:[STMUncashingPlace class]]) {
            
            _defaultUncashingPlace = (STMUncashingPlace *)object;
            
        }
        
    }
    
    return _defaultUncashingPlace;
    
}

- (void)showImageThumbnail {
    
    self.imageView.image = self.pictureImage;
    
    if (self.pictureImage) {
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped)];
        [self.imageView addGestureRecognizer:tap];
        
    }

}

- (void)hideImageThumbnail {
    
    self.imageView.image = nil;
    self.imageView.gestureRecognizers = @[];
    
}


#pragma mark - buttons pressing

- (IBAction)typeSelected:(id)sender {
    
    if ([sender isEqual:self.typeSelector]) {
        
        if (self.typeSelector.selectedSegmentIndex == 0) {
            
            if (self.uncashingPlaces.count == 0) {

                [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"NO CASH DESK", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    alert.delegate = self;
                    alert.tag = 1;
                    [alert show];
                    
                }];

            } else {
                
                [self showUncashingPlaceInfo];
                self.viaCashDesk = YES;

            }
            
        } else if (self.typeSelector.selectedSegmentIndex == 1) {
            
            [self hideUncashingPlaceInfo];
            self.viaBankOffice = YES;
            
        } else {
            
            self.viaBankOffice = NO;
            self.viaCashDesk = NO;
            
        }
        
    }
    
}

- (IBAction)uncashingPlaceButtonPressed:(id)sender {
    
    if (self.uncashingPlaces.count == 1) {
        
        self.currentUncashingPlace = [self.uncashingPlaces lastObject];
        self.uncashingPlaceButton.enabled = NO;
        
    } else if (self.uncashingPlaces.count > 1) {
    
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SELECT UNCASHING PLACE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:nil];
            
            for (STMUncashingPlace *place in self.uncashingPlaces) {
                
                [actionSheet addButtonWithTitle:place.name];
                
            }
            
            actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
            actionSheet.tag = 1;
            //    [actionSheet showInView:self.splitVC.view];
            [actionSheet showFromRect:self.uncashingPlaceButton.frame inView:self.view animated:YES];
            
        }];

    }
    
}

- (void)doneButtonPressed {
    [self.view endEditing:NO];
}

- (void)cancelUncashingProcessButtonPressed {
    
    [[STMUncashingProcessController sharedInstance] cancelProcess];
    
}

- (void)uncashingProcessDone {
    
    [self flushSelf];
    
}

- (void)uncashingProcessCancel {
    
    [self flushSelf];

}

- (void)flushSelf {
    
    self.uncashingSum = nil;
    self.pictureImage = nil;
    self.uncashingType = nil;
    self.currentUncashingPlace = nil;
    self.uncashingPlaces = nil;
    
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - camera buttons

- (IBAction)cameraButtonPressed:(id)sender {
    
//    NSLog(@"cameraButtonPressed");
    
    UIView *view = [[UIView alloc] initWithFrame:self.imagePickerController.cameraOverlayView.frame];
    view.backgroundColor = [UIColor grayColor];
    view.alpha = 0.75;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = view.center;
    [spinner startAnimating];
    [view addSubview:spinner];
    
    [self.imagePickerController.cameraOverlayView addSubview:view];
    
    [self.imagePickerController takePicture];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
//    NSLog(@"cancelButtonPressed");
    
    [self imagePickerControllerDidCancel:self.imagePickerController];
    
}

- (IBAction)photoLibraryButtonPressed:(id)sender {
    
    [self cancelButtonPressed:sender];
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
}


#pragma mark - info popover buttons

- (void)imageViewTapped {
    
    STMUncashingPhotoVC *photoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"uncashingPhotoVC"];
    photoVC.image = self.pictureImage;
    photoVC.handOverController = self;
    
    [self presentViewController:photoVC animated:YES completion:^{
        
    }];
    
}

- (void)confirmButtonPressed {
    
    [self dismissInfoPopover];
    [[STMUncashingProcessController sharedInstance] uncashingDone];
    
}


#pragma mark - keyboard toolbar buttons

- (void)toolbarDoneButtonPressed {
    
    [self.view endEditing:NO];
    
}

- (void)toolbarCancelButtonPressed {
    
    if ([self.commentTextView isFirstResponder]) {
        
        self.commentTextView.text = self.initialCommentText;
        [self toolbarDoneButtonPressed];
        
    }
    
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        
        [self cancelCashDesk];
        
    } else if (alertView.tag == 2) {
        
        if (buttonIndex == 0) {
            
            [self cancelBankOffice];
            
        } else if (buttonIndex == 1) {
            
//            [self showImagePickerSelector];
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            
        }
        
//    } else if (alertView.tag == 3) {
//        
//        if (buttonIndex > 0) {
//            
//            [self showImagePickerForSourceType:[self.availableSourceTypes[buttonIndex-1] intValue]];
//            
//        }
        
    }

    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex ==  0) buttonIndex = 1;
    
    if (actionSheet.tag == 1) {

        if (buttonIndex == -1) {
            
            if (!self.currentUncashingPlace) {
                [self cancelCashDesk];
            }
            
        } else {
        
            self.currentUncashingPlace = self.uncashingPlaces[buttonIndex-1];

        }
        
    }
    
}


# pragma mark - methods

- (void)showUncashingPlaceInfo {
    
    self.uncashingPlaceLabel.hidden = NO;
    [self.uncashingPlaceButton setTitle:self.currentUncashingPlace.name forState:UIControlStateNormal];
    self.uncashingPlaceButton.hidden = NO;
    
}

- (void)hideUncashingPlaceInfo {
    
    self.uncashingPlaceLabel.hidden = YES;
    self.uncashingPlaceButton.hidden = YES;

}

- (void)deletePhoto {
    
    [self dismissInfoPopover];
    [self cancelBankOffice];
    self.pictureImage = nil;
    self.viaBankOffice = YES;
    
}

- (void)cancelBankOffice {
    
    self.viaBankOffice = NO;
    
    self.typeSelector.selectedSegmentIndex = (self.viaCashDesk) ? 0 : UISegmentedControlNoSegment;
    
    (self.viaCashDesk) ? [self showUncashingPlaceInfo] : nil;

}

- (void)cancelCashDesk {
    
    self.viaCashDesk = NO;
    
    self.typeSelector.selectedSegmentIndex = (self.viaBankOffice) ? 1 : UISegmentedControlNoSegment;
    
    [self hideUncashingPlaceInfo];
    
}

/*
- (void)showImagePickerSelector {
    
    self.availableSourceTypes = nil;
    
    BOOL photoLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
//    BOOL savedPhotosAlbum = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IMAGE SOURCE", nil) message:NSLocalizedString(@"CHOOSE TYPE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:nil];
    alert.tag = 3;
    
    if (photoLibrary) {
        
        [alert addButtonWithTitle:NSLocalizedString(@"PHOTO LIBRARY", nil)];
        [self.availableSourceTypes addObject:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
        
    }
    
    if (camera) {
        
        [alert addButtonWithTitle:NSLocalizedString(@"CAMERA", nil)];
        [self.availableSourceTypes addObject:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeCamera]];
        
    }
    
//    if (savedPhotosAlbum) {
//        
//        [alert addButtonWithTitle:NSLocalizedString(@"SAVED PHOTOS ALBUM", nil)];
//        [self.availableSourceTypes addObject:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeSavedPhotosAlbum]];
//        
//    }
    
    [alert show];
    
}
*/

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)imageSourceType {
    
    if ([UIImagePickerController isSourceTypeAvailable:imageSourceType]) {
        
        self.selectedSourceType = imageSourceType;

        [self.splitViewController presentViewController:self.imagePickerController animated:YES completion:^{
            
            [self.splitViewController.view addSubview:self.spinnerView];
            //            NSLog(@"presentViewController:UIImagePickerController");
            
        }];
        
    }
    
}

- (void)cashingDictionaryChanged {
    
    NSDecimalNumber *uncashingSum = [NSDecimalNumber zero];
    
    for (STMCashing *cashing in [[STMUncashingProcessController sharedInstance].cashingDictionary allValues]) {
        
        uncashingSum = (cashing.summ) ? [uncashingSum decimalNumberByAdding:(NSDecimalNumber *)cashing.summ] : uncashingSum;
        
    }
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];

    self.uncashingSumLabel.text = [numberFormatter stringFromNumber:uncashingSum];
    
    self.uncashingSum = uncashingSum;

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (self.infoPopoverIsVisible) {
        
        [self showInfoPopover];
        self.infoPopoverIsVisible = NO;
        
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    if (self.uncashingInfoPopover.popoverVisible) {
        
        self.infoPopoverIsVisible = YES;
        [self dismissInfoPopover];
        
    }
    
}

- (void)showInfoPopover {

//    self.uncashingInfoPopover = nil;
    
    CGRect rect = CGRectMake(self.splitVC.view.frame.size.width/2, self.splitVC.view.frame.size.height/2, 1, 1);
    [self.uncashingInfoPopover presentPopoverFromRect:rect inView:self.splitVC.view permittedArrowDirections:0 animated:YES];

}

- (void)dismissInfoPopover {
    
    [self.uncashingInfoPopover dismissPopoverAnimated:YES];
    self.uncashingInfoPopover = nil;
    
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.uncashingInfoPopover = nil;
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
//    NSLog(@"picker didFinishPickingMediaWithInfo");
    
    self.viaCashDesk = NO;
    self.typeSelector.selectedSegmentIndex = 1;

    [picker dismissViewControllerAnimated:NO completion:^{
        
//        [self saveImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        
        self.pictureImage = info[UIImagePickerControllerOriginalImage];
        [self.spinnerView removeFromSuperview];
        self.spinnerView = nil;
        self.imagePickerController = nil;
        
//        NSLog(@"dismiss UIImagePickerController");
        
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self cancelBankOffice];
    
    [picker dismissViewControllerAnimated:NO completion:^{

//        [self.spinnerView removeFromSuperview];
//        
//        self.imagePickerController = nil;

//        NSLog(@"imagePickerControllerDidCancel");
        
    }];

    [self.spinnerView removeFromSuperview];
    
    self.imagePickerController = nil;

}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.commentTextView]) {
        
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, TOOLBAR_HEIGHT);
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(toolbarCancelButtonPressed)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toolbarDoneButtonPressed)];

        [cancelButton setTintColor:[UIColor redColor]];
        
        [toolbar setItems:@[cancelButton,flexibleSpace,doneButon] animated:YES];
        
        self.commentTextView.inputAccessoryView = toolbar;

    }
    
    return YES;
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.commentTextView]) {
        
        self.commentTextView.inputAccessoryView = nil;
        
    }
    
    return YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.commentTextView]) {

        NSString *text = self.commentTextView.text;
        
        if ([text isEqualToString:NSLocalizedString(@"ADD COMMENT", nil)]) {
            
            self.commentTextView.text = @"";
            self.commentTextView.textColor = [UIColor blackColor];
            
        }
        
        self.initialCommentText = self.commentTextView.text;
        
    }
    
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.commentTextView]) {
        
        NSString *text = self.commentTextView.text;
        
        if ([text isEqualToString:@""]) {
            
            self.commentTextView.text = NSLocalizedString(@"ADD COMMENT", nil);
            self.commentTextView.textColor = GREY_LINE_COLOR;
            self.commentText = nil;
            
        } else {
            
            self.commentText = text;
            
        }
        
        
    }
    
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
    
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    int kOFFSET_FOR_KEYBOARD = 300;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        kOFFSET_FOR_KEYBOARD -= self.view.frame.size.height - (self.commentTextView.frame.origin.y + self.commentTextView.frame.size.height);
        if (kOFFSET_FOR_KEYBOARD<0) kOFFSET_FOR_KEYBOARD=0;
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        kOFFSET_FOR_KEYBOARD = -rect.origin.y;
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([self.commentTextView isFirstResponder] && [touch view] != self.commentTextView) {
        
        [self.commentTextView resignFirstResponder];
        
    }
    
    [super touchesBegan:touches withEvent:event];
    
}

/*
- (void)keyboardDidShow:(NSNotification *)notification {
 
}

- (void)keyboardWillShow:(NSNotification *)notification {
 
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
}
*/

- (id)findFirstResponder {
    
    if (self.isFirstResponder) {
        return self;
    }
    
    for (UIView *subView in self.view.subviews) {
        
        if ([subView isFirstResponder]) {
            return subView;
        }
        
    }
    
    return nil;
    
}


#pragma mark - view lifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(cashingDictionaryChanged)
               name:@"cashingDictionaryChanged"
             object:[STMUncashingProcessController sharedInstance]];
    
    [nc addObserver:self
           selector:@selector(doneButtonPressed)
               name:@"uncashingDoneButtonPressed"
             object:self.splitVC.detailVC];

    [nc addObserver:self
           selector:@selector(uncashingProcessDone)
               name:@"uncashingProcessDone"
             object:[STMUncashingProcessController sharedInstance]];
    
    [nc addObserver:self
           selector:@selector(uncashingProcessCancel)
               name:@"uncashingProcessCancel"
             object:[STMUncashingProcessController sharedInstance]];
    
    [nc addObserver:self
           selector:@selector(showInfoPopover)
               name:@"uncashingIsValid"
             object:[STMUncashingProcessController sharedInstance]];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)labelsInit {
    
    self.title = NSLocalizedString(@"HANDOVERING", nil);
    
    NSDateFormatter *dateFormatter = [STMFunctions dateLongNoTimeFormatter];
    
    self.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    
    self.uncashingLabel.text = NSLocalizedString(@"CASHING SUMM2", nil);

    [self.typeSelector setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [self.typeSelector setTitle:NSLocalizedString(@"CASH DESK", nil) forSegmentAtIndex:0];
    [self.typeSelector setTitle:NSLocalizedString(@"BANK OFFICE", nil) forSegmentAtIndex:1];

    self.uncashingPlaceLabel.text = NSLocalizedString(@"UNCASHING PLACE LABEL", nil);
    self.uncashingPlaceLabel.hidden = YES;
    [self.uncashingPlaceButton setTitle:self.currentUncashingPlace.name forState:UIControlStateNormal];
    self.uncashingPlaceButton.hidden = YES;
    
    self.commentTextView.textColor = GREY_LINE_COLOR;
    self.commentTextView.text = NSLocalizedString(@"ADD COMMENT", nil);
    self.commentTextView.layer.borderWidth = 1.0f;
    self.commentTextView.layer.borderColor = [GREY_LINE_COLOR CGColor];
    self.commentTextView.layer.cornerRadius = 5.0f;

    [self cashingDictionaryChanged];
    
}

- (void)customInit {
    
//    NSLog(@"self %@", self);

    [self addObservers];
    
    self.navigationItem.leftBarButtonItem = [[STMBarButtonItemCancel alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelUncashingProcessButtonPressed)];
    [self.navigationItem setHidesBackButton:YES animated:YES];

    self.commentTextView.delegate = self;
    [self labelsInit];

}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
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
