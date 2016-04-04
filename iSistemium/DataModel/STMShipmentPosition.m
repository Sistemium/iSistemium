//
//  STMShipmentPosition.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMShipmentPosition.h"
#import "STMArticle.h"
#import "STMShipment.h"

#import "STMFunctions.h"


@implementation STMShipmentPosition

- (BOOL)wasProcessed {
    return (self.isProcessed) ? self.isProcessed.boolValue : NO;
}

- (NSString *)volumeText {
    return [STMFunctions volumeStringWithVolume:self.volume.integerValue andPackageRel:self.article.packageRel.integerValue];
}


@end
