//
//  STMPhotoReportsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportsTVC.h"

#define LOCATION_IMAGE_SIZE 24


@interface STMPhotoReportsTVC ()

@property (nonatomic, strong) UIImage *locationImage;


@end


@implementation STMPhotoReportsTVC

@synthesize resultsController = _resultsController;


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

- (void)updateTitle {
    
    NSMutableArray *titleArray = @[].mutableCopy;
    
    if (self.selectedCampaignGroup.name) [titleArray addObject:(NSString * _Nonnull)self.selectedCampaignGroup.name];
    if (self.selectedOutlet.name) [titleArray addObject:(NSString * _Nonnull)self.selectedOutlet.name];
    
    self.title = [titleArray componentsJoinedByString:@" / "];
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
        
        NSSortDescriptor *outletNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"outlet.name"
                                                                               ascending:YES
                                                                                selector:@selector(caseInsensitiveCompare:)];
        
        NSSortDescriptor *deviceCtsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                                                              ascending:YES
                                                                               selector:@selector(compare:)];
        
        request.sortDescriptors = @[outletNameDescriptor, deviceCtsDescriptor];
        
        request.predicate = [self currentPredicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"outlet.name"
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
    
    if (self.selectedOutlet) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"outlet == %@", self.selectedOutlet];
        [subpredicates addObject:predicate];
        
    }
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return predicate;
    
}


#pragma mark - table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom4TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(STMCustom4TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMPhotoReport *photoReport = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.pictureView.contentMode = UIViewContentModeScaleAspectFill;
    cell.pictureView.clipsToBounds = YES;
    cell.pictureView.image = [UIImage imageWithData:photoReport.imageThumbnail];
    
    cell.titleLabel.text = [[STMFunctions dateMediumTimeShortFormatter] stringFromDate:photoReport.deviceCts];
    
    cell.detailLabel.text = photoReport.campaign.name;
    
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
    
    cell.infoLabel.text = nil;
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


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom4TVCell class]) bundle:nil];
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
