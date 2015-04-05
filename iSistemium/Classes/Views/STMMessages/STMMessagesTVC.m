//
//  STMMessagesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMMessagesTVC.h"

#import "STMMessage.h"
#import "STMMessagePicture.h"
#import "STMRecordStatus.h"

#import "STMMessageController.h"
#import "STMRecordStatusController.h"
#import "STMPicturesController.h"

#import "STMConstants.h"

#import "STMSyncer.h"

#import "STMUI.h"

//#define MESSAGE_BODY @"Главная задача месяца это РСП Шелфтокер с ценой 185 руб. Главная задача месяца это РСП Шелфтокер с ценой 185 руб. Главная задача месяца это РСП Шелфтокер с ценой 185 руб. Главная задача месяца это РСП Шелфтокер с ценой 185 руб. Главная задача месяца это РСП Шелфтокер с ценой 185 руб."

static NSString *cellIdentifier = @"messageCell";


@interface STMMessagesTVC () <UIActionSheetDelegate>

@end


#pragma mark - STMMessagesTVC

@implementation STMMessagesTVC

@synthesize resultsController = _resultsController;


- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMMessage class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:NO selector:@selector(compare:)]];
        //        request.predicate = [NSPredicate predicateWithFormat:@"ANY debts.summ != 0"];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.mainContext sectionNameKeyPath:@"xid" cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
//        [self.tableView reloadData];
        
    }
    
}

- (void)markMessageAsRead:(NSDictionary *)messageData{

    STMMessage *message = messageData[@"message"];
    NSIndexPath *indexPath = messageData[@"indexPath"];
    
    STMRecordStatus *recordStatus = [STMRecordStatusController recordStatusForObject:message];
    recordStatus.isRead = @YES;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self showUnreadCount];

    STMSyncer *syncer = [STMSessionManager sharedManager].currentSession.syncer;
    syncer.syncerState = STMSyncerSendDataOnce;

    [self.document saveDocument:^(BOOL success) {
        if (success) {
            
        }
    }];
    
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.resultsController.sections.count > 0) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
        STMMessage *message = [[sectionInfo objects] lastObject];
        return message.subject;
        
    } else {
        
        return nil;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static CGFloat cellHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellHeight = [[STMCustom3TVCell alloc] init].frame.size.height;
    });
    
    return cellHeight + 1.0f;  // Add 1.0f for the cell separator height
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom3TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    });
    
    STMMessage *message = [self.resultsController objectAtIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:nil withMessage:message];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGFloat height = size.height + 1.0f; // Add 1.0f for the cell separator height
    
    return height;
    
}

- (STMCustom3TVCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom3TVCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    STMMessage *message = [self.resultsController objectAtIndexPath:indexPath];

    [self fillCell:cell atIndexPath:indexPath withMessage:message];
    
    return cell;
    
}

- (void)fillCell:(STMCustom3TVCell *)cell atIndexPath:(NSIndexPath *)indexPath withMessage:(STMMessage *)message {
    
    cell.titleLabel.numberOfLines = 0;
    cell.detailLabel.numberOfLines = 0;
    
    NSDateFormatter *dateFormatter = [STMFunctions dateMediumTimeMediumFormatter];
    
    cell.titleLabel.text = [dateFormatter stringFromDate:message.cts];
    
    cell.detailLabel.text = message.body;
//    cell.detailLabel.text = MESSAGE_BODY;
    
    STMRecordStatus *recordStatus = [STMRecordStatusController recordStatusForObject:message];
    
    if ([recordStatus.isRead boolValue]) {
        
        cell.titleLabel.textColor = [UIColor blackColor];
        
    } else {
        
        cell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
        if (indexPath) [self performSelector:@selector(markMessageAsRead:) withObject:@{@"message": message, @"indexPath": indexPath} afterDelay:2];
        
    }
    
    if (message.pictures.count > 0) [self addImageFromMessage:message toCell:cell];

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

}

- (void)addImageFromMessage:(STMMessage *)message toCell:(STMCustom3TVCell *)cell {
    
    NSArray *picturesArray = [STMMessageController picturesArrayForMessage:message];
    
    STMMessagePicture *picture = picturesArray.firstObject;
    
    if (!picture.imageThumbnail && picture.href) {
        
        [STMPicturesController hrefProcessingForObject:picture];
        
    } else {
    
        UIImage *image = [UIImage imageWithData:picture.imageThumbnail];
        cell.pictureView.image = image;

    }
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMMessage *message = [self.resultsController objectAtIndexPath:indexPath];
    
    if (message.pictures.count > 0) [STMMessageController showMessageVCsForMessage:message];
    
    return indexPath;
    
}

- (void)showUnreadCount {
    
    NSMutableArray *messageXids = [NSMutableArray array];
    
    for (STMMessage *message in self.resultsController.fetchedObjects) [messageXids addObject:message.xid];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMRecordStatus class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"objectXid IN %@ && isRead == YES", messageXids];
    
    NSError *error;
    NSArray *result = [[self document].mainContext executeFetchRequest:request error:&error];
    NSInteger unreadCount = messageXids.count - result.count;
    
    NSString *badgeValue = unreadCount > 0 ? [NSString stringWithFormat:@"%lu", (unsigned long)unreadCount] : nil;
    self.navigationController.tabBarItem.badgeValue = badgeValue;
    [UIApplication sharedApplication].applicationIconBadgeNumber = [badgeValue integerValue];
    
}

- (void)messageIsRead {
    
    [self showUnreadCount];
    [self.tableView reloadData];
    
}

- (void)downloadPicture:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[STMMessagePicture class]]) {
        
        STMMessagePicture *messagePicture = (STMMessagePicture *)notification.object;
        
        NSIndexPath *indexPath = [self.resultsController indexPathForObject:messagePicture.message];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
}

#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageIsRead) name:@"messageIsRead" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadPicture:) name:@"downloadPicture" object:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    [STMMessageController generateTestMessages];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom3TVCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];

    [self performFetch];
    [self showUnreadCount];
    [self addObservers];
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
