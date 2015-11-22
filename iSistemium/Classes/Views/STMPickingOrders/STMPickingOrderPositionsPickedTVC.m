//
//  STMPickingOrderPositionsPickedTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 21/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrderPositionsPickedTVC.h"

#import "STMPickingPositionVolumeTVC.h"
#import "STMObjectsController.h"


@interface STMPickingOrderPositionsPickedTVC ()

@property (nonatomic, strong) NSArray <STMPickingOrderPositionPicked *> *tableData;


@end


@implementation STMPickingOrderPositionsPickedTVC

- (NSArray <STMPickingOrderPositionPicked *> *)tableData {
    
    if (!_tableData) {
        
        if (self.pickingOrder) {
            
            NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pickingOrderPosition.ord"
                                                                            ascending:YES
                                                                             selector:@selector(compare:)];
            
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name"
                                                                             ascending:YES
                                                                              selector:@selector(caseInsensitiveCompare:)];
            
            NSSet *pickedPositions = [self.pickingOrder.pickingOrderPositions valueForKeyPath:@"@distinctUnionOfSets.pickingOrderPositionsPicked"];
            
            _tableData = [pickedPositions sortedArrayUsingDescriptors:@[ordDescriptor, nameDescriptor]];
            
        } else {
            
            _tableData = @[];
            
        }
        
    }
    return _tableData;
    
}

- (void)pickedPosition:(STMPickingOrderPositionPicked *)pickedPosition newVolume:(NSUInteger)volume andProductionInfo:(NSString *)info {
    
    if (volume > 0) {
        
        pickedPosition.volume = @(volume);
        pickedPosition.productionInfo = info;
        
        if ([self.tableData containsObject:pickedPosition]) {
            
            NSInteger index = [self.tableData indexOfObject:pickedPosition];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        
        [self.positionsTVC positionWasUpdated:pickedPosition.pickingOrderPosition];

    } else {
        
        self.tableData = nil;
        [self deletePickedPosition:pickedPosition];
        [self.tableView reloadData];
        
    }
    
    [[[STMSessionManager sharedManager].currentSession document] saveDocument:^(BOOL success) {
        
    }];

    [self.navigationController popToViewController:self animated:YES];

}

- (void)deletePickedPosition:(STMPickingOrderPositionPicked *)pickedPosition {
    
    STMPickingOrderPosition *position = pickedPosition.pickingOrderPosition;
    
    [STMObjectsController createRecordStatusAndRemoveObject:pickedPosition];
    
    [self.positionsTVC positionWasUpdated:position];
    
}


#pragma mark - cell's height caching

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *object = self.tableData[indexPath.row];
    NSManagedObjectID *objectID = object.objectID;
    
    if (objectID) {
        self.cachedCellsHeights[objectID] = @(height);
    }
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectID *objectID = [self.tableData[indexPath.row] objectID];
    
    return self.cachedCellsHeights[objectID];
    
}


#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
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
    
    STMPickingOrderPositionPicked *pickedPosition = self.tableData[indexPath.row];
    
    cell.titleLabel.text = pickedPosition.article.name;
    cell.detailLabel.text = pickedPosition.productionInfo;
    cell.infoLabel.text = [STMFunctions volumeStringWithVolume:pickedPosition.volume.integerValue andPackageRel:pickedPosition.article.packageRel.integerValue];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrderPositionPicked *pickedPosition = self.tableData[indexPath.row];
    [self performSegueWithIdentifier:@"showPositionVolume" sender:pickedPosition];

}


#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPositionVolume"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMPickingPositionVolumeTVC class]] &&
            [sender isKindOfClass:[STMPickingOrderPositionPicked class]]) {
            
            STMPickingPositionVolumeTVC *volumeTVC = (STMPickingPositionVolumeTVC *)segue.destinationViewController;
            volumeTVC.pickedPosition = (STMPickingOrderPositionPicked *)sender;
            volumeTVC.pickedPositionsTVC = self;
            
        }
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom5TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = NO;
    
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
