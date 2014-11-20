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

@interface STMUncashingHandOverVC () <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingSumLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelector;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *uncashingPlaceButton;
@property (weak, nonatomic) IBOutlet UILabel *uncashingPlaceLabel;

@property (nonatomic, strong) NSDecimalNumber *uncashingSum;
@property (nonatomic, strong) NSString *uncashingType;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) NSString *initialCommentText;
@property (nonatomic) BOOL viaBankOffice;
@property (nonatomic) BOOL viaCashDesk;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIView *spinnerView;
@property (nonatomic, strong) UIView *cameraOverlayView;

@property (nonatomic, strong) UIImage *pictureImage;
@property (nonatomic, strong) UIPopoverController *uncashingInfoPopover;
@property (nonatomic) BOOL infoPopoverIsVisible;

@property (nonatomic, strong) NSArray *uncashingPlaces;
@property (nonatomic, strong) STMUncashingPlace *currentUncashingPlace;

@property (nonatomic, strong) STMUncashingPlace *defaultUncashingPlace;

@end


@implementation STMUncashingHandOverVC

- (UIImagePickerController *)imagePickerController {
    
    if (!_imagePickerController) {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.showsCameraControls = NO;
        
        [[NSBundle mainBundle] loadNibNamed:@"STMCameraOverlayView" owner:self options:nil];
        self.cameraOverlayView.backgroundColor = [UIColor clearColor];
        self.cameraOverlayView.autoresizesSubviews = YES;
        self.cameraOverlayView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            
            UIView *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
            CGRect originalFrame = [[UIScreen mainScreen] bounds];
            CGRect screenFrame = [rootView convertRect:originalFrame fromView:nil];
            self.cameraOverlayView.frame = screenFrame;
            
        }
        
        imagePickerController.cameraOverlayView = self.cameraOverlayView;
        
        _imagePickerController = imagePickerController;
        
    }
    
    return _imagePickerController;
    
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

- (NSString *)uncashingType {
    
    NSString *type = nil;
    
    if (self.viaBankOffice) {
        type = BANK_OFFICE_TYPE;
    } else if (self.viaCashDesk) {
        type = CASH_DESK_TYPE;
    }

    return type;
    
}

- (void)setViaBankOffice:(BOOL)viaBankOffice {
    
    if (_viaBankOffice != viaBankOffice) {

        if (viaBankOffice) {
            
            if (self.pictureImage) {
                
                [self showImageThumbnail];
                self.viaCashDesk = NO;
                
            } else {
            
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ATTENTION", nil) message:NSLocalizedString(@"BANK CHECK PHOTO", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                alert.tag = 2;
                [alert show];

            }
            
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
            
        }
        
        _viaCashDesk = viaCashDesk;
        
    }
    
}

- (void)setPictureImage:(UIImage *)pictureImage {
    
    if (_pictureImage != pictureImage) {
        
        _pictureImage = pictureImage;
        
        (pictureImage) ? [self showImageThumbnail] : [self hideImageThumbnail];
        
    }
    
}

