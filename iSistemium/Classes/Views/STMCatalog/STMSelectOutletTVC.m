//
//  STMSelectOutletTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSelectOutletTVC.h"

#import "STMDataModel.h"

#import "STMBasketNC.h"
#import "STMBasketPositionsTVC.h"


#define TABLE_WIDTH 512
#define TABLE_HEIGHT 512

@interface STMSelectOutletTVC ()


@end


@implementation STMSelectOutletTVC

@synthesize resultsController = _resultsController;

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
        
        NSSortDescriptor *partnerNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"partner.name"
                                                                                    ascending:YES
                                                                                     selector:@selector(compare:)];
        
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
    
    NSPredicate *outletPredicate = [NSPredicate predicateWithFormat:@"partner.name != %@", nil];
        
    [subpredicates addObject:outletPredicate];
    
    if ([self.searchBar isFirstResponder] && ![self.searchBar.text isEqualToString:@""]) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text]];
    }
    
    [subpredicates addObject:[STMPredicate predicateWithNoFantoms]];
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return predicate;
    
}

- (STMBasketNC *)basketNC {
    
    if ([self.navigationController isKindOfClass:[STMBasketNC class]]) {
        return (STMBasketNC *)self.navigationController;
    } else {
        return nil;
    }

}

#pragma mark - Table view data source

- (NSString *)cellIdentifier {
    return @"outletCell";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [STMFunctions shortCompanyName:[super tableView:tableView titleForHeaderInSection:section]];
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
    
    if ([outlet isEqual:[self basketNC].parentVC.selectedOutlet]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath *previouslySelectedIndexPath = nil;
    
    if ([self basketNC].parentVC.selectedOutlet) {
        
        STMOutlet *previouslySelectedOutlet = (STMOutlet * _Nonnull)[self basketNC].parentVC.selectedOutlet;
        previouslySelectedIndexPath = [self.resultsController indexPathForObject:previouslySelectedOutlet];

    }
    
    STMOutlet *selectedOutlet = [self.resultsController objectAtIndexPath:indexPath];
    [self basketNC].parentVC.selectedOutlet = selectedOutlet;
    
    if (previouslySelectedIndexPath)
        [self.tableView reloadRowsAtIndexPaths:@[previouslySelectedIndexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];

    STMBasketPositionsTVC *basketPositionsTVC = [[STMBasketPositionsTVC alloc] initWithOutlet:selectedOutlet];
    [[self basketNC] pushViewController:basketPositionsTVC animated:YES];

}

- (NSString *)detailedTextForOutlet:(STMOutlet *)outlet {

    NSUInteger positionsCount = outlet.basketPositions.count;

    if (positionsCount > 0) {
        
        NSString *pluralTypeString = [[STMFunctions pluralTypeForCount:positionsCount] stringByAppendingString:@"POSITIONS"];
        NSString *positionsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(pluralTypeString, nil)];

        return positionsCountString;
        
    } else {
        
        return nil;
        
    }
    
}


#pragma mark - view lifecycle

- (void)doneButtonPressed {

    [[self basketNC].parentVC dismissBasketPopover];
    
}

- (void)setupToolbar {
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];

    STMBarButtonItemDone *doneButton = [[STMBarButtonItemDone alloc] initWithTitle:NSLocalizedString(@"CLOSE", nil)
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(doneButtonPressed)];

    [self setToolbarItems:@[flexibleSpace, doneButton]];

}

- (void)customInit {
    
    self.title = NSLocalizedString(@"OUTLETS", nil);
    
    [self setupToolbar];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
        
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self performFetch];

    [super customInit];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
