//
//  STMPickedPositionsInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMPickedPositionsInfoTVC.h"

#import "STMObjectsController.h"


@interface STMPickedPositionsInfoTVC ()


@end


@implementation STMPickedPositionsInfoTVC

@synthesize resultsController = _resultsController;

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPickingOrderPositionPicked class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"pickingOrderPosition == %@", self.position];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        
    }
    return _resultsController;
    
}

- (void)setPosition:(STMPickingOrderPosition *)position {
    
    _position = position;
    
    [self performFetch];
    
}


#pragma mark - table data

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.position.article.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    STMCustom5TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMPickingOrderPositionPicked *positionPicked = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = [self barCodeScanStringForPositionPicked:positionPicked];
    
    cell.detailLabel.text = nil;
    
    NSString *volumeString = [STMFunctions volumeStringWithVolume:positionPicked.volume.integerValue
                                                    andPackageRel:positionPicked.article.packageRel.integerValue];
    
    cell.infoLabel.text = volumeString;
    
    return cell;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ([self.position.pickingOrder orderIsProcessed]) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        STMPickingOrderPositionPicked *positionPicked = [self.resultsController objectAtIndexPath:indexPath];
        [STMObjectsController createRecordStatusAndRemoveObject:positionPicked];
        
        // ????
        [self performFetch];
        // ????
        
    }
    
}


- (NSString *)barCodeScanStringForPositionPicked:(STMPickingOrderPositionPicked *)positionPicked {
    
    NSDictionary *barCodeScanStats = [self barCodeScanStatsForPositionPicked:positionPicked];
    
    NSMutableArray *stringComponents = @[].mutableCopy;
    
    for (NSString *barCodeScan in barCodeScanStats.allKeys) {
        
        NSInteger barCodeScanCount = [barCodeScanStats[barCodeScan] integerValue];
        
        if (barCodeScanCount > 1) {
            [stringComponents addObject:[NSString stringWithFormat:@"%@(%@)", barCodeScan, barCodeScanStats[barCodeScan]]];
        } else {
            [stringComponents addObject:[NSString stringWithFormat:@"%@", barCodeScan]];
        }
        
    }
    
    return [stringComponents componentsJoinedByString:@", "];
    
}

- (NSDictionary *)barCodeScanStatsForPositionPicked:(STMPickingOrderPositionPicked *)positionPicked {
    
    NSMutableDictionary *barCodeScanStats = @{}.mutableCopy;

    NSArray *barCodeScans = [self barCodeScansForPositionPicked:positionPicked];
    
    NSArray *distinctBarCodeScans = [[self barCodeScansForPositionPicked:positionPicked] valueForKeyPath:@"@distinctUnionOfObjects.code"];
    
    for (NSString *barCodeScan in distinctBarCodeScans) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", barCodeScan];
        
        barCodeScanStats[barCodeScan] = @([barCodeScans filteredArrayUsingPredicate:predicate].count);
        
    }
    
    return barCodeScanStats;
    
}

- (NSArray *)barCodeScansForPositionPicked:(STMPickingOrderPositionPicked *)positionPicked {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMBarCodeScan class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"destinationXid == %@", positionPicked.xid];
    
    NSArray *barCodeScans = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    
    return barCodeScans;
    
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
