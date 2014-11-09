//
//  STMUncashing.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMCashing, STMUncashingPicture;

@interface STMUncashing : STMComment

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDecimalNumber * summ;
@property (nonatomic, retain) NSDecimalNumber * summOrigin;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *cashings;
@property (nonatomic, retain) NSSet *pictures;
@end

@interface STMUncashing (CoreDataGeneratedAccessors)

- (void)addCashingsObject:(STMCashing *)value;
- (void)removeCashingsObject:(STMCashing *)value;
- (void)addCashings:(NSSet *)values;
- (void)removeCashings:(NSSet *)values;

- (void)addPicturesObject:(STMUncashingPicture *)value;
- (void)removePicturesObject:(STMUncashingPicture *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

@end
