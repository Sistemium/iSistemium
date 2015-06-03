//
//  STMOutletsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMOutletsTVC.h"
#import "STMDebtsSVC.h"

#import "STMOutlet.h"
#import "STMDebt.h"
#import "STMCashing.h"

#import "STMConstants.h"

#import "STMCashingControlsVC.h"
#import "STMDebtsCombineVC.h"
#import "STMCashingProcessController.h"
#import "STMAddPopoverNC.h"
#import "STMOutletController.h"

#import <Crashlytics/Crashlytics.h>


@interface STMOutletsTVC () <UIActionSheetDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) STMDebtsSVC *splitVC;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) UIPopoverController *addPartnerPopover;
@property (nonatomic, strong) UIPopoverController *addOutletPopover;
@property (nonatomic, strong) STMPartner *selectedPartner;
@property (nonatomic, strong) STMOutlet *outletToDelete;
@property (nonatomic, strong) STMOutlet *nextSelectOutlet;

@end

@implementation STMOutletsTVC

@synthesize resultsController = _resultsController;
@synthesize cellIdentifier = _cellIdentifier;


- (IBAction)addButtonPressed:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"addPARTNER", nil), NSLocalizedString(@"addOUTLET", nil), nil];
    
    actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    actionSheet.tag = 1;
    [actionSheet showFromBarButtonItem:self.addButton animated:YES];
    
}


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
        
        NSSortDescriptor *partnerNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"partner.name"
                                                                                    ascending:YES
                                                                                     selector:@selector(caseInsensitiveCompare:)];
        
        NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"shortName"
                                                                             ascending:YES
                                                                              selector:@selector(caseInsensitiveCompare:)];
                
        request.sortDescriptors = @[partnerNameSortDescriptor, nameSortDescriptor];
        
        request.predicate = [self predicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"partner.name"
                                                                            cacheName:nil];

        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSPredicate *)predicate {
    
    NSMutableArray *subpredicates = [NSMutableArray array];
    
    NSPredicate *outletPredicate = nil;
    
    if ([self debtsEditingIsEnabled]) {
        
        outletPredicate = [NSPredicate predicateWithFormat:@"partner.name != %@", nil];
        
    } else {
        
        outletPredicate = [NSPredicate predicateWithFormat:@"((ANY debts.summ != 0) OR (ANY cashings.summ != 0)) AND partner.name != %@", nil];
        
    }
    
    [subpredicates addObject:outletPredicate];
    
    if ([self.searchBar isFirstResponder] && ![self.searchBar.text isEqualToString:@""]) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text]];
    }
    
    [subpredicates addObject:[STMPredicate predicateWithNoFantoms]];
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];

    return predicate;
    
}

- (UIPopoverController *)addPartnerPopover {
    
    if (!_addPartnerPopover) {
        
        STMAddPopoverNC *addPartnerPopoverNC = [self.storyboard instantiateViewControllerWithIdentifier:@"addPartnerPopover"];
        addPartnerPopoverNC.parentVC = self;
        _addPartnerPopover = [[UIPopoverController alloc] initWithContentViewController:addPartnerPopoverNC];
        _addPartnerPopover.delegate = self;

    }
    return _addPartnerPopover;
    
}

- (UIPopoverController *)addOutletPopover {
    
    if (!_addOutletPopover) {
        
        STMAddPopoverNC *addOutletPopoverNC = [self.storyboard instantiateViewControllerWithIdentifier:@"addOutletPopover"];
        
        addOutletPopoverNC.parentVC = self;
        if (self.selectedPartner) addOutletPopoverNC.partner = self.selectedPartner;
        
        _addOutletPopover = [[UIPopoverController alloc] initWithContentViewController:addOutletPopoverNC];
        _addOutletPopover.delegate = self;
        
    }
    return _addOutletPopover;
    
}

- (BOOL)debtsEditingIsEnabled {
    
    return [[[self appSettings] valueForKey:@"enableDebtsEditing"] boolValue];
    
}

- (BOOL)partnersEditingIsEnabled {

    return [[[self appSettings] valueForKey:@"enablePartnersEditing"] boolValue];

}

