//
//  STMMessage.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMMessage : STMComment

@property (nonatomic, retain) NSDate * cts;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * body;

@end
