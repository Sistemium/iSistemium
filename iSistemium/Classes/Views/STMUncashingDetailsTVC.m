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
#import "STMUncashingSVC.h"
#import "STMSyncer.h"

@interface STMUncashingDetailsTVC ()

@property (nonatomic, strong) STMUncashingSVC *splitVC;
@property (nonatomic, strong) UIPopoverController *uncashingPopover;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoLabel;

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
        [self.uncashingPopover dismissPopoverAnimated:YES];
        
    }
    
}

- (void)setInfoLabelTitle {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    if (self.uncashing) {
        
        NSString *infoLabelTitle = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"TOTAL", nil), [numberFormatter stringFromNumber:self.uncashing.summ]];
        
        self.infoLabel.title = infoLabelTitle;
        
    } else {
        
        NSDecimalNumber *cashingSum = [NSDecimalNumber zero];
        
        for (STMCashing *cashing in self.resultsController.fetchedObjects) {
            
            cashingSum = [cashingSum decimalNumberByAdding:cashing.summ];
            
        }

        NSString *infoLabelTitle = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"TOTAL", nil), [numberFormatter stringFromNumber:cashingSum]];

        self.infoLabel.title = infoLabelTitle;
        
    }
    
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
        
        [self.tableView reloadData];
        [self setInfoLabelTitle];
        
    }
    
}

- (NSMutableDictionary *)cashingDictionary {
    
    if (!_cashingDictionary) {
        
        _cashingDictionary = [NSMutableDictionary dictionary];
        
    }
    
    return _cashingDictionary;
    
}

- (void)handOverButtonPressed {
    
    self.splitVC.isUncashingHandOverProcessing = !self.splitVC.isUncashingHandOverProcessing;
    
    if (self.splitVC.isUncashingHandOverProcessing) {

        [self.tableView setEditing:YES animated:YES];

        for (STMCashing *cashing in self.resultsController.fetchedObjects) {
            
            [self.cashingDictionary setObject:cashing forKey:cashing.xid];
            NSIndexPath *indexPath = [self.resultsController indexPathForObject:cashing];
            
            [self tableView:self.tableView willSelectRowAtIndexPath:indexPath];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }

        [self.handOverButton setTitle:NSLocalizedString(@"CANCEL", nil)];
        [self.handOverButton setTintColor:[UIColor redColor]];
        
    } else {

        [self.tableView setEditing:NO animated:YES];

        self.cashingDictionary = nil;

        [self.handOverButton setTintColor:ACTIVE_BLUE_COLOR];
        [self.handOverButton setTitle:NSLocalizedString(@"HAND OVER BUTTON", nil)];
        
    }
    
}

- (void)uncashingDoneWithSum:(NSDecimalNumber *)summ {

    STMUncashing *uncashing = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMUncashing class]) inManagedObjectContext:self.document.managedObjectContext];

    NSArray *cashings = [self.cashingDictionary allValues];
    
    for (STMCashing *cashing in cashings) {
        
        cashing.uncashing = uncashing;
        
    }
    
    uncashing.summOrigin = self.splitVC.masterVC.cashingSum;
    uncashing.summ = summ;
    uncashing.date = [NSDate date];
    
//    self.uncashing = uncashing;
    
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            
            STMSyncer *syncer = [STMSessionManager sharedManager].currentSession.syncer;
            syncer.syncerState = STMSyncerSendData;

        }
    }];
    
    [self setInfoLabelTitle];
    [self handOverButtonPressed];
    [self.splitVC.masterVC selectRowWithUncashing:nil];
    
}


#pragma mark - UISplitViewControllerDelegate

//- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
//    
//    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
//        
//        return NO;
//        
//    } else {
//    
//        if (self.splitVC.isUncashingHandOverProcessing) {
//            
//            return NO;
//            
//        } else {
//            
//            return YES;
//            
//        }
//
//    }
//    
//}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    barButtonItem.title = NSLocalizedString(@"UNCASHING", nil);
    
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    self.uncashingPopover = pc;
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    
    self.navigationItem.leftBarButtonItem = nil;
    
    self.uncashingPopover = nil;
    
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
  
    STMCashing *cashing = sectionInfo.objects[indexPath.row];
    
    NSString *textLabel = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:cashing.summ]];

    cell.textLabel.text = textLabel;

    
    UIColor *textColor = [UIColor blackColor];
    UIColor *backgroundColor = [UIColor clearColor];
    UIFont *font = cell.detailTextLabel.font;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSBackgroundColorAttributeName: backgroundColor,
                                 NSForegroundColorAttributeName: textColor
                                 };
    
    NSString *debtString = [NSString stringWithFormat:NSLocalizedString(@"DEBT DETAILS", nil), cashing.debt.ndoc, [dateFormatter stringFromDate:cashing.debt.date], cashing.debt.summOrigin];

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:debtString attributes:attributes];
    
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
    
    NSString *dateString = [NSString stringWithFormat:@" / %@", [dateFormatter stringFromDate:cashing.date]];

    textColor = [UIColor blackColor];
    backgroundColor = [UIColor clearColor];

    [text appendAttributedString:[[NSAttributedString alloc] initWithString:dateString attributes:attributes]];
    
    cell.detailTextLabel.attributedText = text;
    
    if ([[self.cashingDictionary allKeys] containsObject:cashing.xid]) {
        
        cell.tintColor = ACTIVE_BLUE_COLOR;
        
    } else {
        
        cell.tintColor = STM_LIGHT_LIGHT_GREY_COLOR;
        
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

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

        STMCashing *cashing = [self.resultsController objectAtIndexPath:indexPath];
        [self.cashingDictionary setObject:cashing forKey:cashing.xid];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingDictionaryChanged" object:self];
        
    }
    
    return indexPath;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.editing) {
        
        STMCashing *cashing = [self.resultsController objectAtIndexPath:indexPath];
        [self.cashingDictionary removeObjectForKey:cashing.xid];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingDictionaryChanged" object:self];

    }
    
    return indexPath;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.handOverButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HAND OVER BUTTON", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handOverButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.handOverButton;

    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;

    self.infoLabel.title = @"";
    self.infoLabel.enabled = NO;
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.infoLabel setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.infoLabel setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    
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
