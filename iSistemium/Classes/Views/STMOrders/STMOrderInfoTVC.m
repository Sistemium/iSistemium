//
//  STMOrderInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrderInfoTVC.h"
#import "STMSaleOrderController.h"
#import "STMOrderEditablesVC.h"

static NSString *Custom2CellIdentifier = @"STMCustom2TVCell";


@interface STMOrderInfoTVC () <UIActionSheetDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *saleOrderPositions;
@property (nonatomic ,strong) NSArray *processingRoutes;

@property (nonatomic, strong) UIActionSheet *routesActionSheet;
@property (nonatomic) BOOL routesActionSheetWasVisible;

@property (nonatomic, strong) NSString *nextProcessing;
@property (nonatomic, strong) NSArray *editableProperties;
@property (nonatomic, strong) UIPopoverController *editablesPopover;
@property (nonatomic) BOOL editablesPopoverWasVisible;

@property (nonatomic, strong) NSMutableDictionary *cachedCellsHeights;

@end


@implementation STMOrderInfoTVC

@synthesize resultsController = _resultsController;


- (void)setSaleOrder:(STMSaleOrder *)saleOrder {
    
    if (saleOrder != _saleOrder) {
        
        _saleOrder = saleOrder;
        
        [self performFetch];
        
    }
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSaleOrder class])];
        
        NSSortDescriptor *xidDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO selector:@selector(compare:)];
        request.sortDescriptors = @[xidDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"xid == %@", self.saleOrder.xid];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
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
                
    }
    
}

- (NSArray *)saleOrderPositions {
    
    if (!_saleOrderPositions) {
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
//        NSSortDescriptor *volumeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"volume" ascending:YES selector:@selector(compare:)];
        
        _saleOrderPositions = [self.saleOrder.saleOrderPositions sortedArrayUsingDescriptors:@[nameDescriptor]];

    }
    return _saleOrderPositions;
    
}


//- (void)closeButtonPressed {
//    [self.parentVC cancelButtonPressed];
//}

- (void)statusLabelTapped:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        self.processingRoutes = [STMSaleOrderController availableRoutesForProcessing:self.saleOrder.processing];
        [self showRoutesActionSheet];
        
    }
    
}


#pragma mark - routesActionSheet

- (UIActionSheet *)routesActionSheet {
    
    if (!_routesActionSheet) {
        
        NSString *title = [STMSaleOrderController descriptionForProcessing:self.saleOrder.processing];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        if (self.processingRoutes.count > 0) {
            
            for (NSString *processing in self.processingRoutes) {
                [actionSheet addButtonWithTitle:[STMSaleOrderController labelForProcessing:processing]];
            }
            
        } else {
            [actionSheet addButtonWithTitle:@""];
        }
        
        _routesActionSheet = actionSheet;

    }
    return _routesActionSheet;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex >= 0 && buttonIndex < self.processingRoutes.count) {
        
        self.nextProcessing = self.processingRoutes[buttonIndex];
        
        self.editableProperties = [STMSaleOrderController editablesPropertiesForProcessing:self.nextProcessing];
        
        if (self.editableProperties) {
            
            [self hideRoutesActionSheet];
            
            [self performSelector:@selector(showEditablesPopover) withObject:nil afterDelay:0];
            
        } else {
            
            [STMSaleOrderController setProcessing:self.nextProcessing forSaleOrder:self.saleOrder];
            
        }
        
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.routesActionSheet = nil;
}

- (void)showRoutesActionSheet {
    
    if (!self.routesActionSheet.isVisible) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
        STMCustom2TVCell *cell = (STMCustom2TVCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if (cell) [self.routesActionSheet showFromRect:cell.detailLabel.frame inView:cell.contentView animated:YES];
        
    }
    
}

