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

#import "STMInventoryController.h"
#import "STMInventoryControlling.h"

#import "STMInventoryArticleSelectTVC.h"


@interface STMInventoryNC () <STMBarCodeScannerDelegate, STMInventoryControlling>

@property (nonatomic, strong) STMBarCodeScanner *cameraBarCodeScanner;
@property (nonatomic, strong) STMBarCodeScanner *HIDBarCodeScanner;


@end


@implementation STMInventoryNC

- (BOOL)isInActiveTab {
    return [self.tabBarController.selectedViewController isEqual:self];
}


#pragma mark - barcode scanning

- (void)startBarcodeScanning {
    
    if ([STMBarCodeScanner isCameraAvailable]) {
        
        self.cameraBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerCameraMode];
        self.cameraBarCodeScanner.delegate = self;
        
        STMBarButtonItem *cameraButton = [[STMBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                        target:self
                                                                                        action:@selector(cameraBarCodeScannerButtonPressed)];
        
        self.navigationItem.leftBarButtonItem = cameraButton;
        
    }
    
//    [self barCodeScanner:nil receiveBarCode:@"10000412"];
    
    self.HIDBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerHIDKeyboardMode];
    self.HIDBarCodeScanner.delegate = self;
    [self.HIDBarCodeScanner startScan];

}

- (void)stopBarcodeScanning {
    
    [self.cameraBarCodeScanner stopScan];
    self.cameraBarCodeScanner = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
    [self.HIDBarCodeScanner stopScan];
    self.HIDBarCodeScanner = nil;
    
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
        [STMInventoryController receiveBarcode:barcode withType:type source:self];

    }

}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error {
    NSLog(@"barCodeScanner receiveError: %@", error.localizedDescription);
}


#pragma mark - STMInventoryControlling

- (void)shouldSelectArticleFromArray:(NSArray <STMArticle *>*)articles {
    
    [self popToRootViewControllerAnimated:YES];

    STMInventoryArticleSelectTVC *articleSelectTVC = [[STMInventoryArticleSelectTVC alloc] initWithStyle:UITableViewStyleGrouped];
    articleSelectTVC.articles = articles;
    articleSelectTVC.parentNC = self;
    
    [self pushViewController:articleSelectTVC animated:YES];
    
}

- (void)shouldSetProductionInfoForArticle:(STMArticle *)article {
    
}

- (void)didSuccessfullySelectArticle:(STMArticle *)article {
    
    if (self.itemsVC) {
        
        self.itemsVC.inventoryArticle = article;
        self.itemsVC.inventoryBatch = nil;
        
    } else {
        
        STMInventoryItemsVC *itemsVC = (STMInventoryItemsVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"inventoryItemsVC"];
        itemsVC.inventoryArticle = article;

        [self pushViewController:itemsVC animated:YES];
        
    }
    
}


#pragma mark -

- (void)selectArticle:(STMArticle *)article {
    
    [self popToRootViewControllerAnimated:YES];
    [STMInventoryController selectArticle:article source:self];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
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
