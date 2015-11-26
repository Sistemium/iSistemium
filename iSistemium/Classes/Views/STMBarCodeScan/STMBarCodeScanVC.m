//
//  STMBarCodeScanVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMBarCodeScanVC.h"

#import "STMBarCodeScanner.h"

#import "STMConstants.h"
#import "STMSessionManager.h"
#import "STMDataModel.h"
#import "STMNS.h"


@interface STMBarCodeScanVC () <STMBarCodeScannerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *articlePriceLabel;

@property (nonatomic, strong) STMBarCodeScanner *cameraScanner;
@property (nonatomic, strong) STMBarCodeScanner *HIDScanner;


@end


@implementation STMBarCodeScanVC

- (IBAction)cameraButtonPressed:(id)sender {
    
    if (self.HIDScanner.status == STMBarCodeScannerStarted) {
        [self.HIDScanner stopScan];
    }
    
    [self.cameraScanner startScan];
    
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


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode {
    
    if (scanner == self.cameraScanner) {
        [self.HIDScanner startScan];
    }
    
    [self searchBarCode:barcode];
    
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error {
    NSLog(@"barCodeScanner receiveError: %@", error.localizedDescription);
}

- (void)deviceArrivalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
}

- (void)deviceRemovalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.cameraScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerCameraMode];
    self.cameraScanner.delegate = self;
    
    self.HIDScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerHIDKeyboardMode];
    self.HIDScanner.delegate = self;
    [self.HIDScanner startScan];
    
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
