//
//  STMPickedPositionsListTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMPickedPositionsListTVC.h"

#import "STMPickedPositionsInfoTVC.h"


@interface STMPickedPositionsListTVC ()

@property (nonatomic, strong) NSArray <STMPickingOrderPosition *> *tableData;


@end


@implementation STMPickedPositionsListTVC

@synthesize resultsController = _resultsController;

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPickingOrderPosition class])];
        
        NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord"
                                                                        ascending:YES
                                                                         selector:@selector(compare:)];
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];

        request.sortDescriptors = @[ordDescriptor, nameDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"pickingOrder == %@ AND pickingOrderPositionsPicked.@count > 0", self.pickingOrder];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
    }
    return _resultsController;
    
}

- (NSArray <STMPickingOrderPosition *> *)tableData {
    
    if (!_tableData) {
        
        if (self.pickingOrder) {
            
            NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord"
                                                                            ascending:YES
                                                                             selector:@selector(compare:)];
            
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name"
                                                                             ascending:YES
                                                                              selector:@selector(caseInsensitiveCompare:)];
            
            NSArray *positions = [self.pickingOrder.pickingOrderPositions sortedArrayUsingDescriptors:@[ordDescriptor, nameDescriptor]];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nonPickedVolume == 0"];
            
            positions = [positions filteredArrayUsingPredicate:[STMPredicate predicateWithNoFantomsFromPredicate:predicate]];
            
            _tableData = positions;
            
        } else {
            
            _tableData = @[];
            
        }
        
    }
    return _tableData;
    
}


#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//    return self.tableData.count;
    return self.resultsController.fetchedObjects.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.pickingOrder.ndoc;
}

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom5TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom5TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom5TVCell class]]) {
        [self fillPickingOrderArticleCell:(STMCustom5TVCell *)cell atIndexPath:indexPath];
    }
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillPickingOrderArticleCell:(STMCustom5TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
//    STMPickingOrderPosition *pickingPosition = self.tableData[indexPath.row];
    STMPickingOrderPosition *pickingPosition = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = pickingPosition.article.name;
    cell.detailLabel.text = pickingPosition.ord.stringValue;
    cell.infoLabel.text = [STMFunctions volumeStringWithVolume:pickingPosition.volume.integerValue
                                                 andPackageRel:pickingPosition.article.packageRel.integerValue];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.pickingOrder orderIsProcessed]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.pickingOrder orderIsProcessed]) {
        
//        STMPickingOrderPosition *pickingPosition = self.tableData[indexPath.row];
        STMPickingOrderPosition *pickingPosition = [self.resultsController objectAtIndexPath:indexPath];

        [self performSegueWithIdentifier:@"showPickedPositionInfo" sender:pickingPosition];
        
    }
    
}


#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPickedPositionInfo"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMPickedPositionsInfoTVC class]] &&
            [sender isKindOfClass:[STMPickingOrderPosition class]]) {
            
            STMPickedPositionsInfoTVC *pickedPositionsInfoTVC = (STMPickedPositionsInfoTVC *)segue.destinationViewController;
            pickedPositionsInfoTVC.position = (STMPickingOrderPosition *)sender;
            
            self.parentVC.pickedPositionsInfoTVC = pickedPositionsInfoTVC;
            
        }
        
    }
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom5TVCell class]) bundle:nil];
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
