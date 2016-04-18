//
//  STMVolumePicker+category.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMVolumePicker+category.h"

#import "STMArticleController.h"


@implementation STMVolumePicker (category)

- (NSArray *)currentPackageRels {
    return [STMArticleController packageRels];
}


@end