- (void)hideRoutesActionSheet {
    
    [self.routesActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    self.routesActionSheet = nil;
    
}


#pragma mark - editables popover

- (UIPopoverController *)editablesPopover {
    
    if (!_editablesPopover) {
        
        STMOrderEditablesVC *vc = [[STMOrderEditablesVC alloc] init];
        
        vc.fromProcessing = self.saleOrder.processing;
        vc.toProcessing = self.nextProcessing;
        vc.editableFields = self.editableProperties;
        vc.saleOrder = self.saleOrder;
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        popover.delegate = self;
        popover.popoverContentSize = CGSizeMake(vc.view.frame.size.width, vc.view.frame.size.height);
        
        vc.popover = popover;
        
        _editablesPopover = popover;
        
    }
    return _editablesPopover;
    
}

- (void)showEditablesPopover {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.saleOrder];
    STMCustom2TVCell *cell = (STMCustom2TVCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [self.editablesPopover presentPopoverFromRect:cell.detailLabel.frame
                                           inView:cell.contentView
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    
}

- (void)hideEditablesPopover {
    
    [self.editablesPopover dismissPopoverAnimated:YES];
    self.editablesPopover = nil;
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.editablesPopover = nil;
    
}


#pragma mark - rotate

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (self.routesActionSheet.isVisible) {
        
        self.routesActionSheetWasVisible = YES;
        [self hideRoutesActionSheet];
        
    }
    
    if (self.editablesPopover.isPopoverVisible) {
        self.editablesPopoverWasVisible = YES;
    }
    [self hideEditablesPopover];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    self.cachedCellsHeights = nil;
    [self.tableView reloadData];

    if (self.routesActionSheetWasVisible) {
        
        self.routesActionSheetWasVisible = NO;
        [self showRoutesActionSheet];
        
    }
    
    if (self.editablesPopoverWasVisible) {
        
        self.editablesPopoverWasVisible = NO;
        [self showEditablesPopover];
        
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            
            if (self.saleOrder.commentText && self.saleOrder.processingMessage) {
                return 7;
            } else if (self.saleOrder.commentText || self.saleOrder.processingMessage) {
                return 6;
            } else {
                return 5;
            }
            
            break;
            
        case 1:
            return self.saleOrder.saleOrderPositions.count;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSUInteger positionsCount = self.saleOrder.saleOrderPositions.count;
    NSString *pluralTypeString = [[STMFunctions pluralTypeForCount:positionsCount] stringByAppendingString:@"POSITIONS"];
    NSString *positionsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(pluralTypeString, nil)];
    
    switch (section) {
        case 0:
            return NSLocalizedString(@"ORDER INFO", nil);
            break;
            
        case 1:
//            return NSLocalizedString(@"ORDER POSITIONS", nil);
            return positionsCountString;
            break;
            
        default:
            return @"";
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static CGFloat standardCellHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        standardCellHeight = [[UITableViewCell alloc] init].frame.size.height;
    });
    
    return standardCellHeight + 1.0f;  // Add 1.0f for the cell separator height
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    if (indexPath.section == 0) {
        
        NSNumber *cachedHeight = [self getCachedHeightForIndexPath:indexPath];
        CGFloat height = (cachedHeight) ? cachedHeight.floatValue : [self heightForCellAtIndexPath:indexPath];
        
        return height;

    } else {
        
        return [self tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
        
    }
    
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom2TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:Custom2CellIdentifier];
    });
    
    [self fillOrderInfoCell:cell forRow:indexPath.row];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(cell.bounds));

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    
    CGFloat height = size.height + 1.0f; // Add 1.0f for the cell separator height
    
    [self putCachedHeight:height forIndexPath:indexPath];

    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    static NSString *infoCellIdentifier = @"orderInfoCell";
    static NSString *positionCellIdentifier = @"orderPositionCell";
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:Custom2CellIdentifier forIndexPath:indexPath];
            [self fillOrderInfoCell:(STMCustom2TVCell *)cell forRow:indexPath.row];
            break;

        case 1:
            cell = [[STMInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:positionCellIdentifier];
            [self fillOrderPositionCell:(STMInfoTableViewCell *)cell forRow:indexPath.row];
            break;

        default:
            break;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 1) {
        cell = nil;
    }

}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.section == 1) {
//        
//        STMSaleOrderPosition *saleOrderPosition = self.saleOrderPositions[indexPath.row];
//        STMArticle *article = saleOrderPosition.article;
//        
//        NSLog(@"saleOrderPosition %@", saleOrderPosition);
//        NSLog(@"article %@", article);
//        
//    }
    
    return indexPath;
    
}

