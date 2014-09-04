//
//  SMTClientData.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 04/09/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMClientData : STMComment

@property (nonatomic, retain) NSData * deviceToken;

@end
