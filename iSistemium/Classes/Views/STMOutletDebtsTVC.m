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
#import "STMDebt+Cashing.h"
#import "STMCashing.h"
#import "STMDebtsCombineVC.h"
#import "STMConstants.h"
#import "STMFunctions.h"
#import "STMTableViewCell.h"
#import "STMDebtsSVC.h"
#import "STMCashingProcessController.h"
#import "STMDebtsController.h"

@interface STMOutletDebtsTVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STMDebtsSVC *splitVC;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;


@end


@implementation STMOutletDebtsTVC

@synthesize resultsController = _resultsController;

- (STMDebtsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMDebtsSVC class]]) {
            
            _splitVC = (STMDebtsSVC *)self.splitViewController;
            
        }
        
    }
    
    return _splitVC;
    
}

- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        [self performFetch];
        
    }
    
}

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        [self.tableView setEditing:NO animated:YES];
        [self.tableView reloadData];
                
    }
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDebt class])];
        
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *ndocSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndoc" ascending:YES selector:@selector(compare:)];
        
        request.sortDescriptors = @[dateSortDescriptor, ndocSortDescriptor];
        request.predicate = [NSPredicate predicateWithFormat:@"outlet == %@ AND calculatedSum != %@", self.outlet, [NSDecimalNumber zero]];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)updateRowWithDebt:(STMDebt *)debt {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:debt];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        
        NSArray *selectedIndexPaths = self.tableView.indexPathsForSelectedRows;
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        if ([selectedIndexPaths containsObject:indexPath]) {
            
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            
        }
        
    }
    
}

