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
#import "STMDebtsSVC.h"
#import "STMRecordStatusController.h"
#import "STMObjectsController.h"

@interface STMOutletCashingTV : UITableView

@end


@interface STMOutletCashingVC () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;
@property (weak, nonatomic) IBOutlet STMOutletCashingTV *tableView;

@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *updatedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;

@property (nonatomic) BOOL wasChanged;

@end


@implementation STMOutletCashingTV

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    if (self.editing && !editing) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"quitEditingMode" object:self];
        
    }
    
    [super setEditing:editing animated:animated];
    
}

@end



@implementation STMOutletCashingVC

@synthesize outlet = _outlet;


- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        [self.parentViewController setEditing:NO animated:YES];
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

- (NSMutableIndexSet *)updatedSectionIndexes {
    
    if (!_updatedSectionIndexes) {
        _updatedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    
    return _updatedSectionIndexes;
    
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
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"dayAsString" cacheName:nil];
        
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

- (void)editingButtonPressed:(NSNotification *)notification {
    
    BOOL editing = [(notification.userInfo)[@"editing"] boolValue];
    
    [self.tableView setEditing:editing animated:YES];
    
}

- (void)quitEditingMode {
    
    if (self.wasChanged) {

        self.wasChanged = NO;
        [STMSessionManager sharedManager].currentSession.syncer.syncerState = STMSyncerSendDataOnce;
        
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
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.resultsController sections][section];
    
    NSString *cashingDate = [sectionInfo name];

    NSDecimalNumber *summ = [NSDecimalNumber zero];
    
    for (STMCashing *cashing in sectionInfo.objects) {
        
        summ = [summ decimalNumberByAdding:cashing.summ];
        
    }
    
    NSNumberFormatter *numberFormatter = [STMFunctions decimalMinTwoDigitFormatter];

    NSString *sumString = [numberFormatter stringFromNumber:summ];
    
    NSString *title = [NSString stringWithFormat:@"%@ %@", cashingDate, sumString];
    
    return title;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cashingDetailsCell" forIndexPath:indexPath];
    
    STMCashing *cashing = [self.resultsController objectAtIndexPath:indexPath];
    
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];

    NSString *sumString = [[numberFormatter stringFromNumber:cashing.summ] stringByAppendingString:@" "];

    UIColor *textColor = cashing.uncashing ? [UIColor darkGrayColor] : [UIColor blackColor];
    UIColor *backgroundColor = [UIColor clearColor];
    UIFont *font = cell.textLabel.font;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSBackgroundColorAttributeName: backgroundColor,
                                 NSForegroundColorAttributeName: textColor
                                 };
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:sumString attributes:attributes];
    
    if (cashing.commentText) {
        
        font = cell.detailTextLabel.font;
        attributes = @{NSFontAttributeName: font};
        
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:cashing.commentText attributes:attributes]];

    }
    
    cell.textLabel.attributedText = text;
    
    
    NSDateFormatter *dateFormatter = [STMFunctions dateMediumNoTimeFormatter];    
    NSString *debtDate = [dateFormatter stringFromDate:cashing.debt.date];
    
    NSString *summOriginString = [numberFormatter stringFromNumber:cashing.debt.summOrigin];
    
    NSString *detailText = [NSString stringWithFormat:NSLocalizedString(@"DEBT DETAILS", nil), cashing.debt.ndoc, debtDate, summOriginString];
    
    backgroundColor = [UIColor clearColor];
    font = cell.detailTextLabel.font;
    
    attributes = @{
                                 NSFontAttributeName: font,
                                 NSBackgroundColorAttributeName: backgroundColor,
                                 NSForegroundColorAttributeName: textColor
                                 };

    text = [[NSMutableAttributedString alloc] initWithString:detailText attributes:attributes];
    
    
    if (cashing.debt.responsibility) {
        
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attributes]];
        
        UIColor *backgroundColor = [UIColor grayColor];
        UIColor *textColor = [UIColor whiteColor];
        
        NSDictionary *attributes = @{
                       NSFontAttributeName: font,
                       NSBackgroundColorAttributeName: backgroundColor,
                       NSForegroundColorAttributeName: textColor
                       };
        
        NSString *responsibilityString = [NSString stringWithFormat:@" %@ ", cashing.debt.responsibility];
        
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:responsibilityString attributes:attributes]];

    }
    
    cell.detailTextLabel.attributedText = text;

    return cell;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCashing *cashing = [self.resultsController objectAtIndexPath:indexPath];
    
    if (cashing.uncashing) {
        
        return UITableViewCellEditingStyleNone;
        
    } else {
        
        return UITableViewCellEditingStyleDelete;
        
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        STMCashing *cashing = [self.resultsController objectAtIndexPath:indexPath];
        
        [STMObjectsController createRecordStatusAndRemoveObject:cashing];
                
        if ([self.splitViewController isKindOfClass:[STMDebtsSVC class]]) {
            
            STMDebtsSVC *splitVC = (STMDebtsSVC *)self.splitViewController;
            NSIndexPath *indexPath = [splitVC.masterVC.resultsController indexPathForObject:self.outlet];
            [splitVC.masterVC.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            
        }

    
    }
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteSections:self.deletedSectionIndexes withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertSections:self.insertedSectionIndexes withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadSections:self.updatedSectionIndexes withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView deleteRowsAtIndexPaths:self.deletedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:self.insertedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    self.insertedSectionIndexes = nil;
    self.deletedSectionIndexes = nil;
    self.updatedSectionIndexes = nil;
    
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
            
//        case NSFetchedResultsChangeUpdate:
//            [self.updatedSectionIndexes addIndex:sectionIndex];
//            break;
            
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
        
        [self.updatedSectionIndexes addIndex:newIndexPath.section];
        
    } else if (type == NSFetchedResultsChangeDelete) {
        
        if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
            return;
        }
        
        [self.deletedRowIndexPaths addObject:indexPath];
        
        if (newIndexPath) {
            [self.updatedSectionIndexes addIndex:newIndexPath.section];
        }
        
        self.wasChanged = YES;
        
    } else if (type == NSFetchedResultsChangeMove) {
        
        if (![self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
            [self.insertedRowIndexPaths addObject:newIndexPath];
        }
        
        if (![self.deletedSectionIndexes containsIndex:indexPath.section]) {
            [self.deletedRowIndexPaths addObject:indexPath];
        }
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        [self.updatedRowIndexPaths addObject:indexPath];
        
        [self.updatedSectionIndexes addIndex:newIndexPath.section];
        
    }
    
}



#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingButtonPressed:) name:@"editingButtonPressed" object:self.parentViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitEditingMode) name:@"quitEditingMode" object:self.tableView];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    [self addObservers];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    [self.tableView setEditing:YES animated:YES];

}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

    [self.parentViewController setEditing:NO animated:YES];

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
