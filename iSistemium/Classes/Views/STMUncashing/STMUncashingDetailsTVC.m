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
#import "STMUncashingPicture.h"
#import "STMObjectsController.h"
#import "STMUncashingInfoVC.h"
#import "STMTableViewCell.h"
#import "STMUncashingProcessController.h"
#import "STMAddEtceteraVC.h"

@interface STMUncashingDetailsTVC () <UIPopoverControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) STMUncashingSVC *splitVC;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoLabel;
@property (nonatomic, strong) UIPopoverController *uncashingInfoPopover;
@property (nonatomic, strong) UIPopoverController *addCashingPopover;
@property (nonatomic, strong) UIBarButtonItem *addButton;

@property (nonatomic) STMCashingType addCashingType;


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
            
            self.uncashingProcessButton.enabled = NO;
            [self hideAddButton];
            
        } else {
            
            self.uncashingProcessButton.enabled = (self.splitVC.masterVC.cashingSum.intValue == 0) ? NO : YES;
            [self showAddButton];

        }
        
        [self performFetch];
        
    }
    
}

- (UIBarButtonItem *)addButton {
    
    if (!_addButton) {
//        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
        _addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADD SUM", nil) style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed)];
    }
    return _addButton;
    
}

- (void)hideAddButton {

    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];

    if ([toolbarButtons containsObject:self.addButton]) {

        [toolbarButtons removeObject:self.addButton];
        [self setToolbarItems:toolbarButtons animated:YES];

    }
    
}

- (void)showAddButton {
    
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];

    if (![toolbarButtons containsObject:self.addButton]) {

        [toolbarButtons addObject:self.addButton];
        [self setToolbarItems:toolbarButtons animated:YES];
        
    }

}

- (void)setInfoLabelTitle {
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    if (self.uncashing) {
        
//        NSString *infoLabelTitle = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"TOTAL", nil), [numberFormatter stringFromNumber:self.uncashing.summ]];
        NSString *infoLabelTitle = NSLocalizedString(@"DETAILS", nil);
        
        self.infoLabel.title = infoLabelTitle;
        
        self.infoLabel.enabled = YES;
        NSDictionary *attributes = @{NSForegroundColorAttributeName:ACTIVE_BLUE_COLOR};
        [self.infoLabel setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
    } else {
        
        NSDecimalNumber *cashingSum = [NSDecimalNumber zero];
        
        for (STMCashing *cashing in self.resultsController.fetchedObjects) {
            
            cashingSum = (cashing.summ) ? [cashingSum decimalNumberByAdding:(NSDecimalNumber * _Nonnull)cashing.summ] : cashingSum;
            
        }

        NSString *infoLabelTitle = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"TOTAL", nil), [numberFormatter stringFromNumber:cashingSum]];

        self.infoLabel.title = infoLabelTitle;

        self.infoLabel.enabled = NO;
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
        [self.infoLabel setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [self.infoLabel setTitleTextAttributes:attributes forState:UIControlStateDisabled];

    }
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCashing class])];
        
        NSSortDescriptor *outletNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"outlet.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *sumSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"summ" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[outletNameSortDescriptor, sumSortDescriptor, dateSortDescriptor];
        
//        request.predicate = [NSPredicate predicateWithFormat:@"uncashing == %@ AND outlet.name != %@", self.uncashing, nil];
        request.predicate = [NSPredicate predicateWithFormat:@"uncashing == %@", self.uncashing];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"outletSectionName" cacheName:nil];
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

- (void)addButtonPressed {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"ETC", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"DEDUCTION", nil)];
        
        [actionSheet showFromBarButtonItem:self.addButton animated:YES];
        
    }];
    
    self.addButton.enabled = NO;
    
}

- (void)showUncashingInfoPopover {
    
    self.uncashingInfoPopover = nil;
    [self.uncashingInfoPopover presentPopoverFromBarButtonItem:self.infoLabel permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
 
    if ([actionSheet.title isEqualToString:NSLocalizedString(@"ADD", nil)]) {
        
        if (buttonIndex >= 0) {
            
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"ETC", nil)]) {
                self.addCashingType = STMCashingEtcetera;
            } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"DEDUCTION", nil)]) {
                self.addCashingType = STMCashingDeduction;
            }
            
            self.addCashingPopover = nil;
            
            CGRect rect = CGRectMake(self.splitVC.view.frame.size.width/2, self.splitVC.view.frame.size.height/2, 1, 1);
            [self.addCashingPopover presentPopoverFromRect:rect inView:self.splitVC.view permittedArrowDirections:0 animated:YES];
            
        }
        
        self.addButton.enabled = YES;
        
    }

}


#pragma mark - popovers

- (UIPopoverController *)addCashingPopover {
    
    if (!_addCashingPopover) {
        
        STMAddEtceteraVC *addEtceteraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addEtceteraVC"];
        addEtceteraVC.parentVC = self;
        addEtceteraVC.cashingType = self.addCashingType;
        
        _addCashingPopover = [[UIPopoverController alloc] initWithContentViewController:addEtceteraVC];
        _addCashingPopover.delegate = self;
        
    }
    return _addCashingPopover;
    
}

- (UIPopoverController *)uncashingInfoPopover {
    
    if (!_uncashingInfoPopover) {
        
        STMUncashingInfoVC *uncashingInfoPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"uncashingInfoPopover"];
        uncashingInfoPopover.uncashing = self.uncashing;
        
        _uncashingInfoPopover = [[UIPopoverController alloc] initWithContentViewController:uncashingInfoPopover];
        
    }
    return _uncashingInfoPopover;
    
}

- (void)dismissAddCashingPopover {
    
    [self.addCashingPopover dismissPopoverAnimated:YES];
    self.addCashingPopover = nil;

}

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    
    return NO;
    
}