- (NSMutableAttributedString *)textLabelForDebt:(STMDebt *)debt withFont:(UIFont *)font {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSString *debtSumString = [numberFormatter stringFromNumber:debt.calculatedSum];
    
    if (debtSumString) {

        UIColor *backgroundColor = [UIColor clearColor];
        UIColor *textColor = [UIColor blackColor];
        
        if ([[[STMCashingProcessController sharedInstance].debtsArray lastObject] isEqual:debt]) {
            
            textColor = ACTIVE_BLUE_COLOR;
            
        }
        
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName: font,
                                     NSBackgroundColorAttributeName: backgroundColor,
                                     NSForegroundColorAttributeName: textColor
                                     };
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:debtSumString attributes:attributes];
        
        if (debt.responsibility) {
            
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attributes]];
            
            backgroundColor = [UIColor grayColor];
            textColor = [UIColor whiteColor];
            
            attributes = @{
                           NSFontAttributeName: font,
                           NSBackgroundColorAttributeName: backgroundColor,
                           NSForegroundColorAttributeName: textColor
                           };
            
            NSString *responsibilityString = [NSString stringWithFormat:@" %@ ", debt.responsibility];
            
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:responsibilityString attributes:attributes]];
            
        }
        
        if (debt.dateE) {
            
            backgroundColor = [UIColor clearColor];
            textColor = [UIColor blackColor];
            UIFont *font = [UIFont systemFontOfSize:16];
            
            attributes = @{
                           NSFontAttributeName: font,
                           NSBackgroundColorAttributeName: backgroundColor,
                           NSForegroundColorAttributeName: textColor
                           };
            
            NSString *dueDateHeader = [NSString stringWithFormat:@" / %@: ", NSLocalizedString(@"DUE DATE", nil)];
            
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:dueDateHeader attributes:attributes]];
            
            NSNumber *numberOfDays = [STMFunctions daysFromTodayToDate:debt.dateE];

            NSString *dueDate = nil;
            
            if ([numberOfDays intValue] == 0) {
                
                textColor = [UIColor purpleColor];
                dueDate = NSLocalizedString(@"TODAY", nil);
                
            } else if ([numberOfDays intValue] == 1) {
                
                dueDate = NSLocalizedString(@"TOMORROW", nil);
                
            } else if ([numberOfDays intValue] == -1) {
                
                textColor = [UIColor redColor];
                dueDate = NSLocalizedString(@"YESTERDAY", nil);
                
            } else {
                
                NSString *pluralType = [STMFunctions pluralTypeForCount:abs([numberOfDays intValue])];
                
                BOOL dateIsInPast = ([numberOfDays intValue] < 0);
                
                if (dateIsInPast) {
                    
                    int positiveNumberOfDays = -1 * [numberOfDays intValue];
                    numberOfDays = [NSNumber numberWithInt:positiveNumberOfDays];
                    
                }
                
                dueDate = [NSString stringWithFormat:@"%@ %@", numberOfDays, NSLocalizedString([pluralType stringByAppendingString:@"DAYS"], nil)];
                
                if (dateIsInPast) {
                    
                    textColor = [UIColor redColor];
                    dueDate = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"AGO", nil), dueDate];
                    
                }
                
            }
            
            attributes = @{
                           NSFontAttributeName: font,
                           NSBackgroundColorAttributeName: backgroundColor,
                           NSForegroundColorAttributeName: textColor
                           };

            [text appendAttributedString:[[NSAttributedString alloc] initWithString:dueDate attributes:attributes]];
            
        }
        
        return text;
        
    } else {
        
        return nil;
        
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

- (STMTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"debtDetailsCell" forIndexPath:indexPath];

    STMDebt *debt = [self.resultsController objectAtIndexPath:indexPath];

    cell.textLabel.attributedText = [self textLabelForDebt:debt withFont:cell.textLabel.font];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *debtDate = [dateFormatter stringFromDate:debt.date];
    NSString *debtSumOriginString = [numberFormatter stringFromNumber:debt.summOrigin];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DEBT DETAILS", nil), debt.ndoc, debtDate, debtSumOriginString];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMDebt *debt = [self.resultsController objectAtIndexPath:indexPath];

    [[cell.contentView viewWithTag:1] removeFromSuperview];

    cell.tintColor = ACTIVE_BLUE_COLOR;
    cell.accessoryType = UITableViewCellAccessoryNone;

    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if ([STMCashingProcessController sharedInstance].state == STMCashingProcessRunning) {
        
        if ([[[STMCashingProcessController sharedInstance].debtsArray lastObject] isEqual:debt]) {
            
            cell.detailTextLabel.textColor = ACTIVE_BLUE_COLOR;
            
        } else {
            
            cell.detailTextLabel.textColor = [UIColor blackColor];
            
        }
        
        CGFloat fillWidth = 0;
        
        if ([[[STMCashingProcessController sharedInstance].debtsDictionary allKeys] containsObject:debt.xid]) {
            
            NSDecimalNumber *cashingSum = [[STMCashingProcessController sharedInstance].debtsDictionary objectForKey:debt.xid][1];
            
            fillWidth = [[cashingSum decimalNumberByDividingBy:debt.calculatedSum] doubleValue];
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        } else {

            cell.accessoryType = UITableViewCellAccessoryNone;

        }

        if (fillWidth != 0) {
            
            fillWidth = fillWidth * cell.frame.size.width;
            
            if (fillWidth < 10) fillWidth = 10;
            
            CGRect rect = CGRectMake(0, 1, fillWidth, cell.frame.size.height-2);
            UIView *view = [[UIView alloc] initWithFrame:rect];
            view.backgroundColor = STM_SUPERLIGHT_BLUE_COLOR;
            view.tag = 1;
            [cell.contentView addSubview:view];
            [cell.contentView sendSubviewToBack:view];

        }
        
    } else {
        
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        
    }

}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([STMCashingProcessController sharedInstance].state == STMCashingProcessRunning) {
        
        return UITableViewCellEditingStyleNone;

    } else {
        
        return UITableViewCellEditingStyleDelete;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([STMCashingProcessController sharedInstance].state == STMCashingProcessRunning) {
        
        return NO;
        
    } else {
        
        return YES;
    }
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([STMCashingProcessController sharedInstance].state == STMCashingProcessRunning && ![STMCashingProcessController sharedInstance].cashingLimitIsReached) {
        
        STMDebt *debt = [self.resultsController objectAtIndexPath:indexPath];
        [[STMCashingProcessController sharedInstance] addDebt:debt];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        return indexPath;

    } else {
        
        return nil;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"indexPathsForSelectedRows %@", self.tableView.indexPathsForSelectedRows);

}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([STMCashingProcessController sharedInstance].state == STMCashingProcessRunning) {

        STMDebt *debt = [self.resultsController objectAtIndexPath:indexPath];
        [[STMCashingProcessController sharedInstance] removeDebt:debt];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        return indexPath;

    } else {
        
        return nil;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

//    NSLog(@"indexPathsForSelectedRows %@", self.tableView.indexPathsForSelectedRows);

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        STMDebt *debt = [self.resultsController objectAtIndexPath:indexPath];

        [STMDebtsController removeDebt:debt];
        
        if ([self.splitViewController isKindOfClass:[STMDebtsSVC class]]) {
            
            STMDebtsSVC *splitVC = (STMDebtsSVC *)self.splitViewController;
            NSIndexPath *indexPath = [splitVC.masterVC.resultsController indexPathForObject:self.outlet];
            [splitVC.masterVC.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            
        }
    
        
    }
    
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self.tableView reloadData];
    
}


