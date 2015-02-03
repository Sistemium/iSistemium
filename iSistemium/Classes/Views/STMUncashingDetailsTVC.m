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

@interface STMUncashingDetailsTVC ()

@property (nonatomic, strong) STMUncashingSVC *splitVC;
//@property (nonatomic, strong) UIPopoverController *uncashingPopover;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoLabel;
@property (nonatomic, strong) UIPopoverController *uncashingInfoPopover;


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
            
        } else {
            
            self.uncashingProcessButton.enabled = (self.splitVC.masterVC.cashingSum.intValue == 0) ? NO : YES;

        }
        
        [self performFetch];
//        [self.uncashingPopover dismissPopoverAnimated:YES];
        
    }
    
}

- (void)setInfoLabelTitle {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
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
            
            cashingSum = [cashingSum decimalNumberByAdding:cashing.summ];
            
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
        
        NSSortDescriptor *outletNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"debt.outlet.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[outletNameSortDescriptor, dateSortDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"uncashing == %@ AND debt.outlet.name != %@", self.uncashing, nil];
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

- (UIPopoverController *)uncashingInfoPopover {
    
    if (!_uncashingInfoPopover) {
        
        STMUncashingInfoVC *uncashingInfoPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"uncashingInfoPopover"];
        uncashingInfoPopover.uncashing = self.uncashing;
        
        _uncashingInfoPopover = [[UIPopoverController alloc] initWithContentViewController:uncashingInfoPopover];
        
    }
    
    return _uncashingInfoPopover;
    
}

- (void)showUncashingInfoPopover {
    
    self.uncashingInfoPopover = nil;
    [self.uncashingInfoPopover presentPopoverFromBarButtonItem:self.infoLabel permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (void)uncashingProcessButtonPressed {

    if ([STMUncashingProcessController sharedInstance].state == STMUncashingProcessIdle) {
        
        [[STMUncashingProcessController sharedInstance] startWithCashings:self.resultsController.fetchedObjects];
        
    } else if ([STMUncashingProcessController sharedInstance].state == STMUncashingProcessRunning) {
        
        [[STMUncashingProcessController sharedInstance] checkUncashing];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uncashingDoneButtonPressed" object:self userInfo:nil];
        
    }
    
}

- (void)uncashingProcessStart {
    
    [self.tableView setEditing:YES animated:YES];
    
    for (STMCashing *cashing in self.resultsController.fetchedObjects) {
        
        NSIndexPath *indexPath = [self.resultsController indexPathForObject:cashing];
        
        if (indexPath) {
            
            [self tableView:self.tableView willSelectRowAtIndexPath:indexPath];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

        }
        
    }
    
    [self.uncashingProcessButton setTitle:NSLocalizedString(@"DONE", nil)];
    
//    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//        
//        [self.uncashingPopover presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//
//    }
    
}

- (void)uncashingProcessCancel {
    
    [self uncashingProcessDone];

}

- (void)uncashingProcessDone {
    
    [self.tableView setEditing:NO animated:YES];
    [self.uncashingProcessButton setTitle:NSLocalizedString(@"HAND OVER BUTTON", nil)];
    
    [self setInfoLabelTitle];
    [self.splitVC.masterVC selectRowWithUncashing:nil];
    
}

/*
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
*/

#pragma mark - table view data source

- (STMTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uncashingDetailCell" forIndexPath:indexPath];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    STMCashing *cashing = [self.resultsController objectAtIndexPath:indexPath];
    
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


    textColor = [UIColor blackColor];
    backgroundColor = [UIColor clearColor];
    font = cell.detailTextLabel.font;
    
    attributes = @{
                                 NSFontAttributeName: font,
                                 NSBackgroundColorAttributeName: backgroundColor,
                                 NSForegroundColorAttributeName: textColor
                                 };
    
    NSString *debtString = [NSString stringWithFormat:NSLocalizedString(@"DEBT DETAILS", nil), cashing.debt.ndoc, [dateFormatter stringFromDate:cashing.debt.date], cashing.debt.summOrigin];

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
    
    NSString *dateString = [NSString stringWithFormat:@" / %@", [dateFormatter stringFromDate:cashing.date]];

    textColor = [UIColor blackColor];
    backgroundColor = [UIColor clearColor];

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uncashingProcessStart) name:@"uncashingProcessStart" object:[STMUncashingProcessController sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uncashingProcessCancel) name:@"uncashingProcessCancel" object:[STMUncashingProcessController sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uncashingProcessDone) name:@"uncashingProcessDone" object:[STMUncashingProcessController sharedInstance]];    

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    [self addObservers];
    
    self.uncashingProcessButton = [[STMUIBarButtonItemDone alloc] initWithTitle:NSLocalizedString(@"HAND OVER BUTTON", nil) style:UIBarButtonItemStylePlain target:self action:@selector(uncashingProcessButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = self.uncashingProcessButton;

    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;

    [self infoLabelSetup];
    [self performFetch];
    
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
