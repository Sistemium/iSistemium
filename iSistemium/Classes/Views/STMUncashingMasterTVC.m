//
//  STMUncashingMasterTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingMasterTVC.h"
#import "STMUncashingSVC.h"
#import "STMConstants.h"
#import "STMCashing.h"
#import "STMUncashing.h"


@interface STMUncashingMasterTVC ()

@property (nonatomic, strong) STMUncashingSVC *splitVC;
@property (nonatomic, strong) STMCashingSumFRCD *cashingSumFRCD;
@property (nonatomic, strong) NSFetchedResultsController *cashingSumResultsController;

@end


//@interface STMCashingSumFRCD ()
//
//@end

#pragma mark - STMCashingSumFRCD

@implementation STMCashingSumFRCD

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.cashingSumTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
}

@end


#pragma mark - STMUncashingMasterTVC

@implementation STMUncashingMasterTVC

@synthesize resultsController = _resultsController;

- (STMUncashingSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMUncashingSVC class]]) {
            _splitVC = (STMUncashingSVC *)self.splitViewController;
        }
        
    }
    
    return _splitVC;
    
}

- (void)setCashingSum:(NSDecimalNumber *)cashingSum {
    
    if (_cashingSum != cashingSum) {
        
        self.splitVC.detailVC.handOverButton.enabled = (!self.splitVC.detailVC.uncashing && cashingSum.intValue == 0) ? NO : YES;
     
        _cashingSum = cashingSum;
        
    }
    
}

- (NSFetchedResultsController *)cashingSumResultsController {
    
    if (!_cashingSumResultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCashing class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"uncashing == %@", nil];
        _cashingSumResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _cashingSumResultsController.delegate = self.cashingSumFRCD;
        
    }
    
    return _cashingSumResultsController;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMUncashing class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)]];
//        request.predicate = [NSPredicate predicateWithFormat:@"ANY debts.summ != 0"];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}


#pragma mark - UITableView dataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 1;
        
    } else {
    
        if (self.resultsController.sections.count > 0) {
            
            id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section-1];
            return [sectionInfo numberOfObjects];
            
        } else {
            
            return 0;
            
        }

    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        
        return NSLocalizedString(@"ON HAND", nil);
        
    } else {

        id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section-1];

        if ([sectionInfo numberOfObjects] == 0) {
            
            return nil;
            
        } else {

            return NSLocalizedString(@"HAND OVER", nil);

        }

    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uncashingMasterCell" forIndexPath:indexPath];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    if (indexPath.section == 0) {
        
        NSDecimalNumber *cashSum = [NSDecimalNumber zero];
        
        for (STMCashing *cashing in self.cashingSumResultsController.fetchedObjects) {
            
            cashSum = [cashSum decimalNumberByAdding:cashing.summ];
            
        }
        
        self.cashingSum = cashSum;
                
        cell.textLabel.text = [numberFormatter stringFromNumber:self.cashingSum];
        cell.detailTextLabel.text = nil;
        
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        
        self.splitVC.detailVC.uncashing = nil;
        
    } else if (indexPath.section == 1) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section-1];
        STMUncashing *uncashing = sectionInfo.objects[indexPath.row];

        cell.textLabel.text = [numberFormatter stringFromNumber:uncashing.summ];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:uncashing.date];
        
    }
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = ACTIVE_BLUE_COLOR;
    
    cell.selectedBackgroundView = selectedBackgroundView;
    
    UIColor *highlightedTextColor = [UIColor whiteColor];
    
    cell.textLabel.highlightedTextColor = highlightedTextColor;
    cell.detailTextLabel.highlightedTextColor = highlightedTextColor;
    
    return cell;
    
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        self.splitVC.detailVC.uncashing = nil;
        
    } else {
    
        id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[indexPath.section-1];
        STMUncashing *uncashing = sectionInfo.objects[indexPath.row];
        
        self.splitVC.detailVC.uncashing = uncashing;

    }

    return indexPath;
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [self.insertedSectionIndexes addIndex:sectionIndex+1];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.deletedSectionIndexes addIndex:sectionIndex+1];
            break;
            
        default:
            ; // Shouldn't have a default
            break;
            
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSIndexPath *iPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+1];
    NSIndexPath *nPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section+1];
    
    if (type == NSFetchedResultsChangeInsert) {
        
        if ([self.insertedSectionIndexes containsIndex:nPath.section]) {
            return;
        }
        
        [self.insertedRowIndexPaths addObject:nPath];
        
    } else if (type == NSFetchedResultsChangeDelete) {
        
        if ([self.deletedSectionIndexes containsIndex:iPath.section]) {
            return;
        }
        
        [self.deletedRowIndexPaths addObject:iPath];
        
    } else if (type == NSFetchedResultsChangeMove) {
        
        if (![self.insertedSectionIndexes containsIndex:nPath.section]) {
            [self.insertedRowIndexPaths addObject:nPath];
        }
        
        if (![self.deletedSectionIndexes containsIndex:iPath.section]) {
            [self.deletedRowIndexPaths addObject:iPath];
        }
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        [self.updatedRowIndexPaths addObject:iPath];
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.cashingSumFRCD = [[STMCashingSumFRCD alloc] init];
    self.cashingSumFRCD.cashingSumTableView = self.tableView;
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = NSLocalizedString(@"UNCASHING", nil);
    
    NSError *error;
    
    if (![self.cashingSumResultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
    }

    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
    }
    
}


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
    [self customInit];

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
