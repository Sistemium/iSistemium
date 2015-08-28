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
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"xid" cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSString *)cellIdentifier {
    return @"messageCell";
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

    [STMMessageController markMessageAsRead:message];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self showUnreadCount];
    
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

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom3TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });

    return cell;
    
}

- (STMCustom3TVCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom3TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];

    [self fillCell:cell atIndexPath:indexPath];

    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom3TVCell class]]) {
        
        STMCustom3TVCell *customCell = (STMCustom3TVCell *)cell;
        
        STMMessage *message = [self.resultsController objectAtIndexPath:indexPath];
        
        [self fillCell:customCell atIndexPath:indexPath withMessage:message];
        
        STMRecordStatus *recordStatus = [STMRecordStatusController existingRecordStatusForXid:message.xid];
        
        UIColor *textColor = ([recordStatus.isRead boolValue]) ? [UIColor blackColor] : ACTIVE_BLUE_COLOR;
        
        customCell.titleLabel.textColor = textColor;

    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillCell:(STMCustom3TVCell *)cell atIndexPath:(NSIndexPath *)indexPath withMessage:(STMMessage *)message {
    
    cell.titleLabel.numberOfLines = 0;
    cell.detailLabel.numberOfLines = 0;
    
    [[cell.pictureView viewWithTag:555] removeFromSuperview];
    cell.pictureView.image = nil;
    
    NSDateFormatter *dateFormatter = [STMFunctions dateMediumTimeMediumFormatter];
    
    cell.titleLabel.text = [dateFormatter stringFromDate:message.deviceCts];
    
    cell.detailLabel.text = message.body;
//    cell.detailLabel.text = MESSAGE_BODY;
    
    if (message.pictures.count > 0) [self addImageFromMessage:message toCell:cell];

}

- (void)addImageFromMessage:(STMMessage *)message toCell:(STMCustom3TVCell *)cell {
    
    NSArray *picturesArray = [STMMessageController sortedPicturesArrayForMessage:message];
    
    STMMessagePicture *picture = picturesArray.lastObject;
    
    if (!picture.imageThumbnail && picture.href) {
        
        [STMPicturesController hrefProcessingForObject:picture];
        [self addSpinnerToCell:cell];
        
    } else {
    
        UIImage *image = [UIImage imageWithData:picture.imageThumbnail];
        [[cell.pictureView viewWithTag:555] removeFromSuperview];
        cell.pictureView.image = image;

    }
    
}

- (void)addSpinnerToCell:(STMCustom3TVCell *)cell {
    
    UIView *view = [[UIView alloc] initWithFrame:cell.pictureView.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor whiteColor];
    view.alpha = 0.75;
    view.tag = 555;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = view.center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [spinner startAnimating];
    
    [view addSubview:spinner];
    
    [cell.pictureView addSubview:view];

}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMMessage *message = [self.resultsController objectAtIndexPath:indexPath];
    
    if (message.pictures.count > 0) [STMMessageController showMessageVCsForMessage:message];
    
    if (indexPath && message.pictures.count == 0) {
        
        [self performSelector:@selector(markMessageAsRead:)
                   withObject:@{@"message": message, @"indexPath": indexPath}
                   afterDelay:0];
        
    }

    return indexPath;
    
}

- (void)showUnreadCount {
    
    NSInteger unreadCount = [STMMessageController unreadMessagesCount];
    
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
        if (indexPath) [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
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
    
//    [STMMessageController generateTestMessages];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom3TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];

    [self performFetch];
    [self showUnreadCount];
    [self addObservers];
    
    [super customInit];
    
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
//    [self customInit];

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
