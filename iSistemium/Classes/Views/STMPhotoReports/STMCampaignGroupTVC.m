//
//  STMCampaignGroupTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMCampaignGroupTVC.h"

#import "STMPhotoReportsSVC.h"


@interface STMCampaignGroupTVC ()

@property (nonatomic, strong) STMPhotoReportsSVC *splitVC;

@end

@implementation STMCampaignGroupTVC

@synthesize resultsController = _resultsController;

- (STMPhotoReportsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMPhotoReportsSVC class]]) {
            _splitVC = (STMPhotoReportsSVC *)self.splitViewController;
        }
        
    }
    
    return _splitVC;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaignGroup class])];
        
        NSSortDescriptor *groupDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                          ascending:NO
                                                                           selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[groupDescriptor];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"campaignGroupCell" forIndexPath:indexPath];
    
    STMCampaignGroup *campaignGroup = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [campaignGroup displayName];
    
    NSString *detailText = @"";
    
    if (campaignGroup.campaigns.count > 0) {
    
        NSString *campaignsString = NSLocalizedString([[STMFunctions pluralTypeForCount:campaignGroup.campaigns.count] stringByAppendingString:@"CAMPAIGNS"], nil);
        detailText = [detailText stringByAppendingString:[NSString stringWithFormat:@"%lu %@", (long unsigned)campaignGroup.campaigns.count, campaignsString]];

    } else {
        
        detailText = [detailText stringByAppendingString:NSLocalizedString(@"0CAMPAIGNS", nil)];
        
    }
    
    NSSet *photoReports = [campaignGroup.campaigns valueForKeyPath:@"@distinctUnionOfSets.photoReports"];
    
    if (photoReports.count > 0) {
        
        NSString *photoReportsStrings = [NSString stringWithFormat:@"%lu %@", (long unsigned)photoReports.count, NSLocalizedString(@"PHOTO", nil)];
        detailText = [detailText stringByAppendingString:@" / "];
        detailText = [detailText stringByAppendingString:photoReportsStrings];

    }
    
    cell.detailTextLabel.text = detailText;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    STMCampaignGroup *campaignGroup = [self.resultsController objectAtIndexPath:indexPath];
    
    if ([campaignGroup isEqual:self.splitVC.detailVC.selectedCampaignGroup]) {
        
        self.splitVC.detailVC.selectedCampaignGroup = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {
        
        self.splitVC.detailVC.selectedCampaignGroup = campaignGroup;
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self.resultsController performFetch:nil];
    
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
