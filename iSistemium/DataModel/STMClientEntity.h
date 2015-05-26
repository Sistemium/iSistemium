//
//  STMClientEntity.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMClientEntity : STMComment

@property (nonatomic, retain) NSString * eTag;
@property (nonatomic, retain) NSString * name;

@end
