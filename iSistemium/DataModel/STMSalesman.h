//
//  STMSalesman.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMOutlet, STMPhotoReport;

@interface STMSalesman : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *outlets;
@property (nonatomic, retain) NSSet *photoreports;
@end

@interface STMSalesman (CoreDataGeneratedAccessors)

- (void)addOutletsObject:(STMOutlet *)value;
- (void)removeOutletsObject:(STMOutlet *)value;
- (void)addOutlets:(NSSet *)values;
- (void)removeOutlets:(NSSet *)values;

- (void)addPhotoreportsObject:(STMPhotoReport *)value;
- (void)removePhotoreportsObject:(STMPhotoReport *)value;
- (void)addPhotoreports:(NSSet *)values;
- (void)removePhotoreports:(NSSet *)values;

@end
