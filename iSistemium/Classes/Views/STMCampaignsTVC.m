//
//  STMCampaignTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignsTVC.h"

#import "STMCampaign.h"
#import "STMArticlesTVC.h"
#import "STMRootTBC.h"
#import "STMCampaignsSVC.h"
#import "STMFunctions.h"
#import "STMOutlet.h"
#import "STMPhotoReport.h"
#import "STMPhoto.h"
#import "STMConstants.h"

@interface STMCampaignsTVC ()

@property (nonatomic, strong) STMCampaignsSVC *splitVC;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation STMCampaignsTVC

@synthesize resultsController = _resultsController;

- (STMCampaignsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMCampaignsSVC class]]) {
            _splitVC = (STMCampaignsSVC *)self.splitViewController;
        }
        
    }
    
    return _splitVC;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaign class])];
        
        NSSortDescriptor *groupDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"campaignGroup.ord"
                                                                          ascending:YES
                                                                           selector:@selector(compare:)];
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[groupDescriptor, nameDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"name != %@", nil];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"campaignGroup.name"
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
    
//        NSLog(@"_resultsController %@", _resultsController);

    }
    
    return _resultsController;

}

- (void)photoReportsChanged:(NSNotification *)notification {
    
    STMCampaign *campaign = [notification userInfo][@"campaign"];
    
    NSUInteger section = 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
    NSUInteger row = [sectionInfo.objects indexOfObject:campaign];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}

#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoReportsChanged:) name:@"photoReportsChanged" object:nil];

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self addObservers];

    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    }
    
    self.title = NSLocalizedString(@"AD CAMPAIGNS", nil);
    
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    [self removeObservers];
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
    }

}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"campaignCell" forIndexPath:indexPath];
    
    STMCampaign *campaign = [self.resultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = campaign.name;
    
    int articlesCount = (int)campaign.articles.count;
    int picturesCount = (int)campaign.pictures.count;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"campaign == %@", campaign];
    NSError *error;
    NSArray *campaignPhotos = [self.document.managedObjectContext executeFetchRequest:request error:&error];

    int photosCount = (int)campaignPhotos.count;
    
    NSString *articlesString = NSLocalizedString([[STMFunctions pluralTypeForCount:articlesCount] stringByAppendingString:@"ARTICLES"], nil);
    NSString *picturesString = NSLocalizedString([[STMFunctions pluralTypeForCount:picturesCount] stringByAppendingString:@"PICTURES"], nil);
    
    NSMutableArray *detailTextArray = [NSMutableArray array];
    
    if (articlesCount != 0) {
        
        articlesString = [NSString stringWithFormat:@"%d %@", articlesCount, articlesString];
        [detailTextArray addObject:articlesString];
        
    }
    
    if (picturesCount != 0) {
        
        picturesString = [NSString stringWithFormat:@"%d %@", picturesCount, picturesString];
        [detailTextArray addObject:picturesString];
        
    }
    
    if (photosCount != 0) {
        
        NSString *photosString = [NSString stringWithFormat:@"%d %@", photosCount, NSLocalizedString(@"PHOTO", nil)];
        [detailTextArray addObject:photosString];
        
    }
    
    cell.detailTextLabel.text = [detailTextArray componentsJoinedByString:@" / "];

    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
//    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0.48 blue:1 alpha:1];
    selectedBackgroundView.backgroundColor = ACTIVE_BLUE_COLOR;
    
    cell.selectedBackgroundView = selectedBackgroundView;
    
    UIColor *highlightedTextColor = [UIColor whiteColor];
    
    cell.textLabel.highlightedTextColor = highlightedTextColor;
    cell.detailTextLabel.highlightedTextColor = highlightedTextColor;
    
    return cell;
    
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCampaign *campaign = [self.resultsController objectAtIndexPath:indexPath];
    self.splitVC.detailVC.campaign = campaign;
    
    return indexPath;
    
}


@end
