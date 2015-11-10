//
//  STMPhotoReportsDetailTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportsDetailTVC.h"

#import "STMPhotoReportsSVC.h"
#import "STMPhotoReportVC.h"
#import "STMPhotoReportMapVC.h"


#define LOCATION_IMAGE_SIZE 24


@interface STMPhotoReportsDetailTVC () <UIActionSheetDelegate>

@property (nonatomic, strong) UIImage *locationImage;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *groupSwitcher;

@property (nonatomic, weak) STMPhotoReportsSVC *splitVC;

@property (nonatomic) BOOL shouldShowAddPhotoCell;
@property (nonatomic, strong) NSArray <NSDictionary <NSString *, NSArray *> *> *tableData;


@end


@implementation STMPhotoReportsDetailTVC

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
    return @"photoReportCell";
}

- (UIImage *)locationImage {
    
    if (!_locationImage) {
        
        UIImage *image = [UIImage imageNamed:@"location.png"];
        image = [STMFunctions resizeImage:image toSize:CGSizeMake(LOCATION_IMAGE_SIZE, LOCATION_IMAGE_SIZE)];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        _locationImage = image;
        
    }
    return _locationImage;
    
}

- (void)setSelectedCampaignGroup:(STMCampaignGroup *)selectedCampaignGroup {
    
    if (![_selectedCampaignGroup isEqual:selectedCampaignGroup]) {
        
        _selectedCampaignGroup = selectedCampaignGroup;
        
        [self updateTitle];
        [self performFetch];
        
    }
    
}

- (void)setSelectedOutlet:(STMOutlet *)selectedOutlet {
    
    if (![_selectedOutlet isEqual:selectedOutlet]) {
        
        _selectedOutlet = selectedOutlet;
        
        [self updateTitle];
        [self performFetch];
        
    }
    
}

- (void)setSelectedCampaign:(STMCampaign *)selectedCampaign {
    
    if (![_selectedCampaign isEqual:selectedCampaign]) {
        
        _selectedCampaign = selectedCampaign;

        [self updateTitle];
        [self performFetch];

    }
    
}

- (void)setCurrentGrouping:(STMPhotoReportGrouping)currentGrouping {
    
    _currentGrouping = currentGrouping;
    
    switch (currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            self.selectedCampaign = nil;
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            self.selectedOutlet = nil;
            break;
        }
        default: {
            break;
        }
    }
    
    [self updateGroupSwitcher];
    [self.filterTVC photoReportGroupingChanged];
    
}

- (void)updateTitle {
    
    NSMutableArray *titleArray = @[].mutableCopy;
    
    if (self.selectedCampaign.name) {
        [titleArray addObject:(NSString * _Nonnull)self.selectedCampaign.name];
    } else {
        if (self.selectedCampaignGroup.name) [titleArray addObject:(NSString * _Nonnull)self.selectedCampaignGroup.name];
    }
    
    if (self.selectedOutlet.name) [titleArray addObject:(NSString * _Nonnull)self.selectedOutlet.name];
    
    self.title = [titleArray componentsJoinedByString:@" / "];
    
}

- (BOOL)shouldShowAddPhotoCell {
    
    if (self.selectedCampaignGroup) {
        
        switch (self.currentGrouping) {
            case STMPhotoReportGroupingCampaign: {
                
                if (self.selectedOutlet) {
                    return YES;
                } else {
                    return NO;
                }
                
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                
                if (self.selectedCampaign) {
                    return YES;
                } else {
                    return NO;
                }
                
                break;
            }
            default: {
                break;
            }
        }
        
    } else {
        
        return NO;
        
    }
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
        
        NSString *sectionNameKeyPath = nil;
        
        switch (self.currentGrouping) {
            case STMPhotoReportGroupingCampaign: {
                
                request.sortDescriptors = @[[self campaignNameDescriptor], [self outletNameDescriptor], [self deviceCtsDescriptor]];
                sectionNameKeyPath = @"campaign.name";
                
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                
                request.sortDescriptors = @[[self outletNameDescriptor], [self campaignNameDescriptor], [self deviceCtsDescriptor]];
                sectionNameKeyPath = @"outlet.name";

                break;
            }
            default: {
                break;
            }
        }
        
        request.predicate = [self currentPredicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:sectionNameKeyPath
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSSortDescriptor *)nameDescriptor {
    
    return [NSSortDescriptor sortDescriptorWithKey:@"name"
                                         ascending:YES
                                          selector:@selector(caseInsensitiveCompare:)];
    
}

- (NSSortDescriptor *)outletNameDescriptor {
 
    return [NSSortDescriptor sortDescriptorWithKey:@"outlet.name"
                                         ascending:YES
                                          selector:@selector(caseInsensitiveCompare:)];

}

- (NSSortDescriptor *)campaignNameDescriptor {

    return [NSSortDescriptor sortDescriptorWithKey:@"campaign.name"
                                         ascending:YES
                                          selector:@selector(caseInsensitiveCompare:)];

}

- (NSSortDescriptor *)deviceCtsDescriptor {
 
    return [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                         ascending:NO
                                          selector:@selector(compare:)];

}

- (NSPredicate *)currentPredicate {
    
    NSMutableArray *subpredicates = @[].mutableCopy;
    
    if (self.selectedCampaignGroup) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"campaign.campaignGroup == %@", self.selectedCampaignGroup];
        [subpredicates addObject:predicate];
        
    }

    if (self.selectedCampaign) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"campaign == %@", self.selectedCampaign];
        [subpredicates addObject:predicate];
        
    }

    if (self.selectedOutlet) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"outlet == %@", self.selectedOutlet];
        [subpredicates addObject:predicate];
        
    }

    NSPredicate *imageThumbnailPredicate = [NSPredicate predicateWithFormat:@"imageThumbnail != %@", nil];
    [subpredicates addObject:imageThumbnailPredicate];

    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return predicate;
    
}

