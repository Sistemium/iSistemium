//
//  STMUncashingPlaceController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingPlaceController.h"
#import "STMSessionManager.h"
#import "STMDocument.h"

@interface STMUncashingPlaceController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, weak) STMDocument *document;

@end


@implementation STMUncashingPlaceController

+ (STMUncashingPlaceController *)sharedController {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedController = nil;
    
    dispatch_once(&pred, ^{
        _sharedController = [[self alloc] init];
    });
    
    return _sharedController;
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [self performFetch];
        
    }
    
    return self;
}

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
}


- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMUncashingPlace class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
//        request.predicate = [NSPredicate predicateWithFormat:@"name != %@", nil];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)performFetch {
    
    NSError *error;
    
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    }

}

- (NSArray *)uncashingPlaces {
    
    return self.resultsController.fetchedObjects;
    
}

@end
