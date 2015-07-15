//
//  STMShipmentPosition+custom.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentPosition+custom.h"
#import "STMArticle.h"
#import "STMFunctions.h"


@implementation STMShipmentPosition (custom)

- (BOOL)wasProcessed {
    return (self.isProcessed) ? self.isProcessed.boolValue : NO;
}

- (NSString *)volumeText {
    
    return [STMFunctions volumeStringWithVolume:self.volume.integerValue andPackageRel:self.article.packageRel.integerValue];
    
}


@end
