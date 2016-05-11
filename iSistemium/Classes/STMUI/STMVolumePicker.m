//
//  STMVolumePicker.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMVolumePicker.h"

#import "STMArticleController.h"


@implementation STMVolumePicker

- (NSArray *)currentPackageRels {
    return [STMArticleController packageRels];
}


@end