#pragma mark - observers methods

- (void)editingButtonPressed:(NSNotification *)notification {
    
    BOOL editing = [[notification.userInfo objectForKey:@"editing"] boolValue];
    
    //    self.tableView.allowsMultipleSelectionDuringEditing = !editing;
    [self.tableView setEditing:editing animated:YES];
    
}

- (void)cashingProcessStart {
    
    [self.tableView setEditing:NO animated:YES];
    
}

- (void)cashingProcessCancel {
    
    [self.tableView reloadData];

}

- (void)cashingProcessDone {

    [self.tableView reloadData];

}

- (void)debtAdded:(NSNotification *)notification {
    
    STMDebt *debt = [notification.userInfo objectForKey:@"debt"];
    STMDebt *previousDebt = [notification.userInfo objectForKey:@"previousDebt"];

    if (debt) [self updateRowWithDebt:debt];
    if (previousDebt && ![previousDebt isEqual:[NSNull null]]) [self updateRowWithDebt:previousDebt];

}

- (void)debtRemoved:(NSNotification *)notification {
    
    STMDebt *debt = [notification.userInfo objectForKey:@"debt"];
    STMDebt *selectedDebt = [notification.userInfo objectForKey:@"selectedDebt"];
    
    if (debt) [self updateRowWithDebt:debt];
    if (selectedDebt && ![selectedDebt isEqual:[NSNull null]]) [self updateRowWithDebt:selectedDebt];

    NSIndexPath *removedDebtIndexPath = [self.resultsController indexPathForObject:debt];
    [self.tableView deselectRowAtIndexPath:removedDebtIndexPath animated:NO];
    
}

- (void)cashingSumChanged:(NSNotification *)notification {
    
    STMDebt *debt = [notification.userInfo objectForKey:@"debt"];
    [self updateRowWithDebt:debt];

}


#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingButtonPressed:)
                                                 name:@"editingButtonPressed"
                                               object:self.parentVC];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cashingProcessStart)
                                                 name:@"cashingProcessStart"
                                               object:[STMCashingProcessController sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cashingProcessCancel)
                                                 name:@"cashingProcessCancel"
                                               object:[STMCashingProcessController sharedInstance]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cashingProcessDone)
                                                 name:@"cashingProcessDone"
                                               object:[STMCashingProcessController sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(debtAdded:)
                                                 name:@"debtAdded"
                                               object:[STMCashingProcessController sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(debtRemoved:)
                                                 name:@"debtRemoved"
                                               object:[STMCashingProcessController sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cashingSumChanged:)
                                                 name:@"cashingSumChanged"
                                               object:[STMCashingProcessController sharedInstance]];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    [self addObservers];
    
    [self.tableView setTintColor:STM_LIGHT_LIGHT_GREY_COLOR];
//    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsMultipleSelection = YES;
    self.clearsSelectionOnViewWillAppear = NO;
    
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.parentVC setEditing:NO animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
