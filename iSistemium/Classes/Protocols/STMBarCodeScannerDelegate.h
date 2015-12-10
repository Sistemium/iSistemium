//
//  STMBarCodeScannerDelegate.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STMBarCodeScannedType) {
    STMBarCodeTypeUnknown,
    STMBarCodeTypeArticle,
    STMBarCodeTypeExciseStamp,
    STMBarCodeTypeStockBatch
};

@class STMBarCodeScanner;

@protocol STMBarCodeScannerDelegate <NSObject>

@required

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner;

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type;
- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error;


@optional

- (void)deviceArrivalForBarCodeScanner:(STMBarCodeScanner *)scanner;
- (void)deviceRemovalForBarCodeScanner:(STMBarCodeScanner *)scanner;


@end
