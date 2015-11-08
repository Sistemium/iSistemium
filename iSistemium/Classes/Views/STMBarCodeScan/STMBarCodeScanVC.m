//
//  STMBarCodeScanVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMBarCodeScanVC.h"

#import <AVFoundation/AVFoundation.h>

#import "STMConstants.h"
#import "STMSessionManager.h"
#import "STMDataModel.h"
#import "STMNS.h"


@interface STMBarCodeScanVC () <UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *articlePriceLabel;

@property (nonatomic, strong) UITextField *hiddenBarCodeTextField;

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;


@end


@implementation STMBarCodeScanVC

- (IBAction)cameraButtonPressed:(id)sender {
    
    [self.hiddenBarCodeTextField resignFirstResponder];
    
    [self.view.layer insertSublayer:self.preview atIndex:0];

    [self.session startRunning];
    
}

- (BOOL)isCameraAvailable {
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
    
}


#pragma mark - AVFoundationSetup

- (void)setupScanner {
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    self.session = [[AVCaptureSession alloc] init];
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    AVCaptureConnection *con = self.preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationPortrait;
    
//    [self.view.layer insertSublayer:self.preview atIndex:0];
    
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    for (AVMetadataObject *current in metadataObjects) {
        
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            
            NSString *scannedValue = [(AVMetadataMachineReadableCodeObject *)current stringValue];
            [self didSuccessfullyScan:scannedValue];
            
        }
        
    }
    
}

- (void)didSuccessfullyScan:(NSString *)aScannedValue {
    
//    NSLog(@"aScannedValue %@", aScannedValue);
    
    [self.session stopRunning];
    
    [self.preview removeFromSuperlayer];
    
    [self searchBarCode:aScannedValue];
    
}


- (void)searchBarCode:(NSString *)barcode {
    
    self.barcodeLabel.text = barcode;

    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY barcodes.barcode == %@", barcode];
    
    NSArray *articlesArray = [[[STMSessionManager sharedManager].currentSession document].managedObjectContext executeFetchRequest:request error:nil];
    
    if (articlesArray.count > 1) {
        NSLog(@"articlesArray.count > 1");
    }
    
    STMArticle *article = articlesArray.firstObject;
    
    if (article) {
        
        self.articleNameLabel.text = article.name;
        self.articleVolumeLabel.text = article.pieceVolume.stringValue;
        self.articlePriceLabel.text = [(STMPrice *)article.prices.allObjects.firstObject price].stringValue;

    } else {
        
        self.articleNameLabel.text = @"N/A";
        self.articleVolumeLabel.text = @"N/A";
        self.articlePriceLabel.text = @"N/A";

    }
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self searchBarCode:textField.text];
    textField.text = @"";
    return NO;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.hiddenBarCodeTextField = [[UITextField alloc] init];
    [self.hiddenBarCodeTextField becomeFirstResponder];
    self.hiddenBarCodeTextField.delegate = self;
    
    [self.view addSubview:self.hiddenBarCodeTextField];
    
    if ([self isCameraAvailable]) {
        [self setupScanner];
    }
    
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