- (void)performFetch {
    
    if (self.shouldShowAddPhotoCell) {
        
        [self prepareTableDataForTakingPhoto];
        [self.tableView reloadData];
        
    } else {
        
        self.resultsController = nil;
        
        if ([self.resultsController performFetch:nil]) {
            
            [self.tableView reloadData];
            
        }
        
    }
    
}

- (void)prepareTableDataForTakingPhoto {
    
    switch (self.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            [self prepareCampaignsTableData];
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            [self prepareOutletsTableData];
            break;
        }
        default: {
            break;
        }
    }
    
}

- (void)prepareCampaignsTableData {
    
    NSMutableArray <NSDictionary <NSString *, NSArray *> *> *campaignsTableData = @[].mutableCopy;
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaign class])];

    request.sortDescriptors = @[[self nameDescriptor]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"campaignGroup == %@", self.selectedCampaignGroup];

    NSArray *campaigns = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    
    for (STMCampaign *campaign in campaigns) {
        
        NSArray *photoReports = (campaign.photoReports.count > 0) ?
                                [campaign.photoReports sortedArrayUsingDescriptors:@[[self outletNameDescriptor], [self deviceCtsDescriptor]]] :
                                @[];

        [campaignsTableData addObject:@{campaign.name : photoReports}];
        
    }
    
    self.tableData = campaignsTableData;

}

- (void)prepareOutletsTableData {
    
    NSMutableArray <NSDictionary <NSString *, NSArray *> *> *outletsTableData = @[].mutableCopy;
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
    
    request.sortDescriptors = @[[self nameDescriptor]];
    
    request.predicate = [STMPredicate predicateWithNoFantoms];
    
    NSArray *outlets = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    
    for (STMOutlet *outlet in outlets) {
        
        NSArray *photoReports = (outlet.photoReports.count > 0) ?
                                [outlet.photoReports sortedArrayUsingDescriptors:@[[self campaignNameDescriptor], [self deviceCtsDescriptor]]] :
                                @[];
        
        [outletsTableData addObject:@{outlet.name : photoReports}];
        
    }
    
    self.tableData = outletsTableData;

}


#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return (self.shouldShowAddPhotoCell) ?
            self.tableData.count :
            [super numberOfSectionsInTableView:tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return (self.shouldShowAddPhotoCell) ?
            self.tableData[section].allValues.firstObject.count + 1 :
            [super tableView:tableView numberOfRowsInSection:section];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return (self.shouldShowAddPhotoCell) ?
            self.tableData[section].allKeys.firstObject :
            [super tableView:tableView titleForHeaderInSection:section];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom10TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(STMCustom10TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if (self.shouldShowAddPhotoCell && indexPath.row == 0) {
        
        [self fillAddPhotoCell:cell];
        
    } else {

        STMPhotoReport *photoReport = [self photoReportForIndexPath:indexPath];
        [self fillCell:cell withPhotoReport:photoReport];

    }
    
}

- (void)fillAddPhotoCell:(STMCustom10TVCell *)cell {
    
    cell.titleLabel.text = @"ADD PHOTO";
    cell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
    
    cell.detailLabel.text = nil;
    cell.pictureView.image = nil;
    cell.accessoryView = nil;
    
}

- (void)fillCell:(STMCustom10TVCell *)cell withPhotoReport:(STMPhotoReport *)photoReport {
    
    cell.pictureView.contentMode = UIViewContentModeScaleAspectFill;
    cell.pictureView.clipsToBounds = YES;
    cell.pictureView.image = [UIImage imageWithData:photoReport.imageThumbnail];
    
    cell.titleLabel.text = [[STMFunctions dateMediumTimeShortFormatter] stringFromDate:photoReport.deviceCts];
    cell.titleLabel.textColor = [UIColor blackColor];

    switch (self.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            cell.detailLabel.text = photoReport.outlet.name;
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            cell.detailLabel.text = photoReport.campaign.name;
            break;
        }
        default: {
            break;
        }
    }
    
    if (photoReport.location) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0, 0.0, self.locationImage.size.width, self.locationImage.size.height);
        [button setBackgroundImage:self.locationImage forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(locationButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        
        cell.accessoryView = button;
        
    } else {
        
        cell.accessoryView = nil;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.shouldShowAddPhotoCell && indexPath.row == 0) {
        
        NSLog(@"ADD NEW PHOTO");
        
    } else {
            
        [self performSegueWithIdentifier:@"showPhotoReport" sender:indexPath];

    }

}

