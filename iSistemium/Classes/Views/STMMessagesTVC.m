//
//  STMMessagesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMMessagesTVC.h"
#import "STMMessage.h"
#import "STMConstants.h"
#import "STMSyncer.h"
#import "STMRecordStatus.h"
#import "STMObjectsController.h"

#define STMTextFont [UIFont systemFontOfSize:12]
#define STMDetailTextFont [UIFont systemFontOfSize:18]
#define STMHPadding 15

@interface STMMessagesTVC ()

@end


@interface STMMessageCell : UITableViewCell

@end

#pragma mark - STMMessageCell

@implementation STMMessageCell

- (void)layoutSubviews {
    
    self.textLabel.font = STMTextFont;
    self.detailTextLabel.font = STMDetailTextFont;
    
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [super layoutSubviews];

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {

    }
    
    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
}

@end


#pragma mark - STMMessagesTVC

@implementation STMMessagesTVC

@synthesize resultsController = _resultsController;


- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMMessage class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:NO selector:@selector(compare:)]];
        //        request.predicate = [NSPredicate predicateWithFormat:@"ANY debts.summ != 0"];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"xid" cacheName:nil];
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

    STMMessage *message = [messageData objectForKey:@"message"];
    NSIndexPath *indexPath = [messageData objectForKey:@"indexPath"];
    
    STMRecordStatus *recordStatus = [STMObjectsController recordStatusForObject:message];
    
    recordStatus.isRead = [NSNumber numberWithBool:YES];

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self showUnreadCount];

    STMSyncer *syncer = [STMSessionManager sharedManager].currentSession.syncer;
    syncer.syncerState = STMSyncerSendData;

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

- (STMMessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];

    STMMessage *message = [self.resultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    cell.textLabel.text = [dateFormatter stringFromDate:message.cts];
    cell.detailTextLabel.text = message.body;

    STMRecordStatus *recordStatus = [STMObjectsController recordStatusForObject:message];
    
    if ([recordStatus.isRead boolValue]) {
        
        cell.textLabel.textColor = [UIColor blackColor];
        
    } else {
        
        cell.textLabel.textColor = ACTIVE_BLUE_COLOR;
        [self performSelector:@selector(markMessageAsRead:) withObject:@{@"message": message, @"indexPath": indexPath} afterDelay:2];
        
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMMessageCell *cell = [[STMMessageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"messageCell"];
    STMMessage *message = [self.resultsController objectAtIndexPath:indexPath];
    
    CGFloat contentWidth = tableView.frame.size.width - 2 * STMHPadding;
    CGSize contentSize = {contentWidth, tableView.frame.size.height};
    UIFont *defaultFont = cell.detailTextLabel.font;
    
    CGRect defaultTextFrame = [message.body boundingRectWithSize:contentSize options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:defaultFont} context:nil];
    
    CGRect detailTextFrame = [message.body boundingRectWithSize:contentSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:STMDetailTextFont} context:nil];

    CGFloat hDiff = ceil(detailTextFrame.size.height) - ceil(defaultTextFrame.size.height);
    
    return cell.frame.size.height + hDiff;
    
}

- (void)showUnreadCount {
    
    NSMutableArray *messageXids = [NSMutableArray array];
    
    for (STMMessage *message in self.resultsController.fetchedObjects) {
        
        [messageXids addObject:message.xid];
        
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMRecordStatus class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"objectXid IN %@ && isRead == YES", messageXids];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    NSInteger unreadCount = messageXids.count - result.count;
    
    NSString *badgeValue = unreadCount > 0 ? [NSString stringWithFormat:@"%lu", (unsigned long)unreadCount] : nil;
    self.navigationController.tabBarItem.badgeValue = badgeValue;
    [UIApplication sharedApplication].applicationIconBadgeNumber = [badgeValue integerValue];
    
}

- (void)messageIsRead {
    
    [self showUnreadCount];
    [self.tableView reloadData];
    
}

#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageIsRead) name:@"messageIsRead" object:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    [self performFetch];
    [self showUnreadCount];
    [self addObservers];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
