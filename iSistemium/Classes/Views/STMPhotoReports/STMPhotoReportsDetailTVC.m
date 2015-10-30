//
//  STMPhotoReportsDetailTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportsDetailTVC.h"

#import "STMPhotoReportsSVC.h"


#define LOCATION_IMAGE_SIZE 24


@interface STMPhotoReportsDetailTVC () <UIActionSheetDelegate>

@property (nonatomic, strong) UIImage *locationImage;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *groupSwitcher;

@property (nonatomic, weak) STMPhotoReportsSVC *splitVC;

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

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
        
        NSSortDescriptor *outletNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"outlet.name"
                                                                               ascending:YES
                                                                                selector:@selector(caseInsensitiveCompare:)];
        
        NSSortDescriptor *campaignNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"campaign.name"
                                                                                 ascending:YES
                                                                                  selector:@selector(caseInsensitiveCompare:)];

        NSSortDescriptor *deviceCtsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                                                              ascending:YES
                                                                               selector:@selector(compare:)];
        
        NSString *sectionNameKeyPath = nil;
        
        switch (self.currentGrouping) {
            case STMPhotoReportGroupingCampaign: {
                
                request.sortDescriptors = @[campaignNameDescriptor, outletNameDescriptor, deviceCtsDescriptor];
                sectionNameKeyPath = @"campaign.name";
                
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                
                request.sortDescriptors = @[outletNameDescriptor, campaignNameDescriptor, deviceCtsDescriptor];
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

- (void)performFetch {
    
    self.resultsController = nil;
    
    if ([self.resultsController performFetch:nil]) {
        
        [self.tableView reloadData];
        
    }
    
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
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return predicate;
    
}


#pragma mark - table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom10TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(STMCustom10TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMPhotoReport *photoReport = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.pictureView.contentMode = UIViewContentModeScaleAspectFill;
    cell.pictureView.clipsToBounds = YES;
    cell.pictureView.image = [UIImage imageWithData:photoReport.imageThumbnail];
    
    cell.titleLabel.text = [[STMFunctions dateMediumTimeShortFormatter] stringFromDate:photoReport.deviceCts];
    
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
    
    NSLog(@"didSelectRowAtIndexPath %@", indexPath);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"???"
                                                        message:@"А тут вот не знаю, надо ли что-нибудь показать?"
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
    }];

}

- (void)locationButtonTapped:(id)sender event:(id)event {
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil) {
        
        NSLog(@"locationButtonTapped for indexPath %@", indexPath);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"!!!"
                                                            message:@"Тут я покажу карту с пином"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            
        }];
        
    }
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [super controllerDidChangeContent:controller];
    
    [self.splitVC.masterVC photoReportsWasUpdated];
    
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
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"GROUPING BY CAMPAIGN", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"GROUPING BY OUTLET", nil)];
        
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
