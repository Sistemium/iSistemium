//
//  STMBarCodeScanner.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMBarCodeScanner.h"

#import <AVFoundation/AVFoundation.h>


@interface STMBarCodeScanner() <UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UITextField *hiddenBarCodeTextField;

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;


@end


@implementation STMBarCodeScanner

- (instancetype)initWithMode:(STMBarCodeScannerMode)mode {

    self = [super init];
    
    if (self) {
        _mode = mode;
    }
    return self;

}

- (void)startScan {
    
    if (self.status != STMBarCodeScannerStarted) {
        
        _status = STMBarCodeScannerStarted;

        switch (self.mode) {
            case STMBarCodeScannerCameraMode: {
                
                [self prepareForCameraMode];
                break;
                
            }
            case STMBarCodeScannerHIDKeyboardMode: {
                
                [self prepareForHIDScanMode];
                break;
                
            }
            case STMBarCodeScannerIOSMode: {
                
                break;
            }
            default: {
                break;
            }
        }

    }
    
}

- (void)stopScan {
    
    if (self.status != STMBarCodeScannerStopped) {
        
        _status = STMBarCodeScannerStopped;
        
        switch (self.mode) {
            case STMBarCodeScannerCameraMode: {
                
                [self finishCameraMode];
                break;
                
            }
            case STMBarCodeScannerHIDKeyboardMode: {
                
                [self finishHIDScanMode];
                break;
                
            }
            case STMBarCodeScannerIOSMode: {
                
                break;
            }
            default: {
                break;
            }
        }
        
    }

}


#pragma mark - STMBarCodeScannerCameraMode

- (void)prepareForCameraMode {
    
    if ([self isCameraAvailable]) {
        
        [self setupScanner];
        
    } else {
        
        NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
        
        NSError *error = [NSError errorWithDomain:(NSString * _Nonnull)bundleId
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"No camera available"}];
        
        [self.delegate barCodeScanner:self receiveError:error];
        
        [self stopScan];
        
    }

}

- (void)finishCameraMode {
    
    [self.session stopRunning];
    [self.preview removeFromSuperlayer];

    self.preview = nil;
    self.output = nil;
    self.session = nil;
    self.input = nil;
    self.device = nil;
    
}

- (BOOL)isCameraAvailable {
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
    
}

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
    
    UIView *superView = [self.delegate viewForScanner:self];
    self.preview.frame = CGRectMake(0, 0, superView.frame.size.width, superView.frame.size.height);
    
    AVCaptureConnection *con = self.preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationPortrait;

    [superView.layer insertSublayer:self.preview atIndex:0];
    
    [self.session startRunning];

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
    
    [self.delegate barCodeScanner:self receiveBarCode:aScannedValue];
    [self stopScan];
    
}


#pragma mark - STMBarCodeScannerHIDKeyboardMode

- (void)prepareForHIDScanMode {

    
    self.hiddenBarCodeTextField = [[UITextField alloc] init];
    [self.hiddenBarCodeTextField becomeFirstResponder];
    self.hiddenBarCodeTextField.delegate = self;
    
    [[self.delegate viewForScanner:self] addSubview:self.hiddenBarCodeTextField];

}

- (void)finishHIDScanMode {
    
    [self.hiddenBarCodeTextField resignFirstResponder];
    [self.hiddenBarCodeTextField removeFromSuperview];
    self.hiddenBarCodeTextField.delegate = nil;
    self.hiddenBarCodeTextField = nil;
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.delegate barCodeScanner:self receiveBarCode:textField.text];
    textField.text = @"";
    
    return NO;
    
}


@end