- (NSDictionary *)appSettings {
    
    return [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"appSettings"];
    
}

- (void)debtSummChanged:(NSNotification *)notification {
    
//    CLS_LOG(@"____________debtSummChanged____________");
    
    STMOutlet *outlet = (notification.userInfo)[@"outlet"];
    
//    CLS_LOG(@"outlet %@", outlet);
//    CLS_LOG(@"outlet.managedObjectContext %@", outlet.managedObjectContext);
//    CLS_LOG(@"self.resultsController.managedObjectContext %@", self.resultsController.managedObjectContext);
//    CLS_LOG(@"isMainThread %d", [NSThread isMainThread]);
//    CLS_LOG(@"____________debtSummChanged____________");

    [self reloadRowWithOutlet:outlet];
    
}

- (void)cashingIsProcessedChanged:(NSNotification *)notification {

    STMOutlet *outlet = (notification.userInfo)[@"outlet"];
    [self reloadRowWithOutlet:outlet];

}

- (void)settingsChanged:(NSNotification *)notification {
    
    STMSetting *setting = [notification.userInfo valueForKey:@"changedObject"];
    
    if ([setting.group isEqualToString:@"appSettings"] && [setting.name isEqualToString:@"enableDebtsEditing"]) {
        
        [self.tableView reloadData];
        
    }
    
}

- (void)reloadRowWithOutlet:(STMOutlet *)outlet {

    NSIndexPath *indexPath = [self.resultsController indexPathForObject:outlet];
    
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

}

- (void)cashingProcessStart {
 
    if ([STMCashingProcessController sharedInstance].state == STMCashingProcessRunning) {
        
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

- (void)showAddPartnerPopover {
    
//    NSLog(@"showAddPartnerPopover");
    
    CGFloat x = self.splitVC.view.frame.size.width/2;
    CGFloat y = self.addPartnerPopover.popoverContentSize.height/2;
    CGRect rect = CGRectMake(x, y, 1, 1);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.addPartnerPopover presentPopoverFromRect:rect inView:self.splitVC.view permittedArrowDirections:0 animated:YES];
    }];
    
}

- (void)showAddOutletPopover {
    
//    NSLog(@"showAddOutletPopover");
    CGFloat x = self.splitVC.view.frame.size.width/2;
    CGFloat y = self.addOutletPopover.popoverContentSize.height/2;
    CGRect rect = CGRectMake(x, y, 1, 1);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.addOutletPopover presentPopoverFromRect:rect inView:self.splitVC.view permittedArrowDirections:0 animated:YES];
    }];

}

- (void)dissmissPopover {
    
    if (self.addPartnerPopover.isPopoverVisible) {
        
        [self.addPartnerPopover dismissPopoverAnimated:YES];
        [self popoverControllerDidDismissPopover:self.addPartnerPopover];
        
    }
    
    if (self.addOutletPopover.isPopoverVisible) {
        
        [self.addOutletPopover dismissPopoverAnimated:YES];
        [self popoverControllerDidDismissPopover:self.addOutletPopover];
        
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    if (self.addPartnerPopover.isPopoverVisible) {
        [self showAddPartnerPopover];
    }
    
    if (self.addOutletPopover.isPopoverVisible) {
        [self showAddOutletPopover];
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}


#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    
    return NO;
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.addPartnerPopover = nil;
    self.addOutletPopover = nil;
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 1) {

        switch (buttonIndex) {

            case 0:
                [self showAddPartnerPopover];
                break;

            case 1:
                [self showAddOutletPopover];
                break;

            default:
                break;

        }
        
    }
    
}


#pragma mark - Table view data source