- (void)fillOrderInfoCell:(STMCustom2TVCell *)cell forRow:(NSUInteger)row {
    
    for (UIGestureRecognizer *gestures in cell.detailLabel.gestureRecognizers) {
        [cell.detailLabel removeGestureRecognizer:gestures];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusLabelTapped:)];
    
    cell.titleLabel.numberOfLines = 0;
    cell.detailLabel.numberOfLines = 0;
    
    switch (row) {
        case 0:
            cell.titleLabel.text = NSLocalizedString(@"OUTLET", nil);
//            cell.titleLabel.text = @"Title title title title title title title title title title title title title title title title title ";
            cell.detailLabel.text = self.saleOrder.outlet.name;
            break;

        case 1:
            cell.titleLabel.text = NSLocalizedString(@"SALESMAN", nil);
            cell.detailLabel.text = self.saleOrder.salesman.name;
            break;

        case 2:
            cell.titleLabel.text = NSLocalizedString(@"DISPATCH DATE", nil);
            cell.detailLabel.text = [STMFunctions dayWithDayOfWeekFromDate:self.saleOrder.date];
            break;

        case 3:
            cell.titleLabel.text = NSLocalizedString(@"COST", nil);
            cell.detailLabel.text = [[STMFunctions currencyFormatter] stringFromNumber:self.saleOrder.totalCost];
            break;

        case 4:
            cell.titleLabel.text = NSLocalizedString(@"STATUS", nil);
            
            cell.detailLabel.userInteractionEnabled = YES;
            [cell.detailLabel addGestureRecognizer:tap];

            cell.detailLabel.text = [STMSaleOrderController labelForProcessing:self.saleOrder.processing];
        
            if ([STMSaleOrderController colorForProcessing:self.saleOrder.processing]) {
                cell.detailLabel.textColor =  [STMSaleOrderController colorForProcessing:self.saleOrder.processing];
            } else {
                cell.detailLabel.textColor = [UIColor blackColor];
            }
            break;

        case 5:
            (self.saleOrder.commentText) ? [self fillCommentForCell:cell] : [self fillProcessingMessageForCell:cell];
            break;

        case 6:
            [self fillProcessingMessageForCell:cell];
            break;

        default:
            break;
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
}

- (void)fillCommentForCell:(STMCustom2TVCell *)cell {
    
    cell.titleLabel.text = NSLocalizedString(@"COMMENT", nil);
    cell.detailLabel.text = self.saleOrder.commentText;
    
}

- (void)fillProcessingMessageForCell:(STMCustom2TVCell *)cell {
    
    cell.titleLabel.text = NSLocalizedString(@"PROCESSING MESSAGE", nil);
    cell.detailLabel.text = self.saleOrder.processingMessage;
    
//    NSLog(@"processingMessage %@", [cell.detailLabel.text dataUsingEncoding:NSUTF8StringEncoding]);
    
    cell.detailLabel.textColor = [STMSaleOrderController messageColorForProcessing:self.saleOrder.processing];

}

