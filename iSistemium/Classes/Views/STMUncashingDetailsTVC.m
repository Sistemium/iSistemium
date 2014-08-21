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

@property (nonatomic, strong) UIBarButtonItem *handOverButton;
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
    
    if (_uncashing != uncashing) {
        
        _uncashing = uncashing;
        [self performFetch];
        
    }
    
}

- (UIPopoverController *)handOverPopover {
    
    if (!_handOverPopover) {
        
        STMHandOverPopoverVC *handOverPopoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"handOverPopoverVC"];
        handOverPopoverVC.uncashingSum = [self.splitVC.masterVC cashingSum];
        
        _handOverPopover = [[UIPopoverController alloc] initWithContentViewController:handOverPopoverVC];

    }

    return _handOverPopover;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDebt class])];

        NSSortDescriptor *outletNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"outlet.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[outletNameSortDescriptor, dateSortDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"cashings.@count != 0 AND ANY cashings.uncashing == %@", self.uncashing];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"outlet.name" cacheName:nil];
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
//        [self.tableView reloadData];
        
    }
    
}

- (void)showHandOverPopover {
    
    [self.handOverPopover presentPopoverFromBarButtonItem:self.handOverButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
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
    STMDebt *debt = sectionInfo.objects[indexPath.row];
    
    NSDecimalNumber *cashingSum = [NSDecimalNumber zero];
    
    for (STMCashing *cashing in debt.cashings) {
        
        cashingSum = [cashingSum decimalNumberByAdding:cashing.summ];
        
    }
    
    NSString *textLabel = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:cashingSum]];
    NSString *detailTextLabel = [NSString stringWithFormat:@"%@ / %@ / %@", debt.ndoc, [dateFormatter stringFromDate:debt.date], [numberFormatter stringFromNumber:debt.summOrigin]];
    
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
