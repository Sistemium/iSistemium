//
//  STMShipmentRouteSummaryTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRouteSummaryTVC.h"
#import "STMUI.h"
#import "STMNS.h"
#import "STMFunctions.h"


typedef NS_ENUM(NSInteger, STMSummaryType) {
    STMSummaryTypeBad,
    STMSummaryTypeExcess,
    STMSummaryTypeShortage
};


@interface STMShipmentRouteSummaryTVC ()

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSSet *shipments;


@end


@implementation STMShipmentRouteSummaryTVC

- (NSMutableArray *)tableData {
    
    if (!_tableData) {
        _tableData = [NSMutableArray array];
    }
    return _tableData;
    
}

- (NSSet *)shipments {
    
    if (!_shipments) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isShipped.boolValue == YES"];
        NSSet *shipments = [self.route valueForKeyPath:@"shipmentRoutePoints.@distinctUnionOfSets.shipments"];
        shipments = [shipments filteredSetUsingPredicate:predicate];

        _shipments = shipments;
        
    }
    return _shipments;
    
}

- (NSString *)cellIdentifier {
    return @"summaryCell";
}

- (void)prepareTableData {
    
    NSString *entityName = NSStringFromClass([STMArticle class]);
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:entityName];

    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    request.sortDescriptors = @[nameDescriptor];
    
    request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:[self requestPredicate]];
    
    NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];

    NSArray *availableTypes = @[@(STMSummaryTypeBad), @(STMSummaryTypeExcess), @(STMSummaryTypeShortage)];
    
    for (NSNumber *typeNumber in availableTypes) {
        
        STMSummaryType type = typeNumber.integerValue;
        
        NSPredicate *resultPredicate = nil;
        
        switch (type) {
            case STMSummaryTypeBad: {
                resultPredicate = [self badVolumePredicate];
                break;
            }
            case STMSummaryTypeExcess: {
                resultPredicate = [self excessVolumePredicate];
                break;
            }
            case STMSummaryTypeShortage: {
                resultPredicate = [self shortageVolumePredicate];
                break;
            }
            default: {
                break;
            }
        }
        
        NSArray *notShippingArticles = [result filteredArrayUsingPredicate:resultPredicate];
        
        if (notShippingArticles.count > 0) {
            
            NSArray *positions = [self filteredPositionsForArticlesArray:notShippingArticles];
            
            NSArray *articlesArray = [self articlesArrayForType:type withPositions:positions andArticles:notShippingArticles];
            
            [self.tableData addObject:@{typeNumber : articlesArray}];

        }
        
    }
    
}

- (NSArray *)filteredPositionsForArticlesArray:(NSArray *)articlesArray {
    
    NSArray *positions = [articlesArray valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shipment.isProcessed.boolValue == YES"];
    positions = [positions filteredArrayUsingPredicate:predicate];
    
    predicate = [NSPredicate predicateWithFormat:@"shipment in %@", self.shipments];
    positions = [positions filteredArrayUsingPredicate:predicate];

    return positions;
    
}

- (NSArray *)articlesArrayForType:(STMSummaryType)type withPositions:(NSArray *)positions  andArticles:(NSArray *)articles {
    
    NSString *volumeProperty = [self stringVolumePropertyForType:type];
    
    if (volumeProperty) {
        
        NSString *predicateFormat = [volumeProperty stringByAppendingString:@".integerValue > 0"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
        positions = [positions filteredArrayUsingPredicate:predicate];
        
        NSMutableArray *articlesArray = [NSMutableArray array];
        
        for (STMArticle *article in articles) {
            
            predicate = [NSPredicate predicateWithFormat:@"article == %@", article];
            NSArray *tempPositions = [positions filteredArrayUsingPredicate:predicate];
            
            NSString *keyPath = [@"@sum." stringByAppendingString:volumeProperty];
            NSNumber *volumeSum = [tempPositions valueForKeyPath:keyPath];
            
            [articlesArray addObject:@{@"article": article, @"volumeSum": volumeSum}];
            
        }

        return articlesArray;
        
    } else {
        return nil;
    }
    
}

- (NSString *)stringVolumePropertyForType:(STMSummaryType)type {
    
    NSString *volumeType = nil;
    
    switch (type) {
        case STMSummaryTypeBad: {
            volumeType = @"badVolume";
            break;
        }
        case STMSummaryTypeExcess: {
            volumeType = @"excessVolume";
            break;
        }
        case STMSummaryTypeShortage: {
            volumeType = @"shortageVolume";
            break;
        }
        default: {
            break;
        }
    }

    return volumeType;
    
}

- (NSPredicate *)requestPredicate {

    NSPredicate *badVolumePredicate = [self badVolumePredicate];
    NSPredicate *shortageVolumePredicate = [self shortageVolumePredicate];
    NSPredicate *excessVolumePredicate = [self excessVolumePredicate];

    NSCompoundPredicate *volumesPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[badVolumePredicate, shortageVolumePredicate, excessVolumePredicate]];

    NSPredicate *shipmentIsShippedPredicate = [NSPredicate predicateWithFormat:@"ANY shipmentPositions.shipment.isShipped.boolValue == YES"];
    NSPredicate *shipmentPredicate = [NSPredicate predicateWithFormat:@"ANY shipmentPositions.shipment in %@", self.shipments];

    NSCompoundPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[shipmentIsShippedPredicate, shipmentPredicate, volumesPredicate]];
    
    return finalPredicate;
    
}

