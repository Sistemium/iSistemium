//
//  STMEntity.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMEntity : STMComment

@property (nonatomic, retain) NSString * eTag;
@property (nonatomic, retain) NSNumber * lifeTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * roleName;
@property (nonatomic, retain) NSString * roleOwner;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * workflow;

@end
