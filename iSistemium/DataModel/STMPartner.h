//
//  STMPartner.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMOutlet;

@interface STMPartner : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *outlets;
@end

@interface STMPartner (CoreDataGeneratedAccessors)

- (void)addOutletsObject:(STMOutlet *)value;
- (void)removeOutletsObject:(STMOutlet *)value;
- (void)addOutlets:(NSSet *)values;
- (void)removeOutlets:(NSSet *)values;

@end
