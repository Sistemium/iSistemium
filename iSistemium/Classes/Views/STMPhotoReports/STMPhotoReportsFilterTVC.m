//
//  STMPhotoReportsFilterTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportsFilterTVC.h"

#import "STMPhotoReportsSVC.h"


@interface STMPhotoReportsFilterTVC ()

@property (nonatomic, weak) STMPhotoReportsSVC *splitVC;


@end


@implementation STMPhotoReportsFilterTVC

@synthesize resultsController = _resultsController;

- (STMPhotoReportsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMPhotoReportsSVC class]]) {
            _splitVC = (STMPhotoReportsSVC *)self.splitViewController;
        }
        
    }
    
    return _splitVC;
    
}

- (NSString *)cellIdentifier {
    return @"photoReportsOutletCell";
}

- (void)photoReportGroupingChanged {
    [self performFetch];
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        switch (self.splitVC.detailVC.currentGrouping) {
            case STMPhotoReportGroupingCampaign: {
                _resultsController = [self outletResultsController];
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                _resultsController = [self campaignResultsController];
                break;
            }
            default: {
                break;
            }
        }

    }
    return _resultsController;
    
}

- (NSFetchedResultsController *)outletResultsController {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
    
    NSSortDescriptor *partnerNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"partner.name"
                                                                                ascending:YES
                                                                                 selector:@selector(compare:)];
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"shortName"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
    
    request.sortDescriptors = @[partnerNameSortDescriptor, nameSortDescriptor];
    
    request.predicate = [NSPredicate predicateWithFormat:@"photoReports.@count > 0 AND ANY photoReports.campaign IN %@", self.selectedCampaignGroup.campaigns];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.document.managedObjectContext
                                                 sectionNameKeyPath:@"partner.name"
                                                          cacheName:nil];

}

- (NSFetchedResultsController *)campaignResultsController {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaign class])];
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:YES
                                                                      selector:@selector(caseInsensitiveCompare:)];
    
    request.sortDescriptors = @[nameDescriptor];
    
    request.predicate = [NSPredicate predicateWithFormat:@"campaignGroup == %@ AND name != %@ AND photoReports.@count > 0", self.selectedCampaignGroup, nil];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.document.managedObjectContext
                                                 sectionNameKeyPath:@"campaignGroup.displayName"
                                                          cacheName:nil];

}

- (void)performFetch {
    
    self.resultsController = nil;
    
    if ([self.resultsController performFetch:nil]) {
        [self.tableView reloadData];
    }
    
}


#pragma mark - table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];

    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {

        switch (self.splitVC.detailVC.currentGrouping) {
            case STMPhotoReportGroupingCampaign: {
                [self fillOutletCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                [self fillCampaignCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
                break;
            }
            default: {
                break;
            }
        }

    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillOutletCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
    
    UIColor *textColor = (!outlet.isActive || [outlet.isActive boolValue]) ? [UIColor blackColor] : [UIColor redColor];
    
    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;
    
    cell.titleLabel.text = outlet.shortName;
    
    NSUInteger count = outlet.photoReports.count;
    
    NSString *photosCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)count, NSLocalizedString(@"PHOTO", nil)];
    
    cell.detailLabel.text = photosCountString;
    
}

- (void)fillCampaignCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMCampaign *campaign = [self.resultsController objectAtIndexPath:indexPath];
    
    UIColor *textColor = [UIColor blackColor];
    
    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;
    
    cell.titleLabel.text = campaign.name;
    
    NSUInteger count = campaign.photoReports.count;
    
    NSString *photosCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)count, NSLocalizedString(@"PHOTO", nil)];
    
    cell.detailLabel.text = photosCountString;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
    
    if ([outlet isEqual:self.splitVC.detailVC.selectedOutlet]) {
        
        self.splitVC.detailVC.selectedOutlet = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {
        
        self.splitVC.detailVC.selectedOutlet = outlet;
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.clearsSelectionOnViewWillAppear = NO;

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];

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
