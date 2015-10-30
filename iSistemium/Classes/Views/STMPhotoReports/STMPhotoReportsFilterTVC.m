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

- (void)photoReportsWasUpdated {
    [self.tableView reloadData];
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
    
    request.predicate = [NSPredicate predicateWithFormat:@"campaignGroup == %@ AND name != %@", self.selectedCampaignGroup, nil];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.document.managedObjectContext
                                                 sectionNameKeyPath:nil
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"campaign.campaignGroup == %@", self.selectedCampaignGroup];
    NSSet *photoReports = [outlet.photoReports filteredSetUsingPredicate:predicate];
    NSArray *campaigns = [photoReports valueForKeyPath:@"@distinctUnionOfObjects.campaign"];
    
    NSUInteger photoReportsCount = photoReports.count;
    NSString *photosCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)photoReportsCount, NSLocalizedString(@"PHOTO", nil)];
    
    NSUInteger campaignsCount = campaigns.count;
    NSString *campaignsString = NSLocalizedString([[STMFunctions pluralTypeForCount:campaignsCount] stringByAppendingString:@"CAMPAIGNS"], nil);
    NSString *campaignsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)campaignsCount, campaignsString];

    cell.detailLabel.text = [@[photosCountString, campaignsCountString] componentsJoinedByString:@" / "];
    
}

- (void)fillCampaignCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMCampaign *campaign = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = campaign.name;
    
    NSUInteger photoReportsCount = campaign.photoReports.count;
    
    UIColor *textColor = (photoReportsCount > 0) ? [UIColor blackColor] : [UIColor lightGrayColor];
    
    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;

    if (photoReportsCount > 0) {
    
        NSString *photosCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)photoReportsCount, NSLocalizedString(@"PHOTO", nil)];
        
        NSArray *outlets = [campaign.photoReports valueForKeyPath:@"@distinctUnionOfObjects.outlet"];
        NSUInteger outletsCount = outlets.count;
        NSString *outletsString = NSLocalizedString([[STMFunctions pluralTypeForCount:outletsCount] stringByAppendingString:@"OUTLETS"], nil);
        NSString *outletsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)outletsCount, outletsString];

        cell.detailLabel.text = [@[photosCountString, outletsCountString] componentsJoinedByString:@" / "];

    } else {
        
        cell.detailLabel.text = nil;

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    switch (self.splitVC.detailVC.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            [self tableView:tableView didSelectOutletAtIndexPath:indexPath];
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            [self tableView:tableView didSelectCampaignAtIndexPath:indexPath];
            break;
        }
        default: {
            break;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectOutletAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
    
    if ([outlet isEqual:self.splitVC.detailVC.selectedOutlet]) {
        
        self.splitVC.detailVC.selectedOutlet = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {
        
        self.splitVC.detailVC.selectedOutlet = outlet;
        
    }

}

- (void)tableView:(UITableView *)tableView didSelectCampaignAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    STMCampaign *campaign = [self.resultsController objectAtIndexPath:indexPath];
    
    if ([campaign isEqual:self.splitVC.detailVC.selectedCampaign]) {
        
        self.splitVC.detailVC.selectedCampaign = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {
        
        self.splitVC.detailVC.selectedCampaign = campaign;
        
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
