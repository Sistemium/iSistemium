//
//  STMBarCodeScanner.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMBarCodeScanner.h"

#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import <ScanAPI/ScanApiHelper.h>

#import "STMNS.h"
#import "STMDataModel.h"
#import "STMSessionManager.h"


@interface STMBarCodeScanner() <UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate, ScanApiHelperDelegate>

@property (nonatomic, strong) UITextField *hiddenBarCodeTextField;

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic, strong) ScanApiHelper *iOSScanHelper;
@property (nonatomic, strong) NSTimer* scanApiConsumer;

@property (nonatomic, strong) NSFetchedResultsController *barCodeTypesRC;


@end


@implementation STMBarCodeScanner

- (instancetype)initWithMode:(STMBarCodeScannerMode)mode {

    self = (mode == STMBarCodeScannerIOSMode) ? [STMBarCodeScanner iOSModeScanner] : [super init];
    
    if (self) {
        
        _mode = mode;
        _status = STMBarCodeScannerStopped;
        
    }
    return self;

}

- (BOOL)isDeviceConnected {
    return (self.mode == STMBarCodeScannerIOSMode) ? [self.iOSScanHelper isDeviceConnected] : NO;
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
                
                [self prepareForIOSScanMode];
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
                
                [self finishIOSScanMode];
                break;
            }
            default: {
                break;
            }
        }
        
        self.delegate = nil;
        
    }

}

- (NSFetchedResultsController *)barCodeTypesRC {
    
    if (!_barCodeTypesRC) {
        
        NSManagedObjectContext *context = [[STMSessionManager sharedManager].currentSession document].managedObjectContext;
        
        if (context) {
            
            STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMBarCodeType class])];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
            request.predicate = [STMPredicate predicateWithNoFantoms];
            
            NSFetchedResultsController *rc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                 managedObjectContext:context
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:nil];
            [rc performFetch:nil];
            
            _barCodeTypesRC = rc;

        }
        
    }
    return _barCodeTypesRC;
    
}

- (void)checkScannedBarcode:(NSString *)barcode {
    
    NSString *matchedType = nil;

    for (STMBarCodeType *barCodeType in self.barCodeTypesRC.fetchedObjects) {
        
        if (barCodeType.mask) {
            
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:(NSString * _Nonnull)barCodeType.mask
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:barcode
                                                                options:0
                                                                  range:NSMakeRange(0, barcode.length)];
            
            if (numberOfMatches > 0) {
                
                matchedType = barCodeType.type;
                break;
                
            }

        }
        
    }
    
    [self.delegate barCodeScanner:self receiveBarCode:barcode withType:[self barCodeScannedTypeForStringType:matchedType]];

}

- (STMBarCodeScannedType)barCodeScannedTypeForStringType:(NSString *)type {
    
    if ([type isEqualToString:@"Article"]) {
        
        return STMBarCodeTypeArticle;
        
    } else if ([type isEqualToString:@"StockBatch"]) {
        
        return STMBarCodeTypeStockBatch;
        
    } else if ([type isEqualToString:@"ExciseStamp"]) {
        
        return STMBarCodeTypeExciseStamp;
        
    } else {
        
        return STMBarCodeTypeUnknown;
        
    }
    
}


#pragma mark - STMBarCodeScannerCameraMode

- (void)prepareForCameraMode {
    
    if ([STMBarCodeScanner isCameraAvailable]) {
        
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

+ (BOOL)isCameraAvailable {
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return ([videoDevices count] > 0);
    
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

    [superView.layer insertSublayer:self.preview above:superView.layer];
    
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
    
    [self checkScannedBarcode:aScannedValue];
    [self stopScan];
    
}


#pragma mark - STMBarCodeScannerHIDKeyboardMode

- (void)prepareForHIDScanMode {

    
    self.hiddenBarCodeTextField = [[UITextField alloc] init];
    self.hiddenBarCodeTextField.keyboardType = UIKeyboardTypeASCIICapable;
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


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self checkScannedBarcode:textField.text];
    textField.text = @"";
    
    return NO;
    
}


#pragma mark - STMBarCodeScannerIOSMode

+ (STMBarCodeScanner *)iOSModeScanner {

    static dispatch_once_t pred = 0;
    __strong static id _iOSModeScanner = nil;
    
    dispatch_once(&pred, ^{
        
        _iOSModeScanner = [[STMBarCodeScanner alloc] init];
        [self addScanHelperToScanner:_iOSModeScanner];
        
    });
    
    return _iOSModeScanner;

}

+ (void)addScanHelperToScanner:(STMBarCodeScanner *)scanner {
    
    scanner.iOSScanHelper = [[ScanApiHelper alloc] init];
    [scanner.iOSScanHelper setDelegate:scanner];
    [scanner.iOSScanHelper open];

    scanner.scanApiConsumer = [NSTimer scheduledTimerWithTimeInterval:.2
                                                               target:scanner
                                                             selector:@selector(onScanApiConsumerTimer:)
                                                             userInfo:nil
                                                              repeats:YES];

}

- (void)prepareForIOSScanMode {
    
}

-(void)onScanApiConsumerTimer:(NSTimer*)timer {
    
    if (timer == self.scanApiConsumer){
        [self.iOSScanHelper doScanApiReceive];
    }
    
}

- (void)finishIOSScanMode {

}

- (void)postGetPostamble:(id)sender {
    
    NSLog(@"%@", sender);
    
}


#pragma mark ScanApiHelperDelegate

- (void)onDeviceArrival:(SKTRESULT)result device:(DeviceInfo *)deviceInfo {
    
//    [self.iOSScanHelper postGetPostambleDevice:deviceInfo Target:self Response:@selector(postGetPostamble:)];
    
    [self.iOSScanHelper postSetPostambleDevice:deviceInfo Postamble:@"" Target:nil Response:nil];

//    [self.iOSScanHelper postGetPostambleDevice:deviceInfo Target:self Response:@selector(postGetPostamble:)];

    
    [self.delegate deviceArrivalForBarCodeScanner:self];
    
}

- (void)onDeviceRemoval:(DeviceInfo *)deviceRemoved {
    [self.delegate deviceRemovalForBarCodeScanner:self];
}

- (void)onDecodedDataResult:(long)result device:(DeviceInfo *)device decodedData:(ISktScanDecodedData *)decodedData {
    
    if(SKTSUCCESS(result)){
        
        NSString *resultString = [NSString stringWithUTF8String:(const char *)[decodedData getData]];

        [self checkScannedBarcode:resultString];

    }

}


@end