#pragma mark - uncashing process

- (void)uncashingProcessButtonPressed {
    
    if ([STMUncashingProcessController sharedInstance].state == STMUncashingProcessIdle) {
    
        [self.tableView setEditing:NO animated:YES];
        [[STMUncashingProcessController sharedInstance] startWithCashings:self.resultsController.fetchedObjects];
        
    } else if ([STMUncashingProcessController sharedInstance].state == STMUncashingProcessRunning) {
        
        [[STMUncashingProcessController sharedInstance] checkUncashing];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uncashingDoneButtonPressed" object:self userInfo:nil];
        
    }
    
}

- (void)uncashingProcessStart {
    
    self.addButton.enabled = NO;
    
    [self.tableView setEditing:YES animated:YES];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    for (STMCashing *cashing in self.resultsController.fetchedObjects) {
        
        NSIndexPath *indexPath = [self.resultsController indexPathForObject:cashing];
        
        if (indexPath) {
            
            [self tableView:self.tableView willSelectRowAtIndexPath:indexPath];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

        }
        
    }
    
    [self.uncashingProcessButton setTitle:NSLocalizedString(@"DONE", nil)];
    
}

- (void)uncashingProcessCancel {
    
    [self uncashingProcessDone];

}

- (void)uncashingProcessDone {
    
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;

    [self.tableView setEditing:NO animated:YES];
    [self.uncashingProcessButton setTitle:NSLocalizedString(@"HAND OVER BUTTON", nil)];
    
    [self setInfoLabelTitle];
    [self.splitVC.masterVC selectRowWithUncashing:nil];
    
    self.addButton.enabled = YES;

}


#pragma mark - table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [STMFunctions shortCompanyName:(NSString *)[super tableView:tableView titleForHeaderInSection:section]];
}

- (STMTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uncashingDetailCell" forIndexPath:indexPath];
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    NSDateFormatter *dateFormatter = [STMFunctions dateMediumNoTimeFormatter];
    
    STMCashing *cashing = [self.resultsController objectAtIndexPath:indexPath];
    
    NSString *sumString = [[numberFormatter stringFromNumber:(NSDecimalNumber * _Nonnull)cashing.summ] stringByAppendingString:@" "];
    
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
        
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:(NSString * _Nonnull)cashing.commentText attributes:attributes]];
        
    }
    
    cell.textLabel.attributedText = text;


    textColor = [UIColor blackColor];
    backgroundColor = [UIColor clearColor];
    font = cell.detailTextLabel.font;
    
    attributes = @{
                                 NSFontAttributeName: font,
                                 NSBackgroundColorAttributeName: backgroundColor,
                                 NSForegroundColorAttributeName: textColor
                                 };
    
    if (cashing.debt) {
        
        NSString *debtString = [NSString stringWithFormat:NSLocalizedString(@"DEBT DETAILS", nil), cashing.debt.ndoc, [dateFormatter stringFromDate:(NSDate * _Nonnull)cashing.debt.date], cashing.debt.summOrigin];
        
        text = [[NSMutableAttributedString alloc] initWithString:debtString attributes:attributes];
        
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

    } else {
        
        if (cashing.ndoc) {
            text = [[NSMutableAttributedString alloc] initWithString:(NSString *)cashing.ndoc attributes:attributes];
        } else {
            text = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"NO DATA", nil) attributes:attributes];
        }
        
    }
    
    NSString *dateString = [NSString stringWithFormat:@" / %@", [dateFormatter stringFromDate:(NSDate *)cashing.date]];

//    textColor = [UIColor blackColor];
//    backgroundColor = [UIColor clearColor];

    [text appendAttributedString:[[NSAttributedString alloc] initWithString:dateString attributes:attributes]];
    
    cell.detailTextLabel.attributedText = text;
    
    
    if ([[STMUncashingProcessController sharedInstance] hasCashingWithXid:cashing.xid]) {
        
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
        
        [[STMUncashingProcessController sharedInstance] addCashing:cashing];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    return indexPath;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.editing) {
        
        STMCashing *cashing = [self.resultsController objectAtIndexPath:indexPath];
        [[STMUncashingProcessController sharedInstance] removeCashing:cashing];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
    
    return indexPath;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (self.uncashing) ? NO : YES;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        STMCashing *cashing = [self.resultsController objectAtIndexPath:indexPath];
        [STMCashingController removeCashing:cashing];
        
    }
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];
    [self setInfoLabelTitle];
    
}


- (void)infoLabelSetup {
    
    self.infoLabel.title = @"";
    self.infoLabel.enabled = NO;
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.infoLabel setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.infoLabel setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    
    [self.infoLabel setTarget:self];
    [self.infoLabel setAction:@selector(showUncashingInfoPopover)];

}

#pragma mark - view lifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(uncashingProcessStart)
               name:@"uncashingProcessStart"
             object:[STMUncashingProcessController sharedInstance]];
    
    [nc addObserver:self
           selector:@selector(uncashingProcessCancel)
               name:@"uncashingProcessCancel"
             object:[STMUncashingProcessController sharedInstance]];
    
    [nc addObserver:self
           selector:@selector(uncashingProcessDone)
               name:@"uncashingProcessDone"
             object:[STMUncashingProcessController sharedInstance]];

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    [self addObservers];
    
    self.uncashingProcessButton = [[STMBarButtonItemDone alloc] initWithTitle:NSLocalizedString(@"HAND OVER BUTTON", nil) style:UIBarButtonItemStylePlain target:self action:@selector(uncashingProcessButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = self.uncashingProcessButton;

    [self infoLabelSetup];
    
    (self.uncashing) ? [self hideAddButton] : [self showAddButton];
    
    [self performFetch];
    
    [super customInit];
    
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
//    [self customInit];

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
