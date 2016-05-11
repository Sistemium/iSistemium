//
//  STMAuthController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMAuthController.h"

#import "STMSessionManager.h"


@implementation STMAuthController

- (STMCoreSessionManager *)sessionManager {
    return [STMSessionManager sharedManager];
}


@end
