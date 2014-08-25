//
//  STMUncashingDetailsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingDetailsTVC.h"
#import "STMDebt.h"
#import "STMCashing.h"
#import "STMConstants.h"
#import "STMHandOverPopoverVC.h"
#import "STMUncashingSVC.h"

@interface STMUncashingDetailsTVC ()

@property (nonatomic, strong) STMUncashingSVC *splitVC;

@property (nonatomic, strong) UIPopoverController *handOverPopover;

@end

@implementation STMUncashingDetailsTVC

@synthesize resultsController = _resultsController;

- (STMUncashingSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMUncashingSVC class]]) {
            _splitVC = (STMUncashingSVC *)self.splitViewController;
        }
        
    }
    
    return _splitVC;
    
}

- (void)setUncashing:(STMUncashing *)uncashing {
    
//    NSLog(@"setUncashing %@", uncashing);
    
    if (_uncashing != uncashing) {
        
        _uncashing = uncashing;
        
        if (_uncashing) {
            
            self.handOverButton.enabled = NO;
            
        } else {
            
            self.handOverButton.enabled = (self.splitVC.masterVC.cashingSum.intValue == 0) ? NO : YES;

        }
        
        [self performFetch];
        
    }
    
}

- (UIPopoverController *)handOverPopover {
    
    if (!_handOverPopover) {
        
        STMHandOverPopoverVC *handOverPopoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"handOverPopoverVC"];
        handOverPopoverVC.uncashingSum = self.splitVC.masterVC.cashingSum;
        handOverPopoverVC.parent = self;
        
        _handOverPopover = [[UIPopoverController alloc] initWithContentViewController:handOverPopoverVC];

    }

    return _handOverPopover;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCashing class])];
        
        NSSortDescriptor *outletNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"debt.outlet.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[outletNameSortDescriptor, dateSortDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"uncashing == %@", self.uncashing];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"debt.outlet.name" cacheName:nil];
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
        
//        NSLog(@"fetchedObjects %@", self.resultsController.fetchedObjects);
        
//        [self.tableView setEditing:NO animated:YES];
        [self.tableView reloadData];
        
    }
    
}

- (void)showHandOverPopover {
    
    self.handOverPopover = nil;
    [self.handOverPopover presentPopoverFromBarButtonItem:self.handOverButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (void)uncashingDoneWithSum:(NSDecimalNumber *)summ {

    [self.handOverPopover dismissPopoverAnimated:YES];

    STMUncashing *uncashing = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMUncashing class]) inManagedObjectContext:self.document.managedObjectContext];

    NSArray *cashings = self.resultsController.fetchedObjects;
    
    for (STMCashing *cashing in cashings) {
        
        cashing.uncashing = uncashing;
        
    }
    
    uncashing.summOrigin = self.splitVC.masterVC.cashingSum;
    
    uncashing.summ = summ;
    
    uncashing.date = [NSDate date];
    
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            
        }
    }];
    
}

#pragma mark - table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uncashingDetailCell" forIndexPath:indexPath];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
//    STMDebt *debt = sectionInfo.objects[indexPath.row];
  
    STMCashing *cashing = sectionInfo.objects[indexPath.row];
    
//    NSDecimalNumber *cashingSum = [NSDecimalNumber zero];
//    
//    for (STMCashing *cashing in debt.cashings) {
//        
//        cashingSum = [cashingSum decimalNumberByAdding:cashing.summ];
//        
//    }
    
    NSString *textLabel = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:cashing.summ]];
    NSString *detailTextLabel = [NSString stringWithFormat:@"%@ / %@ / %@", cashing.debt.ndoc, [dateFormatter stringFromDate:cashing.date], [numberFormatter stringFromNumber:cashing.debt.summOrigin]];
    
    cell.textLabel.text = textLabel;
    cell.detailTextLabel.text = detailTextLabel;

    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = ACTIVE_BLUE_COLOR;
    
    cell.selectedBackgroundView = selectedBackgroundView;
    
    UIColor *highlightedTextColor = [UIColor whiteColor];
    
    cell.textLabel.highlightedTextColor = highlightedTextColor;
    cell.detailTextLabel.highlightedTextColor = highlightedTextColor;
    
    return cell;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.handOverButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HAND OVER BUTTON", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showHandOverPopover)];
    self.navigationItem.rightBarButtonItem = self.handOverButton;

    self.handOverButton.enabled = (self.splitVC.masterVC.cashingSum.intValue == 0) ? NO : YES;

    [self performFetch];
    
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