- (void)fillOrderPositionCell:(STMInfoTableViewCell *)cell forRow:(NSUInteger)row {
    
    STMSaleOrderPosition *saleOrderPosition = self.saleOrderPositions[row];
    
    cell.textLabel.text = saleOrderPosition.article.name;
//    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.detailTextLabel.text = [self detailedTextForSaleOrderPosition:saleOrderPosition];
    
    NSString *volumeUnitString = nil;
    
    int volume = [saleOrderPosition.volume intValue];
    int packageRel = [saleOrderPosition.article.packageRel intValue];
    
    if (packageRel != 0 && volume >= packageRel) {

        int package = floor(volume / packageRel);
        
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT1", nil);
        NSString *packageString = [NSString stringWithFormat:@"%d %@", package, volumeUnitString];

        int bottle = volume % packageRel;
        
        if (bottle > 0) {
            
            volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
            NSString *bottleString = [NSString stringWithFormat:@" %d %@", bottle, volumeUnitString];
            
            packageString = [packageString stringByAppendingString:bottleString];
            
        }
        
        cell.infoLabel.text = packageString;
        
    } else {
     
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
        cell.infoLabel.text = [NSString stringWithFormat:@"%@ %@", saleOrderPosition.volume, volumeUnitString];

    }
        
}

- (NSString *)detailedTextForSaleOrderPosition:(STMSaleOrderPosition *)saleOrderPosition {
    
    NSDecimalNumber *price0 = saleOrderPosition.price0;
    NSDecimalNumber *price1 = saleOrderPosition.price1;
    NSDecimalNumber *priceOrigin = saleOrderPosition.priceOrigin;
    
    NSString *detailedText = @"";
    NSString *appendString = @"";
    
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    appendString = [NSString stringWithFormat:@"%@%@", saleOrderPosition.article.pieceVolume, volumeUnitString];
    detailedText = [detailedText stringByAppendingString:appendString];
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    appendString = [NSString stringWithFormat:@", %@", NSLocalizedString(@"PRICE0", nil)];
    detailedText = [detailedText stringByAppendingString:appendString];
    
    appendString = [NSString stringWithFormat:@": %@", [numberFormatter stringFromNumber:price0]];
    detailedText = [detailedText stringByAppendingString:appendString];
    
    if ([price0 compare:price1] != NSOrderedSame) {
        
        appendString = [NSString stringWithFormat:@", %@", NSLocalizedString(@"PRICE1", nil)];
        detailedText = [detailedText stringByAppendingString:appendString];
        
        appendString = [NSString stringWithFormat:@": %@", [numberFormatter stringFromNumber:price1]];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    }
    
    if ([price0 compare:priceOrigin] != NSOrderedSame) {
        
        appendString = [NSString stringWithFormat:@", %@", NSLocalizedString(@"PRICE ORIGIN", nil)];
        detailedText = [detailedText stringByAppendingString:appendString];
        
        appendString = [NSString stringWithFormat:@": %@", [numberFormatter stringFromNumber:priceOrigin]];
        detailedText = [detailedText stringByAppendingString:appendString];
        
        NSDecimalNumber *result = [price0 decimalNumberBySubtracting:priceOrigin];
        result = [result decimalNumberByDividingBy:priceOrigin];
        
        NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:3 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];

        NSDecimalNumber *discount = [result decimalNumberByRoundingAccordingToBehavior:behavior];
        
        numberFormatter = [STMFunctions percentFormatter];

        NSString *discountString = [numberFormatter stringFromNumber:discount];
        
        appendString = [NSString stringWithFormat:@", %@", discountString];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    }

    return detailedText;
    
}


#pragma mark - cell's height caching

- (NSMutableDictionary *)cachedCellsHeights {
    
    if (!_cachedCellsHeights) {
        _cachedCellsHeights = [NSMutableDictionary dictionary];
    }
    return _cachedCellsHeights;
    
}

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {

        self.cachedCellsHeights[indexPath] = @(height);

    } else {
        
        NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:indexPath] objectID];
        self.cachedCellsHeights[objectID] = @(height);

    }
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return self.cachedCellsHeights[indexPath];
        
    } else {
        
        NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:indexPath] objectID];
        return self.cachedCellsHeights[objectID];
        
    }
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
}


#pragma mark - view lifecycle

- (void)customInit {

    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom2TVCell" bundle:nil] forCellReuseIdentifier:Custom2CellIdentifier];
    [self performFetch];

}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self customInit];

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
