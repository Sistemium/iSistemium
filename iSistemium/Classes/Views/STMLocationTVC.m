//
//  STMLocationTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMLocationTVC.h"

@interface STMLocationTVC() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end


@implementation STMLocationTVC

- (void)setSession:(id <STMSession>)session {
    
    if (session != _session) {
        _session = session;
        self.resultsController = nil;
        NSError *error;
        if (![self.resultsController performFetch:&error]) {
            NSLog(@"performFetch error %@", error);
        } else {
            
        }
    }
    
}


@end
