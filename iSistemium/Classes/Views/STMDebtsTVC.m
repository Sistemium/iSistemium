//
//  STMDebtsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDebtsTVC.h"
#import "STMDebtsSVC.h"

#import "STMOutlet.h"
#import "STMDebt.h"
#import "STMCashing.h"

#import "STMConstants.h"

#import "STMCashingControlsVC.h"
#import "STMDebtsCombineVC.h"

@interface STMDebtsTVC ()

@property (nonatomic, strong) STMDebtsSVC *splitVC;
//@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation STMDebtsTVC

@synthesize resultsController = _resultsController;

- (STMDebtsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMDebtsSVC class]]) {
            _splitVC = (STMDebtsSVC *)self.splitViewController;
        }
        
    }
    
    return _splitVC;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
        
        NSSortDescriptor *partnerNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"partner.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                
        request.sortDescriptors = @[partnerNameSortDescriptor, nameSortDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"(ANY debts.summ != 0) OR (ANY cashings.summ != 0)"];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"partner.name" cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)debtSummChanged:(NSNotification *)notification {
    
    STMOutlet *outlet = [notification.userInfo objectForKey:@"outlet"];
    [self reloadRowWithOutlet:outlet];
    
}

- (void)cashingIsProcessedChanged:(NSNotification *)notification {
<<<<<<< HEAD
=======
    
    STMOutlet *outlet = [notification.userInfo objectForKey:@"outlet"];
    [self reloadRowWithOutlet:outlet];
    
}

- (void)reloadRowWithOutlet:(STMOutlet *)outlet {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:outlet];
>>>>>>> dev

    STMOutlet *outlet = [notification.userInfo objectForKey:@"outlet"];
    [self reloadRowWithOutlet:outlet];

}

- (void)reloadRowWithOutlet:(STMOutlet *)outlet {

    NSIndexPath *indexPath = [self.resultsController indexPathForObject:outlet];
    
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

}

- (void)cashingButtonPressed {
    
    if (self.splitVC.detailVC.isCashingProcessing) {
        
        [self performSegueWithIdentifier:@"showCashingControls" sender:self];
        
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showCashingControls"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMCashingControlsVC class]]) {
            
            STMCashingControlsVC *controlsVC = (STMCashingControlsVC *)segue.destinationViewController;
            
            controlsVC.outlet = self.splitVC.detailVC.outlet;
            controlsVC.tableVC = [(STMDebtsCombineVC *)self.splitVC.detailVC.debtsCombineVC tableVC];
            
        }
        
    }
    
}

- (void)cashingButtonPressed {
    
    if (self.splitVC.detailVC.isCashingProcessing) {
        
        [self performSegueWithIdentifier:@"showCashingControls" sender:self];
        
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showCashingControls"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMCashingControlsVC class]]) {
            
            STMCashingControlsVC *controlsVC = (STMCashingControlsVC *)segue.destinationViewController;
            
            controlsVC.outlet = self.splitVC.detailVC.outlet;
            controlsVC.tableVC = [(STMDebtsCombineVC *)self.splitVC.detailVC.debtsCombineVC tableVC];
            
        }
        
    }
    
}

#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debtSummChanged:) name:@"debtSummChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cashingIsProcessedChanged:) name:@"cashingIsProcessedChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cashingButtonPressed) name:@"cashingButtonPressed" object:self.splitVC.detailVC];

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    self.clearsSelectionOnViewWillAppear = NO;

    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    }

    self.title = NSLocalizedString(@"OUTLETS", nil);
    
    [self addObservers];
    
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"debtCell" forIndexPath:indexPath];

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];

    STMOutlet *outlet = sectionInfo.objects[indexPath.row];
    
    cell.textLabel.text = outlet.shortName;
    cell.detailTextLabel.text = [self detailedTextForOutlet:outlet];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = ACTIVE_BLUE_COLOR;
    
    cell.selectedBackgroundView = selectedBackgroundView;
    
    UIColor *highlightedTextColor = [UIColor whiteColor];
    
    cell.textLabel.highlightedTextColor = highlightedTextColor;
    cell.detailTextLabel.highlightedTextColor = highlightedTextColor;
    
    return cell;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[indexPath.section];
    STMOutlet *outlet = sectionInfo.objects[indexPath.row];
    
    self.splitVC.detailVC.outlet = outlet;
    
//    self.selectedIndexPath = indexPath;
    
    return indexPath;

}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedIndexPath && [indexPath compare:self.selectedIndexPath] == NSOrderedSame) {
        
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }
    
}
*/

- (NSString *)detailedTextForOutlet:(STMOutlet *)outlet {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSDecimalNumber *debtSum = [NSDecimalNumber zero];
    
    for (STMDebt *debt in outlet.debts) {
                
        if (debt.summ) {
            debtSum = [debtSum decimalNumberByAdding:debt.summ];
        }
        
    }
    
    NSDecimalNumber *cashingSum = [NSDecimalNumber zero];

    NSPredicate *cashingPredicate = [NSPredicate predicateWithFormat:@"isProcessed != %@", [NSNumber numberWithBool:YES]];
    NSSet *cashings = [outlet.cashings filteredSetUsingPredicate:cashingPredicate];
    
    for (STMCashing *cashing in cashings) {
        
        cashingSum = [cashingSum decimalNumberByAdding:cashing.summ];
        
    }
    
    debtSum = [debtSum decimalNumberBySubtracting:cashingSum];
    
    NSString *debtSumString = [numberFormatter stringFromNumber:debtSum];

    return debtSumString;

/*
    NSString *cashingSumString = [numberFormatter stringFromNumber:cashingSum];
    
    NSString *detailedText = nil;
    
    if ([cashingSum compare:[NSDecimalNumber zero]] == NSOrderedSame) {
        
        detailedText = [NSString stringWithFormat:@"%@", debtSumString];
        
    } else {
        
        detailedText = [NSString stringWithFormat:@"%@ (%@)", debtSumString, cashingSumString];
        
    }

    return detailedText;
*/

}

@end
