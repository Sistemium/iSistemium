//
//  STMComment.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMDatum.h"

@class STMDatum;

@interface STMComment : STMDatum

@property (nonatomic, retain) NSString * commentText;
@property (nonatomic, retain) STMDatum *owner;

@end
