//
//  STMUncashingHandOverVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/10/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingHandOverVC.h"
#import "STMCashing.h"

@interface STMUncashingHandOverVC () <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingSumLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelector;
@property (nonatomic, strong) NSDecimalNumber *uncashingSum;
@property (nonatomic) BOOL viaBankOffice;
@property (nonatomic) BOOL viaCashDesk;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIView *spinnerView;
@property (nonatomic, strong) UIView *cameraOverlayView;

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

- (void)setViaBankOffice:(BOOL)viaBankOffice {
    
    if (_viaBankOffice != viaBankOffice) {

        if (viaBankOffice) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PHOTO", nil) message:@"Photo" delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            alert.tag = 2;
            [alert show];

        }
        
        _viaBankOffice = viaBankOffice;
        
        [self checkControlsState];
        
    }
    
}

- (void)setViaCashDesk:(BOOL)viaCashDesk {
    
    if (_viaCashDesk != viaCashDesk) {
     
        if (viaCashDesk) {
            
            self.viaBankOffice = NO;
            self.typeSelector.selectedSegmentIndex = 0;
            
        }
        
        _viaCashDesk = viaCashDesk;
        
        [self checkControlsState];
        
    }
    
}

- (IBAction)typeSelected:(id)sender {
    
    if ([sender isEqual:self.typeSelector]) {
        
        if (self.typeSelector.selectedSegmentIndex == 0) {
            
            self.viaCashDesk = YES;
            
        } else if (self.typeSelector.selectedSegmentIndex == 1) {
            
            self.viaBankOffice = YES;
            
        } else {
            
            self.viaBankOffice = NO;
            self.viaCashDesk = NO;
            
        }
        
    }
    
}

- (IBAction)doneButtonPressed:(id)sender {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HAND OVER BUTTON", nil) message:[numberFormatter stringFromNumber:self.uncashingSum] delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alert.tag = 1;
    [alert show];
    
}

- (IBAction)cameraButtonPressed:(id)sender {
    
    NSLog(@"cameraButtonPressed");
    
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
    
    NSLog(@"cancelButtonPressed");
    
    [self.imagePickerController dismissViewControllerAnimated:NO completion:^{
        
        [self.spinnerView removeFromSuperview];
        
        //        if (self.selectedPhotoReport.photos.count == 0) {
        //            [self.document.managedObjectContext deleteObject:self.selectedPhotoReport];
        //            //            NSLog(@"delete empty photoReport");
        //        }
        
        self.imagePickerController = nil;
        //        NSLog(@"cancel button pressed");
        
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        
        if (buttonIndex == 1) {

            [self.splitVC.detailVC uncashingDoneWithSum:self.uncashingSum];
            
        } else {
            
        }
        
    } else if (alertView.tag == 2) {
        
        if (buttonIndex == 0) {
            
            self.viaBankOffice = NO;
            self.typeSelector.selectedSegmentIndex = self.viaCashDesk ? 0 : UISegmentedControlNoSegment;
            
        } else if (buttonIndex == 1) {
            
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            
            self.viaCashDesk = NO;
            self.typeSelector.selectedSegmentIndex = 1;
            
        }
        
    }
    
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
        
        [self.navigationController popViewControllerAnimated:YES];
        
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

    [self checkControlsState];
    
}

- (void)checkControlsState {
 
    if ([self.uncashingSum intValue] <= 0 || !(self.viaBankOffice || self.viaCashDesk)) {
        
        self.doneButton.enabled = NO;
        
    } else {
        
        self.doneButton.enabled = YES;
        
    }

}


#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handOverProcessingChanged:) name:@"handOverProcessingChanged" object:self.splitVC];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cashingDictionaryChanged) name:@"cashingDictionaryChanged" object:self.splitVC.detailVC];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)labelsInit {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    self.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    
    self.uncashingLabel.text = NSLocalizedString(@"CASHING SUMM", nil);

    [self.typeSelector setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [self.typeSelector setTitle:NSLocalizedString(@"CASH DESK", nil) forSegmentAtIndex:0];
    [self.typeSelector setTitle:NSLocalizedString(@"BANK OFFICE", nil) forSegmentAtIndex:1];

    [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];

    [self cashingDictionaryChanged];
    
}

- (void)customInit {

    [self addObservers];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self labelsInit];
    
//    NSLog(@"self.cameraOverlayView %@", self.cameraOverlayView);
//    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"STMCameraOverlayView" owner:self options:nil];
//    NSLog(@"array %@", array);
//    NSLog(@"self.cameraOverlayView %@", self.cameraOverlayView);
    
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
