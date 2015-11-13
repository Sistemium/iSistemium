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

@property (nonatomic) BOOL showDataOnlyWithPhotos;
@property (nonatomic, strong) NSString *showDataOnlyWithPhotosDefaultsKey;

@property (nonatomic, strong) NSManagedObject *selectedObject;


@end


@implementation STMPhotoReportsFilterTVC

@synthesize resultsController = _resultsController;
@synthesize showDataOnlyWithPhotos = _showDataOnlyWithPhotos;

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

- (NSString *)showDataOnlyWithPhotosDefaultsKey {
    
    if (!_showDataOnlyWithPhotosDefaultsKey) {

        NSString *userID = [STMAuthController authController].userID;
        NSString *key = [@"showDataOnlyWithPhotos_" stringByAppendingString:userID];

        _showDataOnlyWithPhotosDefaultsKey = key;
        
    }
    return _showDataOnlyWithPhotosDefaultsKey;
    
}

- (BOOL)showDataOnlyWithPhotos {
    
    if (!_showDataOnlyWithPhotos) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL showDataOnlyWithPhotos = [defaults boolForKey:self.showDataOnlyWithPhotosDefaultsKey];
        
        _showDataOnlyWithPhotos = showDataOnlyWithPhotos;
        
    }
    return _showDataOnlyWithPhotos;
    
}

- (void)setShowDataOnlyWithPhotos:(BOOL)showDataOnlyWithPhotos {
    
    if (_showDataOnlyWithPhotos != showDataOnlyWithPhotos) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:showDataOnlyWithPhotos forKey:self.showDataOnlyWithPhotosDefaultsKey];
        [defaults synchronize];
        
        _showDataOnlyWithPhotos = showDataOnlyWithPhotos;
        
        [self performFetch];
        
    }
    
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
    
    if (self.showDataOnlyWithPhotos) {
        
        request.predicate = [NSPredicate predicateWithFormat:@"photoReports.@count > 0 AND ANY photoReports.campaign IN %@", self.selectedCampaignGroup.campaigns];
        
    } else {
        
//        request.predicate = [NSPredicate predicateWithFormat:@"ANY photoReports.campaign IN %@", self.selectedCampaignGroup.campaigns];

    }
    
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
    
    if (self.showDataOnlyWithPhotos) {
        
        request.predicate = [NSPredicate predicateWithFormat:@"campaignGroup == %@ AND name != %@ AND photoReports.@count > 0", self.selectedCampaignGroup, nil];

    } else {
        
        request.predicate = [NSPredicate predicateWithFormat:@"campaignGroup == %@ AND name != %@", self.selectedCampaignGroup, nil];

    }
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.document.managedObjectContext
                                                 sectionNameKeyPath:@"campaignGroup.displayName"
                                                          cacheName:nil];

}

- (void)performFetch {
    
    [self rememberSelectedObject];
    
    self.resultsController = nil;
    
    if ([self.resultsController performFetch:nil]) {
        
        [self.tableView reloadData];
        [self selectRememberedObject];
        
    }
    
}

- (void)rememberSelectedObject {
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath) self.selectedObject = [self.resultsController objectAtIndexPath:selectedIndexPath];
    
}

- (void)selectRememberedObject {
    
    if (self.selectedObject) {
        
        if ([self.resultsController.fetchedObjects containsObject:self.selectedObject]) {
            
            NSIndexPath *selectedIndexPath = [self.resultsController indexPathForObject:self.selectedObject];
            [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
            
        } else {
            
            self.selectedObject = nil;
            self.splitVC.detailVC.selectedCampaign = nil;
            self.splitVC.detailVC.selectedOutlet = nil;
            
        }
        
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
    
    cell.titleLabel.text = outlet.shortName;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"campaign.campaignGroup == %@", self.selectedCampaignGroup];
    NSSet *photoReports = [outlet.photoReports filteredSetUsingPredicate:predicate];
    
    if (photoReports.count > 0) {
        
        NSArray *campaigns = [photoReports valueForKeyPath:@"@distinctUnionOfObjects.campaign"];
        
        NSUInteger photoReportsCount = photoReports.count;
        NSString *photosCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)photoReportsCount, NSLocalizedString(@"PHOTO", nil)];
        
        NSUInteger campaignsCount = campaigns.count;
        NSString *campaignsString = NSLocalizedString([[STMFunctions pluralTypeForCount:campaignsCount] stringByAppendingString:@"CAMPAIGNS"], nil);
        NSString *campaignsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)campaignsCount, campaignsString];
        
        cell.detailLabel.text = [@[photosCountString, campaignsCountString] componentsJoinedByString:@" / "];

    } else {

        cell.detailLabel.text = NSLocalizedString(@"NO PHOTO", nil);

    }
    
    UIColor *textColor = (!outlet.isActive || [outlet.isActive boolValue]) ? [UIColor blackColor] : [UIColor redColor];

    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;

}

- (void)fillCampaignCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMCampaign *campaign = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = campaign.name;
    
    NSUInteger photoReportsCount = campaign.photoReports.count;
    
    UIColor *textColor = [UIColor blackColor];
    
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
        
        cell.detailLabel.text = NSLocalizedString(@"NO PHOTO", nil);

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


#pragma mark - photo filter button

- (void)setupPhotoFilterButton {
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    NSString *title = (self.showDataOnlyWithPhotos) ? NSLocalizedString(@"SHOW ALL DATA", nil) : NSLocalizedString(@"SHOW DATA ONLY WITH PHOTOS", nil);
    
    STMBarButtonItem *photoFilterButton = [[STMBarButtonItem alloc] initWithTitle:title
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(photoFilterButtonPressed)];
    
    [self setToolbarItems:@[flexibleSpace, photoFilterButton, flexibleSpace]];
    
}

- (void)photoFilterButtonPressed {
    
    self.showDataOnlyWithPhotos = !self.showDataOnlyWithPhotos;
    [self setupPhotoFilterButton];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self setupPhotoFilterButton];
    
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
