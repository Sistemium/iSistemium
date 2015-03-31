//
//  STMLogMessagesMasterTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMLogMessagesMasterTVC.h"
#import <CoreData/CoreData.h>
#import "STMLogMessage+dayAsString.h"
#import "STMLogMessagesSVC.h"

@interface STMLogMessagesMasterTVC ()

@property (nonatomic, weak) STMLogMessagesSVC *splitVC;


@end


@implementation STMLogMessagesMasterTVC

@synthesize resultsController = _resultsController;


- (STMLogMessagesSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMLogMessagesSVC class]]) {
            
            _splitVC = (STMLogMessagesSVC *)self.splitViewController;
            
        }
        
    }
    
    return _splitVC;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMLogMessage class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:NO selector:@selector(compare:)]];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.mainContext sectionNameKeyPath:@"dayAsString" cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
//        [self.tableView reloadData];
        
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[self.resultsController sections] count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"masterLogCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    id <NSFetchedResultsSectionInfo> sectionInfo = [self.resultsController sections][indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    
    NSDate *date = [dateFormatter dateFromString:[sectionInfo name]];
    
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    cell.textLabel.text = [dateFormatter stringFromDate:date];
    
    return cell;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    id <NSFetchedResultsSectionInfo> sectionInfo = [self.resultsController sections][indexPath.row];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    
    NSDate *date = [dateFormatter dateFromString:[sectionInfo name]];
    
    self.splitVC.detailTVC.selectedDate = date;
    
    return indexPath;
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView reloadData];
            break;
            
        default:

            break;
            
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self performFetch];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

@end
