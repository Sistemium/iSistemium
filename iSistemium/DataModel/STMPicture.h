//
//  STMPicture.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMPicture : STMComment

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imageFormat;
@property (nonatomic, retain) NSString * name;

@end
