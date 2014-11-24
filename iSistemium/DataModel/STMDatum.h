//
//  STMDatum.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STMComment;

@interface STMDatum : NSManagedObject

@property (nonatomic, retain) NSDate * deviceCts;
@property (nonatomic, retain) NSDate * deviceTs;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * lts;
@property (nonatomic, retain) NSDate * sqts;
@property (nonatomic, retain) NSDate * sts;
@property (nonatomic, retain) NSData * xid;
@property (nonatomic, retain) NSNumber * isFantom;
@property (nonatomic, retain) NSSet *comments;
@end

@interface STMDatum (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(STMComment *)value;
- (void)removeCommentsObject:(STMComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
