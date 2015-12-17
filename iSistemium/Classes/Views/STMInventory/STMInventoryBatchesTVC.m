//
//  STMInventoryBatchesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryBatchesTVC.h"

#import "STMInventoryItemsVC.h"
#import "STMInventoryProcessController.h"


@interface STMInventoryBatchesTVC ()

@property (nonatomic, strong) UIAlertView *infoAlert;


@end


@implementation STMInventoryBatchesTVC

@synthesize resultsController = _resultsController;

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
    
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMInventoryBatch class])];
        
        NSSortDescriptor *ctsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                                                        ascending:NO
                                                                         selector:@selector(compare:)];
        request.sortDescriptors = @[ctsDescriptor];
        
        request.predicate = [STMPredicate predicateWithNoFantoms];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"ctsDayAsString"
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (void)showInfoAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
//        self.infoAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INVENTORY INFO TITLE", nil)
//                                                    message:NSLocalizedString(@"INVENTORY INFO MESSAGE", nil)
//                                                   delegate:nil
//                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                          otherButtonTitles:nil];
//        [self.infoAlert show];
        
    }];
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];
    
//    if (self.infoAlert.visible) {
//        [self.infoAlert dismissWithClickedButtonIndex:-1 animated:NO];
//    }
    
}


#pragma mark - table view data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMInventoryBatch *batch = [self.resultsController objectAtIndexPath:indexPath];

    [self fillCellTextLabel:cell.textLabel withInventoryBatch:batch];
    [self fillCellDetailLabel:cell.detailTextLabel withInventoryBatch:batch];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"showItems" sender:indexPath];
    
}

- (void)fillCellTextLabel:(UILabel *)textLabel withInventoryBatch:(STMInventoryBatch *)batch {

    UIFont *font = textLabel.font;
    
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: textLabel.textColor};

    NSString *deviceCtsString = [[STMFunctions noDateMediumTimeFormatter] stringFromDate:batch.deviceCts];
    
    NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:deviceCtsString
                                                                                  attributes:attributes];

    attributes = @{NSFontAttributeName: [UIFont fontWithName:font.fontName size:font.pointSize - 2],
                   NSForegroundColorAttributeName: textLabel.textColor};

    STMArticle *operatingArticle = [batch operatingArticle];
    
    if (operatingArticle.name) {
        
        [labelText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        
        NSString *articleNameString = operatingArticle.name;
        
        if (operatingArticle.extraLabel) {
            articleNameString = [NSString stringWithFormat:@"%@ %@", articleNameString, operatingArticle.extraLabel];
        }
        
        NSAttributedString *articleName = [[NSAttributedString alloc] initWithString:articleNameString
                                                                          attributes:attributes];
        
        [labelText appendAttributedString:articleName];

    }
    
    attributes = @{NSFontAttributeName: [UIFont fontWithName:font.fontName size:font.pointSize - 4],
                   NSForegroundColorAttributeName: textLabel.textColor};

    if (batch.code) {
        
        [labelText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        
        NSString *codeString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"ARTICLE", nil), batch.code];
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:codeString
                                                                               attributes:attributes];
        
        [labelText appendAttributedString:attributedString];

    }
    
    if (batch.stockBatchCode) {
        
        [labelText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];

        NSString *stockBatchCodeString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"STOCK BATCH", nil), batch.stockBatchCode];
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:stockBatchCodeString
                                                                               attributes:attributes];
        
        [labelText appendAttributedString:attributedString];

    }
    
    NSString *productionInfo = [batch.stockBatch displayProductionInfo];
    
    if (productionInfo) {
        
        [labelText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];

        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:productionInfo
                                                                               attributes:attributes];
        
        [labelText appendAttributedString:attributedString];

    }
    
    textLabel.numberOfLines = 0;
    textLabel.attributedText = labelText;
    
}

- (void)fillCellDetailLabel:(UILabel *)detailTextLabel withInventoryBatch:(STMInventoryBatch *)batch {
    
    NSUInteger bottlesCount = batch.inventoryBatchItems.count;
    
    NSDictionary *appSettings = [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"appSettings"];
    BOOL enableShowBottles = [appSettings[@"enableShowBottles"] boolValue];
    
    NSString *bottleString = (enableShowBottles) ? @"BOTTLES" : @"PIECES";
    NSString *pluralType = [STMFunctions pluralTypeForCount:bottlesCount];

    bottleString = [pluralType stringByAppendingString:bottleString];

    if (bottlesCount > 0) {
    
        detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", @(bottlesCount), NSLocalizedString(bottleString, nil)];

    } else {
        
        detailTextLabel.text = NSLocalizedString(bottleString, nil);
        
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        STMInventoryBatch *batch = [self.resultsController objectAtIndexPath:indexPath];
        [STMInventoryProcessController removeInventoryBatch:batch];
        
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showItems"] &&
        [segue.destinationViewController isKindOfClass:[STMInventoryItemsVC class]] &&
        [sender isKindOfClass:[NSIndexPath class]]) {
        
        STMInventoryBatch *inventoryBatch = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
        
        STMInventoryItemsVC *inventoryItemsVC = (STMInventoryItemsVC *)segue.destinationViewController;
        inventoryItemsVC.inventoryBatch = inventoryBatch;
        inventoryItemsVC.productionInfo = [inventoryBatch.stockBatch displayProductionInfo];
        
        NSLog(@"inventoryItemsVC.productionInfo %@", inventoryItemsVC.productionInfo);
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];

    if (self.resultsController.fetchedObjects.count == 0) {
        [self showInfoAlert];
    }
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [self performFetch];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
