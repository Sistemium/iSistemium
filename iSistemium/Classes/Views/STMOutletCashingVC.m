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

@end

@implementation STMOutletCashingVC

@synthesize outlet = _outlet;


- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        [self performFetch];
        [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];

    }
    
}

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
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
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSDate *date = [dateFormatter dateFromString:[sectionInfo name]];
    
    NSString *cashingDate = [dateFormatter stringFromDate:date];
    
    NSDecimalNumber *summ = 0;
    
    for (STMCashing *cashing in sectionInfo.objects) {
        
        summ = [summ decimalNumberByAdding:cashing.summ];
        
    }
    
    NSString *title = [NSString stringWithFormat:@"%@ %@", cashingDate, summ];
    
    return title;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cashingDetailsCell" forIndexPath:indexPath];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    
    STMCashing *cashing = sectionInfo.objects[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", cashing.summ];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *debtDate = [dateFormatter stringFromDate:cashing.debt.date];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DEBT DETAILS", nil), cashing.debt.ndoc, debtDate, cashing.debt.summOrigin];
    
    return cell;
    
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
