//
//  STMMessagesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMMessagesTVC.h"
#import "STMMessage.h"

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
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:NO selector:@selector(compare:)]];
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

#pragma mark - view lifecycle

- (void)customInit {
    
    [self performFetch];
    
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
    [self performFetch];

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
