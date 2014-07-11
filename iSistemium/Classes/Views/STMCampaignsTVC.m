//
//  STMCampaignTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignsTVC.h"
#import <CoreData/CoreData.h>
#import "STMSessionManager.h"
#import "STMDocument.h"
#import "STMCampaign.h"
#import "STMArticlesTVC.h"
#import "STMRootTBC.h"
#import "STMCampaignsSVC.h"
#import "STMFunctions.h"
#import "STMOutlet.h"
#import "STMPhotoReport.h"
#import "STMPhoto.h"

@interface STMCampaignsTVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) STMCampaignsSVC *splitVC;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation STMCampaignsTVC

- (STMCampaignsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMCampaignsSVC class]]) {
            _splitVC = (STMCampaignsSVC *)self.splitViewController;
        }
        
    }
    
    return _splitVC;
    
}

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[STMSessionManager sharedManager].currentSession.document;
        
    }
    
    return _document;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaign class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"name != %@", nil];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
    
//        NSLog(@"_resultsController %@", _resultsController);

    }
    
    return _resultsController;

}

- (void)photoReportsChanged:(NSNotification *)notification {
    
    STMCampaign *campaign = [[notification userInfo] objectForKey:@"campaign"];
    
    NSUInteger section = 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
    NSUInteger row = [sectionInfo.objects indexOfObject:campaign];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (id)initWithStyle:(UITableViewStyle)style {
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.resultsController.sections.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
    return [sectionInfo numberOfObjects];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"campaignCell" forIndexPath:indexPath];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[indexPath.section];
    STMCampaign *campaign = sectionInfo.objects[indexPath.row];

    cell.textLabel.text = campaign.name;
    
    int articlesCount = (int)campaign.articles.count;
    int picturesCount = (int)campaign.pictures.count;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
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

    return cell;
    
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[indexPath.section];
    STMCampaign *campaign = sectionInfo.objects[indexPath.row];

    self.splitVC.detailVC.campaign = campaign;
    
    return indexPath;
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {

    //    NSLog(@"controllerWillChangeContent");

    self.selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView beginUpdates];
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
//    NSLog(@"controllerDidChangeContent");
    
    [self.tableView endUpdates];
    [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
//    [self.document saveDocument:^(BOOL success) {}];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
//    NSLog(@"anObject %@", anObject);
    
    if (type == NSFetchedResultsChangeDelete) {
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        //        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        NSLog(@"NSFetchedResultsChangeInsert");
        
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        NSLog(@"NSFetchedResultsChangeUpdate");
        
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
