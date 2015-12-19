//
//  STMInventoryNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryNC.h"

#import "STMUI.h"
#import "STMBarCodeScanner.h"

#import "STMSoundController.h"
#import "STMObjectsController.h"

#import "STMInventoryProcessController.h"
#import "STMInventoryControlling.h"

#import "STMInventoryArticleSelectTVC.h"
#import "STMInventoryInfoSelectTVC.h"


#define CONNECT_HID_SCANNER_ACTION NSLocalizedString(@"CONNECT HID SCANNER", nil)
#define DISCONNECT_HID_SCANNER_ACTION NSLocalizedString(@"DISCONNECT HID SCANNER", nil)


@interface STMInventoryNC () <STMBarCodeScannerDelegate, STMInventoryControlling>

@property (nonatomic, strong) STMBarCodeScanner *cameraBarCodeScanner;
@property (nonatomic, strong) STMBarCodeScanner *HIDBarCodeScanner;
@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;
@property (nonatomic, weak) STMStockBatch *mismatchedStockBatch;

@property (nonatomic) BOOL shouldUseHIDScanner;


@end


@implementation STMInventoryNC


#pragma mark - STMTabBarItemControllable protocol

- (BOOL)shouldShowOwnActions {
    return YES;
}

- (void)selectActionAtIndex:(NSUInteger)index {
    
    [super selectActionAtIndex:index];
    
    NSString *action = self.actions[index];
    
    if ([action isEqualToString:CONNECT_HID_SCANNER_ACTION]) {

        self.shouldUseHIDScanner = YES;
        
        [self startHIDModeScanner];
        
    } else if ([action isEqualToString:DISCONNECT_HID_SCANNER_ACTION]) {

        [self stopHIDModeScanner];

        self.shouldUseHIDScanner = NO;
        
    }
    
}


#pragma mark

- (BOOL)isInActiveTab {
    return [self.tabBarController.selectedViewController isEqual:self];
}

- (void)addBarcodeImage {
    
    UIImage *image = [STMFunctions resizeImage:[UIImage imageNamed:@"barcode.png"] toSize:CGSizeMake(25, 25)];
    
    UIViewController *rootVC = self.viewControllers.firstObject;
    rootVC.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
}

- (void)removeBarcodeImage {

    UIViewController *rootVC = self.viewControllers.firstObject;
    rootVC.navigationItem.titleView = nil;
    
}


#pragma mark - keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (self.shouldUseHIDScanner) {
        
        [self stopHIDModeScanner];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                            message:NSLocalizedString(@"HID SCANNER NOT FOUND", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            
            [STMSoundController alertSay:NSLocalizedString(@"SAY HID SCANNER NOT FOUND", nil)];
            
        }];

    }
    
}


#pragma mark - barcode scanning

- (void)startBarcodeScanning {

    [self startCameraScanner];

    [self startIOSModeScanner];

    if (![self.iOSModeBarCodeScanner isDeviceConnected]) {
        [self startHIDModeScanner];
    }

}

- (void)startCameraScanner {
    
    if ([STMBarCodeScanner isCameraAvailable]) {
        
        self.cameraBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerCameraMode];
        self.cameraBarCodeScanner.delegate = self;
        
        STMBarButtonItem *cameraButton = [[STMBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                        target:self
                                                                                        action:@selector(cameraBarCodeScannerButtonPressed)];
        
        self.navigationItem.leftBarButtonItem = cameraButton;
        
    }

}

- (void)startIOSModeScanner {
    
    self.iOSModeBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerIOSMode];
    self.iOSModeBarCodeScanner.delegate = self;
    [self.iOSModeBarCodeScanner startScan];

}

- (void)startHIDModeScanner {
    
    if (self.shouldUseHIDScanner) {
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];

        self.actions = @[DISCONNECT_HID_SCANNER_ACTION];
        
        self.HIDBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerHIDKeyboardMode];
        self.HIDBarCodeScanner.delegate = self;
        [self.HIDBarCodeScanner startScan];
        
        [self addBarcodeImage];

    }
    
}

- (void)stopBarcodeScanning {
    
    [self stopCameraScanner];
    [self stopHIDModeScanner];
    [self stopIOSModeScanner];
    
}

- (void)stopCameraScanner {
    
    [self.cameraBarCodeScanner stopScan];
    self.cameraBarCodeScanner = nil;
    self.navigationItem.leftBarButtonItem = nil;

}

- (void)stopIOSModeScanner {
    
    [self.iOSModeBarCodeScanner stopScan];
    self.iOSModeBarCodeScanner = nil;

}

- (void)stopHIDModeScanner {
    
    if (self.shouldUseHIDScanner) {
        
        if (![self.iOSModeBarCodeScanner isDeviceConnected]) [self removeBarcodeImage];
        
        [self.HIDBarCodeScanner stopScan];
        self.HIDBarCodeScanner = nil;
        
        self.actions = @[CONNECT_HID_SCANNER_ACTION];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];

    }
    
}

