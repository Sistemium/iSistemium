//
//  STMBarCodeScannerDelegate.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMBarCodeScanner;

@protocol STMBarCodeScannerDelegate <NSObject>

@required

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner;

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode;
- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error;


@end
