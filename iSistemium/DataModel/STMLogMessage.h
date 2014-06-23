//
//  STMLogMessage.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMLogMessage : STMComment

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * type;

@end