- (void)cameraBarCodeScannerButtonPressed {
    
    if (self.cameraBarCodeScanner.status == STMBarCodeScannerStarted) {
        
        [self.cameraBarCodeScanner stopScan];
        
    } else if (self.cameraBarCodeScanner.status == STMBarCodeScannerStopped) {
        
        [self.cameraBarCodeScanner startScan];
        
    }
    
}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type {

    if (self.scanEnabled && [self isInActiveTab]) {
        
        NSLog(@"barCodeScanner receiveBarCode: %@ withType: %d", barcode, type);
        [STMInventoryProcessController receiveBarcode:barcode withType:type source:self];

    }

}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error {
    NSLog(@"barCodeScanner receiveError: %@", error.localizedDescription);
}

- (void)deviceArrivalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if ([scanner isEqual:self.iOSModeBarCodeScanner]) {

        [self addBarcodeImage];
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE ARRIVAL", nil)];
        [self stopHIDModeScanner];
        
    }
    
}

- (void)deviceRemovalForBarCodeScanner:(STMBarCodeScanner *)scanner {

    if ([scanner isEqual:self.iOSModeBarCodeScanner]) {
        
        [self removeBarcodeImage];
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE REMOVAL", nil)];
        [self startHIDModeScanner];
        
    }

}


#pragma mark - STMInventoryControlling

- (void)didSelectInventoryBatch:(STMInventoryBatch *)inventoryBatch {
    
    self.currentlyProcessedBatch = inventoryBatch;
    
    if (self.itemsVC) {
        
        self.itemsVC.inventoryBatch = self.currentlyProcessedBatch;
        self.itemsVC.productionInfo = [self.currentlyProcessedBatch.stockBatch displayProductionInfo];
        
        if (![self.topViewController isEqual:self.itemsVC]) {
            [self pushViewController:self.itemsVC animated:YES];
        }
        
    } else {
        
        STMInventoryItemsVC *itemsVC = (STMInventoryItemsVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"inventoryItemsVC"];
        itemsVC.productionInfo = [self.currentlyProcessedBatch.stockBatch displayProductionInfo];
        itemsVC.inventoryBatch = self.currentlyProcessedBatch;
        
        [self pushViewController:itemsVC animated:YES];
        
    }

}

- (void)requestForArticleBarcode {

    [STMSoundController say:NSLocalizedString(@"CREATE NEW STOCK BATCH WITH ARTICLE BARCODE", nil)];

}

- (void)shouldSelectArticleFromArray:(NSArray <STMArticle *>*)articles lookingForBarcode:(NSString *)barcode {
    
    [self popToRootViewControllerAnimated:YES];
    
    [STMSoundController say:NSLocalizedString(@"SELECT ARTICLE", nil)];
    
    STMInventoryArticleSelectTVC *articleSelectTVC = [[STMInventoryArticleSelectTVC alloc] initWithStyle:UITableViewStyleGrouped];
    articleSelectTVC.articles = articles;
    articleSelectTVC.parentNC = self;
    articleSelectTVC.searchedBarcode = barcode;
    
    [self pushViewController:articleSelectTVC animated:YES];
    
}

- (void)shouldSetProductionInfoForArticle:(STMArticle *)article {
    
    [self popToRootViewControllerAnimated:YES];
    
    STMInventoryInfoSelectTVC *infoSelectTVC = [[STMInventoryInfoSelectTVC alloc] initWithStyle:UITableViewStyleGrouped];
    infoSelectTVC.article = article;
    infoSelectTVC.parentNC = self;
    
    [self pushViewController:infoSelectTVC animated:YES];
    
}

- (void)finishInventoryBatch {
    
    self.currentlyProcessedBatch = nil;
    [self popToRootViewControllerAnimated:YES];
    
}


#pragma mark -

- (void)selectArticle:(STMArticle *)article withSearchedBarcode:(NSString *)barcode {
    
    if (barcode) {
        
        STMArticleBarCode *articleBarcode = (STMArticleBarCode *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMArticleBarCode class]) isFantom:NO];
        articleBarcode.code = barcode;
        articleBarcode.article = article;
        
    }
    
    [self popToRootViewControllerAnimated:YES];
    [STMInventoryProcessController selectArticle:article source:self];
    
}

- (void)selectInfo:(STMArticleProductionInfo *)info {

    [self popToRootViewControllerAnimated:YES];
    [STMInventoryProcessController productionInfo:info.info setForArticle:info.article source:self];

}

- (void)cancelCurrentInventoryProcessing {
    [STMInventoryProcessController cancelCurrentInventoryProcessingWithSource:self];
}

- (void)doneCurrentInventoryProcessing {
    [STMInventoryProcessController doneCurrentInventoryProcessingWithSource:self];
}

- (void)editInventoryBatch:(STMInventoryBatch *)inventoryBatch {
    [STMInventoryProcessController editInventoryBatch:inventoryBatch];
}

- (void)deleteInventoryBatch:(STMInventoryBatch *)inventoryBatch {
    [STMInventoryProcessController removeInventoryBatch:inventoryBatch];
}


#pragma mark - view lifecycle

- (void)customInit {

    self.actions = @[CONNECT_HID_SCANNER_ACTION];

    self.scanEnabled = YES;
    [self startBarcodeScanning];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