- (void)locationButtonTapped:(id)sender event:(id)event {
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil) {
        [self performSegueWithIdentifier:@"showPhotoReportMap" sender:indexPath];
    }
    
}

- (STMPhotoReport *)photoReportForIndexPath:(NSIndexPath *)indexPath {
    
    if (self.shouldShowAddPhotoCell) {
        
        if (self.tableData.count > indexPath.section) {
            
            NSArray *photoReports = self.tableData[indexPath.section].allValues.firstObject;
            
            if (photoReports.count >= indexPath.row) {
                
                STMPhotoReport *photoReport = photoReports[indexPath.row - 1];
                return photoReport;
                
            }
            
        }

    } else {
        
        STMPhotoReport *photoReport = [self.resultsController objectAtIndexPath:indexPath];
        return photoReport;

    }
    
    return nil;
    
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[NSIndexPath class]]) {

        STMPhotoReport *photoReport = [self photoReportForIndexPath:(NSIndexPath *)sender];

        if ([segue.identifier isEqualToString:@"showPhotoReport"]) {
            
            if ([segue.destinationViewController isKindOfClass:[STMPhotoReportVC class]]) {
                
                STMPhotoReportVC *vc = (STMPhotoReportVC *)segue.destinationViewController;
                vc.photoReport = photoReport;
                
            }
            
        } else if ([segue.identifier isEqualToString:@"showPhotoReportMap"]) {
            
            if ([segue.destinationViewController isKindOfClass:[STMPhotoReportMapVC class]]) {
                
                STMPhotoReportMapVC *vc = (STMPhotoReportMapVC *)segue.destinationViewController;
                vc.photoReport = photoReport;
                
            }
            
        }

    }
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [super controllerDidChangeContent:controller];
    
    [self.splitVC.masterVC photoReportsWasUpdated];
    [self.filterTVC photoReportsWasUpdated];
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {
        case 234:
            
            switch (buttonIndex) {
                case 0:
                    self.currentGrouping = STMPhotoReportGroupingCampaign;
                    break;

                case 1:
                    self.currentGrouping = STMPhotoReportGroupingOutlet;
                    break;

                default:
                    break;
            }
            
            [self performFetch];
//            [self updateGroupSwitcher];
            
            break;
            
        default:
            break;
    }
    
}


#pragma mark - group switcher

- (IBAction)groupSwitcherPressed:(id)sender {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        
        NSString *campaignButtonTitle = NSLocalizedString(@"GROUPING BY CAMPAIGN", nil);
        NSString *outletButtonTitle = NSLocalizedString(@"GROUPING BY OUTLET", nil);
        
        switch (self.currentGrouping) {
            case STMPhotoReportGroupingCampaign: {
                campaignButtonTitle = [@"✓ " stringByAppendingString:campaignButtonTitle];
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                outletButtonTitle = [@"✓ " stringByAppendingString:outletButtonTitle];
                break;
            }
            default: {
                break;
            }
        }
        
        [actionSheet addButtonWithTitle:campaignButtonTitle];
        [actionSheet addButtonWithTitle:outletButtonTitle];
        
        actionSheet.tag = 234;
        actionSheet.delegate = self;
        
        [actionSheet showFromBarButtonItem:self.groupSwitcher animated:YES];
        
    }];
    
}

- (void)setupGroupSwitcher {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [@"currentGrouping_" stringByAppendingString:[STMAuthController authController].userID];
    
    self.currentGrouping = [defaults integerForKey:key];

//    [self updateGroupSwitcher];
    
}

- (void)updateGroupSwitcher {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [@"currentGrouping_" stringByAppendingString:[STMAuthController authController].userID];
    [defaults setInteger:self.currentGrouping forKey:key];
    [defaults synchronize];
    
    switch (self.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            self.groupSwitcher.title = NSLocalizedString(@"GROUPING BY CAMPAIGN", nil);
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            self.groupSwitcher.title = NSLocalizedString(@"GROUPING BY OUTLET", nil);
            break;
        }
        default: {
            break;
        }
    }
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom10TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    [self setupGroupSwitcher];
    
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
