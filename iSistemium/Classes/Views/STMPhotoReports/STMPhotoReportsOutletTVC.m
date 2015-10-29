//
//  STMPhotoReportsOutletTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportsOutletTVC.h"

#import "STMPhotoReportsSVC.h"


@interface STMPhotoReportsOutletTVC ()

@property (nonatomic, weak) STMPhotoReportsSVC *splitVC;


@end


@implementation STMPhotoReportsOutletTVC

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

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
        
        NSSortDescriptor *partnerNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"partner.name"
                                                                                    ascending:YES
                                                                                     selector:@selector(compare:)];
        
        NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"shortName"
                                                                             ascending:YES
                                                                              selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[partnerNameSortDescriptor, nameSortDescriptor];

        request.predicate = [NSPredicate predicateWithFormat:@"photoReports.@count > 0 AND ANY photoReports.campaign IN %@", self.selectedCampaignGroup.campaigns];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"partner.name"
                                                                            cacheName:nil];
        
    }
    return _resultsController;
    
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
    
    STMCustom7TVCell *customCell = nil;
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        customCell = (STMCustom7TVCell *)cell;
    }
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
    
    UIColor *textColor = (!outlet.isActive || [outlet.isActive boolValue]) ? [UIColor blackColor] : [UIColor redColor];
    
    customCell.titleLabel.textColor = textColor;
    customCell.detailLabel.textColor = textColor;
    
    customCell.titleLabel.text = outlet.shortName;
    
    NSUInteger count = outlet.photoReports.count;
//    NSString *pluralType = [STMFunctions pluralTypeForCount:count];
//    NSString *photosString = [pluralType stringByAppendingString:@"PHOTO"];
    
    NSString *photosCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)count, NSLocalizedString(@"PHOTO", nil)];
    
    customCell.detailLabel.text = photosCountString;
    
    [super fillCell:customCell atIndexPath:indexPath];
    
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