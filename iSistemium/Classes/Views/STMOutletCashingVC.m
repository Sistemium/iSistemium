//
//  STMOutletCashingVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMOutletCashingVC.h"
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMCashing.h"
#import "STMDebt.h"

@interface STMOutletCashingVC () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;


@end

@implementation STMOutletCashingVC

@synthesize outlet = _outlet;


- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        [self performFetch];

    }
    
}

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (NSMutableIndexSet *)deletedSectionIndexes {
    
    if (!_deletedSectionIndexes) {
        _deletedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    
    return _deletedSectionIndexes;
    
}

- (NSMutableIndexSet *)insertedSectionIndexes {
    
    if (!_insertedSectionIndexes) {
        _insertedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    
    return _insertedSectionIndexes;
    
}

- (NSMutableArray *)deletedRowIndexPaths {
    
    if (!_deletedRowIndexPaths) {
        _deletedRowIndexPaths = [NSMutableArray array];
    }
    
    return _deletedRowIndexPaths;
    
}

- (NSMutableArray *)insertedRowIndexPaths {
    
    if (!_insertedRowIndexPaths) {
        _insertedRowIndexPaths = [NSMutableArray array];
    }
    
    return _insertedRowIndexPaths;
    
}

- (NSMutableArray *)updatedRowIndexPaths {
    
    if (!_updatedRowIndexPaths) {
        _updatedRowIndexPaths = [NSMutableArray array];
    }
    
    return _updatedRowIndexPaths;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCashing class])];
        
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[dateSortDescriptor];
        request.predicate = [NSPredicate predicateWithFormat:@"outlet == %@", self.outlet];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"date" cacheName:nil];
        
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
        [self.tableView reloadData];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.resultsController.sections.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
    return [sectionInfo numberOfObjects];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:section];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    NSDate *date = [dateFormatter dateFromString:[sectionInfo name]];

    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *cashingDate = [dateFormatter stringFromDate:date];
    
    NSDecimalNumber *summ = [NSDecimalNumber zero];
    
    for (STMCashing *cashing in sectionInfo.objects) {
        
        summ = [summ decimalNumberByAdding:cashing.summ];
        
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumFractionDigits = 2;

    NSString *sumString = [numberFormatter stringFromNumber:summ];
    
    NSString *title = [NSString stringWithFormat:@"%@ %@", cashingDate, sumString];
    
    return title;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cashingDetailsCell" forIndexPath:indexPath];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    
    STMCashing *cashing = sectionInfo.objects[indexPath.row];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumFractionDigits = 2;

    NSString *sumString = [numberFormatter stringFromNumber:cashing.summ];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", sumString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *debtDate = [dateFormatter stringFromDate:cashing.debt.date];
    
    NSString *summOriginString = [numberFormatter stringFromNumber:cashing.debt.summOrigin];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DEBT DETAILS", nil), cashing.debt.ndoc, debtDate, summOriginString];
    
    return cell;
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteSections:self.deletedSectionIndexes withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertSections:self.insertedSectionIndexes withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView deleteRowsAtIndexPaths:self.deletedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:self.insertedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    self.insertedSectionIndexes = nil;
    self.deletedSectionIndexes = nil;
    self.deletedRowIndexPaths = nil;
    self.insertedRowIndexPaths = nil;
    self.updatedRowIndexPaths = nil;
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [self.insertedSectionIndexes addIndex:sectionIndex];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.deletedSectionIndexes addIndex:sectionIndex];
            break;
            
        default:
            ; // Shouldn't have a default
            break;
            
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    if (type == NSFetchedResultsChangeInsert) {
        
        if ([self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
            return;
        }
        
        [self.insertedRowIndexPaths addObject:newIndexPath];
        
    } else if (type == NSFetchedResultsChangeDelete) {
        
        if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
            return;
        }
        
        [self.deletedRowIndexPaths addObject:indexPath];
        
    } else if (type == NSFetchedResultsChangeMove) {
        
        if (![self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
            [self.insertedRowIndexPaths addObject:newIndexPath];
        }
        
        if (![self.deletedSectionIndexes containsIndex:indexPath.section]) {
            [self.deletedRowIndexPaths addObject:indexPath];
        }
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        [self.updatedRowIndexPaths addObject:indexPath];
        
    }
    
}



#pragma mark - view lifecycle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
