//
//  STMStock.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticle;

@interface STMStock : STMComment

@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSString * displayVolume;
@property (nonatomic, retain) STMArticle *article;

@end
