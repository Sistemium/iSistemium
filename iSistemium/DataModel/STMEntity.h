//
//  STMEntity.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMEntity : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * roleName;
@property (nonatomic, retain) NSString * roleOwner;
@property (nonatomic, retain) NSNumber * lifeTime;
@property (nonatomic, retain) NSString * eTag;

@end