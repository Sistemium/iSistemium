//
//  STMComment.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMDatum.h"

@class STMDatum;

@interface STMComment : STMDatum

@property (nonatomic, retain) NSString * commentText;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) STMDatum *owner;

@end
