//
//  STMSingleton.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDocument.h"
#import "STMObjectsController.h"
#import "STMSessionManager.h"
#import "STMSessionManagement.h"

@interface STMSingleton : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) STMDocument *document;


@end
