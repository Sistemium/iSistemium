//
//  STMOutletDebtsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMOutletDebtsTVC.h"
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMDebt+Cashing.h"
#import "STMCashing.h"
#import "STMDebtsCombineVC.h"
#import "STMConstants.h"

@interface STMOutletDebtsTVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STMDebtsCombineVC *parentVC;

//@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;


@end

@implementation STMOutletDebtsTVC

@synthesize resultsController = _resultsController;

- (STMDebtsCombineVC *)parentVC {
    
    return (STMDebtsCombineVC *)self.parentViewController;
    
}

- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        [self performFetch];
        
    }
    
}

/*
- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}
*/
 

- (NSDecimalNumber *)totalSum {
    
    if (!_totalSum) {
        
        NSDecimalNumber *totalSum = [NSDecimalNumber zero];
        
        for (STMDebt *debt in self.resultsController.fetchedObjects) {
            
            totalSum = [totalSum decimalNumberByAdding:debt.calculatedSum];
            
        }
        
//        NSLog(@"totalSum %@", totalSum);
        
        _totalSum = totalSum;
        
    }
    
    return _totalSum;
    
}

- (void)performFetch {
    
    self.resultsController = nil;
    self.totalSum = nil;
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        [self.tableView setEditing:NO animated:YES];
        [self.tableView reloadData];
                
    }
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDebt class])];
        
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *ndocSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndoc" ascending:YES selector:@selector(compare:)];
        
        request.sortDescriptors = @[dateSortDescriptor, ndocSortDescriptor];
        request.predicate = [NSPredicate predicateWithFormat:@"outlet == %@ AND calculatedSum != %@", self.outlet, [NSDecimalNumber zero]];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}


- (void)updateRowWithDebt:(STMDebt *)debt {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:debt];
    
    if ([self.tableView cellForRowAtIndexPath:indexPath]) {
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"debtDetailsCell" forIndexPath:indexPath];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumFractionDigits = 2;

    STMDebt *debt = sectionInfo.objects[indexPath.row];
    
    NSString *debtSumString = [numberFormatter stringFromNumber:debt.calculatedSum];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", debtSumString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *debtDate = [dateFormatter stringFromDate:debt.date];
    NSString *debtSumOriginString = [numberFormatter stringFromNumber:debt.summOrigin];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DEBT DETAILS", nil), debt.ndoc, debtDate, debtSumOriginString];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([[self.parentVC.controlsVC.debtsDictionary allKeys] containsObject:debt.xid]) {
        
        NSDecimalNumber *cashingSum = [self.parentVC.controlsVC.debtsDictionary objectForKey:debt.xid][1];
        
        if ([cashingSum compare:debt.summ] == NSOrderedAscending) {
            
            [cell setTintColor:STM_LIGHT_BLUE_COLOR];
            
        } else {
        
            [cell setTintColor:ACTIVE_BLUE_COLOR];

        }
        
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
//    } else if (debt.cashings.count != 0) {
//            
//        NSDecimalNumber *cashingSum = [NSDecimalNumber zero];
//        
//        for (STMCashing *cashing in debt.cashings) {
//            cashingSum = [cashingSum decimalNumberByAdding:cashing.summ];
//        }
//
//        if ([cashingSum compare:debt.summ] == NSOrderedAscending) {
//            
//            [cell setTintColor:STM_LIGHT_BLUE_COLOR];
//            
//        } else {
//            
//            [cell setTintColor:ACTIVE_BLUE_COLOR];
//            
//        }
//        
//        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    } else {
    
        [cell setTintColor:STM_LIGHT_LIGHT_GREY_COLOR];
        
    }
    
    return cell;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView.editing) {
        
        return UITableViewCellEditingStyleNone;

    } else {
        
        return UITableViewCellEditingStyleDelete;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {

    return NO;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.editing) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];        
        [cell setTintColor:ACTIVE_BLUE_COLOR];

        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
        STMDebt *debt = sectionInfo.objects[indexPath.row];

        [self.parentVC.controlsVC addCashing:debt];
        
    }
    
    return indexPath;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView.editing) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setTintColor:STM_LIGHT_LIGHT_GREY_COLOR];
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
        STMDebt *debt = sectionInfo.objects[indexPath.row];
        
        [self.parentVC.controlsVC removeCashing:debt];
        
    }

    return indexPath;
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView setTintColor:STM_LIGHT_LIGHT_GREY_COLOR];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.clearsSelectionOnViewWillAppear = NO;
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self customInit];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
//    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