- (void)setCurrentUncashingPlace:(STMUncashingPlace *)currentCashDeskPlace {
    
    if (_currentUncashingPlace != currentCashDeskPlace) {
        
        _currentUncashingPlace = currentCashDeskPlace;
        
        [self.uncashingPlaceButton setTitle:currentCashDeskPlace.name forState:UIControlStateNormal];
        self.uncashingPlaceButton.hidden = (!currentCashDeskPlace);
        
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
        NSString *defaultUncashingPlaceXid = [appSettings valueForKey:@"uncashingPlace"];
        
        NSData *xidData = [STMFunctions dataFromString:[defaultUncashingPlaceXid stringByReplacingOccurrencesOfString:@"-" withString:@""]];

        NSManagedObject *object = [STMObjectsController objectForXid:xidData];
        
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
    self.imageView.gestureRecognizers = [NSArray array];
    
}


#pragma mark - buttons pressing

- (IBAction)typeSelected:(id)sender {
    
    if ([sender isEqual:self.typeSelector]) {
        
        if (self.typeSelector.selectedSegmentIndex == 0) {
            
            if (self.uncashingPlaces.count == 0) {

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"NO CASH DESK", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                alert.delegate = self;
                alert.tag = 1;
                [alert show];

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
    
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SELECT UNCASHING PLACE", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for (STMUncashingPlace *place in self.uncashingPlaces) {
            
            [actionSheet addButtonWithTitle:place.name];
            
        }
        
        actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
        actionSheet.tag = 1;
        //    [actionSheet showInView:self.splitVC.view];
        [actionSheet showFromRect:self.uncashingPlaceButton.frame inView:self.view animated:YES];

    }
    
}

- (void)doneButtonPressed {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    [self.view endEditing:NO];

    if ([self uncashingIsValid]) {
        
        [self showInfoPopover];

    }
    
}

- (void)cancelUncashingProcess {
    
    [self.splitVC.detailVC cancelUncashingProcess];
    [self flushSelf];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)flushSelf {
    
    self.uncashingSum = nil;
    self.pictureImage = nil;
    self.uncashingType = nil;
    self.currentUncashingPlace = nil;
    self.uncashingPlaces = nil;
    
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
    
    [self cancelBankOffice];
    
    [self.imagePickerController dismissViewControllerAnimated:NO completion:^{
        
        [self.spinnerView removeFromSuperview];
        
        self.imagePickerController = nil;
        
    }];
    
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
    
    if ([self.uncashingType isEqualToString:BANK_OFFICE_TYPE]) {
        
        self.currentUncashingPlace = nil;
        
    } else if ([self.uncashingType isEqualToString:CASH_DESK_TYPE]) {
        
        self.pictureImage = nil;
        
    }
    
    [self.splitVC.detailVC uncashingDoneWithSum:self.uncashingSum image:self.pictureImage type:self.uncashingType comment:self.commentText place:self.currentUncashingPlace];
    
}


#pragma mark - keyboard toolbar buttons

- (void)toolbarDoneButtonPressed {
    
    [self.view endEditing:NO];

//    if ([self.commentTextView isFirstResponder]) {
//        [self.commentTextView resignFirstResponder];
//    }
    
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
            
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            
        }
        
    }
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 1) {

        if (buttonIndex == -1) {
            
            if (!self.currentUncashingPlace) {
                [self cancelCashDesk];
            }
            
        } else {
        
            self.currentUncashingPlace = self.uncashingPlaces[buttonIndex];

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

- (BOOL)uncashingIsValid {
    
    if (self.uncashingSum.doubleValue <= 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"UNCASHING SUM NOT VALID", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:nil];
        [alert show];
        
        return NO;
        
    } else if (!self.uncashingType) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"NO UNCASHING TYPE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:nil];
        [alert show];
        
        return NO;

    } else if ([self.uncashingType isEqualToString:BANK_OFFICE_TYPE] && !self.pictureImage) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"NO CHECK IMAGE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:nil];
        [alert show];
        
        return NO;

    } else if ([self.uncashingType isEqualToString:CASH_DESK_TYPE] && !self.currentUncashingPlace) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"NO CASH DESK CHOOSEN", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:nil];
        [alert show];
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
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

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)imageSourceType {
    
    if ([UIImagePickerController isSourceTypeAvailable:imageSourceType]) {
        
        [self.splitViewController presentViewController:self.imagePickerController animated:YES completion:^{
            
            [self.splitViewController.view addSubview:self.spinnerView];
            //            NSLog(@"presentViewController:UIImagePickerController");
            
        }];
        
    }
    
}

- (void)handOverProcessingChanged:(NSNotification *)notification {
    
    if (!self.splitVC.isUncashingHandOverProcessing) {

        [self cancelUncashingProcess];
        
    }
    
}

- (void)cashingDictionaryChanged {
    
    NSDecimalNumber *uncashingSum = [NSDecimalNumber zero];
    
    for (STMCashing *cashing in [self.splitVC.detailVC.cashingDictionary allValues]) {
        
        uncashingSum = [uncashingSum decimalNumberByAdding:cashing.summ];
        
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    self.uncashingSumLabel.text = [numberFormatter stringFromNumber:uncashingSum];
    
    self.uncashingSum = uncashingSum;

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (self.infoPopoverIsVisible) {
        
        [self dismissInfoPopover];
        [self showInfoPopover];
        self.infoPopoverIsVisible = NO;
        
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    if (self.uncashingInfoPopover.popoverVisible) {
        
        self.infoPopoverIsVisible = YES;
        
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
        
        self.pictureImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.spinnerView removeFromSuperview];
        self.spinnerView = nil;
        self.imagePickerController = nil;
        
//        NSLog(@"dismiss UIImagePickerController");
        
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
//        NSLog(@"imagePickerControllerDidCancel");
        
    }];
    
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.commentTextView]) {
        
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handOverProcessingChanged:) name:@"handOverProcessingChanged" object:self.splitVC];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cashingDictionaryChanged) name:@"cashingDictionaryChanged" object:self.splitVC.detailVC];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneButtonPressed) name:@"uncashingDoneButtonPressed" object:self.splitVC.detailVC];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)labelsInit {
    
    self.title = NSLocalizedString(@"HANDOVERING", nil);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
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
    
    self.navigationItem.leftBarButtonItem = [[STMUIBarButtonItemCancel alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelUncashingProcess)];
    [self.navigationItem setHidesBackButton:YES animated:YES];

    self.commentTextView.delegate = self;
    [self labelsInit];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
