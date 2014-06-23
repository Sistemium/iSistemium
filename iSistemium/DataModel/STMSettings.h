//
//  STMSettings.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMSettings : STMComment

@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * value;

@end
