//
//  STMRemoteController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMRemoteController.h"
#import "STMSessionManager.h"
#import "STMSession.h"


@implementation STMRemoteController

+ (STMSession *)session {
    return [STMSessionManager sharedManager].currentSession;
}

+ (void)receiveRemoteCommands:(NSDictionary *)remoteCommands {
    [self parseCommands:remoteCommands];
}

+ (void)parseCommands:(NSDictionary *)commands {
    
    for (NSString *className in commands.allKeys) {
        
        Class theClass = NSClassFromString(className);
        
        if (theClass) {
            
            id payload = commands[className];
            
            if ([payload isKindOfClass:[NSString class]]) {
                
                // payload is method name
                [self performMethod:payload onClass:theClass];
                
            } else if ([payload isKindOfClass:[NSDictionary class]]) {
                
                // payload is dic of method:object
                [self parseCommands:payload];
                
            } else {
                
                NSString *logMessage = [NSString stringWithFormat:@"notification's payload for %@ is not a string or dictionary", className];
                [STMLogger.sharedLogger saveLogMessageWithText:logMessage type:@"error"];
                
            }
            
        } else {
            
            NSString *logMessage = [NSString stringWithFormat:@"%@ does not exist", className];
            [STMLogger.sharedLogger saveLogMessageWithText:logMessage type:@"error"];
            
        }
        
    }

}

+ (void)performMethod:(NSString *)methodName onClass:(Class)theClass {
    
    SEL selector = NSSelectorFromString(methodName);
    
    if ([theClass respondsToSelector:selector]) {

        [self noWarningPerformSelector:selector forObject:theClass];
        
    } else if ([theClass instancesRespondToSelector:selector]) {
        
        id instance = [self instanceForClass:theClass];
        [self noWarningPerformSelector:selector forObject:instance];
        
    } else {
        
        NSString *logMessage = [NSString stringWithFormat:@"%@ have no method %@", NSStringFromClass([theClass class]), methodName];
        [STMLogger.sharedLogger saveLogMessageWithText:logMessage type:@"error"];

    }

}

+ (id)instanceForClass:(Class)class {

    if ([class isSubclassOfClass:[STMSyncer class]]) {
        
        return self.session.syncer;
        
    } else if ([class isSubclassOfClass:[STMBatteryTracker class]]) {
        
        return self.session.batteryTracker;
        
    } else if ([class isSubclassOfClass:[STMLocationTracker class]]) {

        return self.session.locationTracker;

    } else {
        
        return nil;
        
    }
}

+ (void)noWarningPerformSelector:(SEL)selector forObject:(id)object {
    
    IMP imp = [object methodForSelector:selector];
    id (*func)(id, SEL) = (void *)imp;
    func(object, selector);

}

@end
