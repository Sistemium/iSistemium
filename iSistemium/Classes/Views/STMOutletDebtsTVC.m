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
#import "STMDebt.h"
#import "STMDebtsCombineVC.h"


@interface STMOutletDebtsTVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STMDebtsCombineVC *parentVC;

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;


@end

@implementation STMOutletDebtsTVC

- (STMDebtsCombineVC *)parentVC {
    
    return (STMDebtsCombineVC *)self.parentViewController;
    
}

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

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    } else {
        [self.tableView reloadData];
    }
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDebt class])];
        
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *ndocSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndoc" ascending:YES selector:@selector(compare:)];
        
        request.sortDescriptors = @[dateSortDescriptor, ndocSortDescriptor];
        request.predicate = [NSPredicate predicateWithFormat:@"outlet == %@", self.outlet];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
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
    
    STMDebt *debt = sectionInfo.objects[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", debt.summ];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *debtDate = [dateFormatter stringFromDate:debt.date];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DEBT DETAILS", nil), debt.ndoc, debtDate, debt.summOrigin];
    
    return cell;
    
}


#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
