//
//  STMDocument.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface STMDocument : UIManagedDocument

@property (nonatomic, strong, readonly) NSManagedObjectModel *myManagedObjectModel;
@property (nonatomic, strong) NSString *uid;

+ (STMDocument *)documentWithUID:(NSString *)uid
                          iSisDB:(NSString *)iSisDB
                   dataModelName:(NSString *)dataModelName
                          prefix:(NSString *)prefix;

+ (void)openDocument:(STMDocument *)document;

- (void)saveDocument:(void (^)(BOOL success))completionHandler;

@end