- (NSString *)cellIdentifier {
    
    if (!_cellIdentifier) {
        _cellIdentifier = @"outletCell";
    }
    return _cellIdentifier;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom7TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom7TVCell *customCell = nil;
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        customCell = (STMCustom7TVCell *)cell;
    }
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
    
    UIColor *textColor = (!outlet.isActive || [outlet.isActive boolValue]) ? [UIColor blackColor] : [UIColor redColor];
    
    customCell.titleLabel.textColor = textColor;
    customCell.detailLabel.textColor = textColor;
    
    customCell.titleLabel.text = outlet.shortName;
    customCell.detailLabel.text = [self detailedTextForOutlet:outlet];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = ACTIVE_BLUE_COLOR;
    
    cell.selectedBackgroundView = selectedBackgroundView;
    
    UIColor *highlightedTextColor = [UIColor whiteColor];
    
    customCell.titleLabel.highlightedTextColor = highlightedTextColor;
    customCell.detailLabel.highlightedTextColor = highlightedTextColor;
    
    if ([outlet isEqual:self.splitVC.detailVC.outlet]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        //        NSLog(@"select indexPath %@", indexPath);
    }
    
    [super fillCell:cell atIndexPath:indexPath];

}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];

    self.splitVC.detailVC.outlet = outlet;
    
    self.selectedPartner = outlet.partner;
    
    return indexPath;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"didSelectRowAtIndexPath %@", indexPath);
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self partnersEditingIsEnabled];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSIndexPath *nearestIndexPath = [self tableView:tableView nearestIndexPathFor:indexPath];
        self.nextSelectOutlet = [self.resultsController objectAtIndexPath:nearestIndexPath];
        self.outletToDelete = [self.resultsController objectAtIndexPath:indexPath];
        
        NSString *alertMessage = [NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"DELETE OUTLET", nil), self.outletToDelete.shortName];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ATTENTION" message:alertMessage delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alert.tag = 1;
        [alert show];
        
    }
    
}

- (NSString *)detailedTextForOutlet:(STMOutlet *)outlet {
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    NSDecimalNumber *debtSum = [NSDecimalNumber zero];
    
    for (STMDebt *debt in outlet.debts) {
        if (debt.summ) debtSum = [debtSum decimalNumberByAdding:debt.summ];
    }
    
    NSDecimalNumber *cashingSum = [NSDecimalNumber zero];
    
    NSPredicate *cashingPredicate = [NSPredicate predicateWithFormat:@"isProcessed != %@", @YES];
    NSSet *cashings = [outlet.cashings filteredSetUsingPredicate:cashingPredicate];
    
    for (STMCashing *cashing in cashings) cashingSum = [cashingSum decimalNumberByAdding:cashing.summ];
    
    debtSum = [debtSum decimalNumberBySubtracting:cashingSum];
    
    NSString *debtSumString = [numberFormatter stringFromNumber:debtSum];
    
    return debtSumString;
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [super controllerDidChangeContent:controller];
    
    if (self.nextSelectOutlet) {
        
        NSIndexPath *selectIndexPath = [self.resultsController indexPathForObject:self.nextSelectOutlet];
        [self tableView:self.tableView willSelectRowAtIndexPath:selectIndexPath];
        [self.tableView selectRowAtIndexPath:selectIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:selectIndexPath];
        
        self.nextSelectOutlet = nil;
        
    }
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        
        if (buttonIndex == 0) {
            
            self.outletToDelete = nil;
            self.nextSelectOutlet = nil;
            
        } else if (buttonIndex == 1) {

            [STMOutletController removeOutlet:self.outletToDelete];
            
        }
        
    }
    
}


#pragma mark - view lifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(debtSummChanged:)
               name:@"debtSummChanged"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(cashingIsProcessedChanged:)
               name:@"cashingIsProcessedChanged"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(cashingProcessStart)
               name:@"cashingProcessStart"
             object:[STMCashingProcessController sharedInstance]];

    [nc addObserver:self
           selector:@selector(settingsChanged:)
               name:@"settingsChanged"
             object:[STMSessionManager sharedManager].currentSession.settingsController];

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    UINib *cellNib = [UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
        
    BOOL toolbarHidden = ![self partnersEditingIsEnabled];
    
    self.navigationController.toolbarHidden = toolbarHidden;
    
    self.clearsSelectionOnViewWillAppear = NO;

    [self performFetch];

    self.title = NSLocalizedString(@"OUTLETS", nil);
        
    [self addObservers];
    
    [super customInit];
    
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