- (NSPredicate *)badVolumePredicate {
    return [NSPredicate predicateWithFormat:@"ANY shipmentPositions.badVolume.integerValue > 0"];
}

- (NSPredicate *)shortageVolumePredicate {
    return [NSPredicate predicateWithFormat:@"ANY shipmentPositions.shortageVolume.integerValue > 0"];
}

- (NSPredicate *)excessVolumePredicate {
    return [NSPredicate predicateWithFormat:@"ANY shipmentPositions.excessVolume.integerValue > 0"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.tableData.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.tableData.count > section) {

        NSDictionary *sectionData = self.tableData[section];
        NSArray *sectionValue = sectionData.allValues.firstObject;
        return sectionValue.count;
        
    } else {
        
        return 0;
        
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.tableData.count > section) {
        
        NSDictionary *sectionData = self.tableData[section];
        NSNumber *sectionKey = sectionData.allKeys.firstObject;
        
        switch (sectionKey.integerValue) {
            case STMSummaryTypeBad:
                return NSLocalizedString(@"BAD VOLUME LABEL", nil);
                break;

            case STMSummaryTypeExcess:
                return NSLocalizedString(@"EXCESS VOLUME LABEL", nil);
                break;

            case STMSummaryTypeShortage:
                return NSLocalizedString(@"SHORTAGE VOLUME LABEL", nil);
                break;
                
            default:
                return nil;
                break;
        }
        
    } else {
        
        return nil;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom7TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];

    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *customCell = (STMCustom7TVCell *)cell;
        
        NSDictionary *sectionData = self.tableData[indexPath.section];
        NSArray *sectionValues = sectionData.allValues.firstObject;
        
        NSDictionary *sectionValue = sectionValues[indexPath.row];
        
        STMArticle *article = sectionValue[@"article"];
        NSNumber *volumeSum = sectionValue[@"volumeSum"];
        
        customCell.titleLabel.text = article.name;
        customCell.detailLabel.text = nil;
                
        STMLabel *infoLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
        infoLabel.text = [STMFunctions volumeStringWithVolume:volumeSum.integerValue andPackageRel:article.packageRel.integerValue];
        infoLabel.textAlignment = NSTextAlignmentRight;
        infoLabel.adjustsFontSizeToFitWidth = YES;
        
        customCell.accessoryView = infoLabel;

    }
    
    
    [super fillCell:cell atIndexPath:indexPath];
    
}


#pragma mark - height's cache

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    self.cachedCellsHeights[indexPath] = @(height);
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    return self.cachedCellsHeights[indexPath];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    [self prepareTableData];
    
    [super customInit];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
