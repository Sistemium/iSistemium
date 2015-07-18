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


typedef NS_ENUM(NSInteger, STMDataType) {
    STMDataTypeBad,
    STMDataTypeShortage,
    STMDataTypeExcess
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
        _shipments = [self.route valueForKeyPath:@"shipmentRoutePoints.@distinctUnionOfSets.shipments"];
    }
    return _shipments;
    
}

- (NSString *)cellIdentifier {
    return @"summaryCell";
}

- (void)prepareTableData {

/*
    
    NSString *entityName = NSStringFromClass([STMShipmentPosition class]);
//    NSString *property = @"article";
//
//    STMEntityDescription *entity = [STMEntityDescription entityForName:entityName inManagedObjectContext:self.document.managedObjectContext];
//    NSPropertyDescription *entityProperty = entity.propertiesByName[property];

    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:entityName];

//    if (entityProperty) {

//        NSExpression *expression = [NSExpression expressionForKeyPath:property];
//        NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:@[expression]];
//        NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
//        ed.expression = countExpression;
//        ed.expressionResultType = NSInteger64AttributeType;
//        ed.name = @"count";
        
        

//        request.propertiesToFetch = @[entityProperty, ed];
//        request.propertiesToFetch = @[entityProperty];
//        request.propertiesToGroupBy = @[entityProperty];
//        request.resultType = NSDictionaryResultType;

        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
//        NSSortDescriptor *propertyDescriptor = [NSSortDescriptor sortDescriptorWithKey:property ascending:YES];
        
        request.sortDescriptors = @[nameDescriptor];

        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:[self requestPredicate]];

        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];

        
//        result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"count > 1"]];

        
//    }
    
    NSArray *badResult = [result filteredArrayUsingPredicate:[self badVolumePredicate]];
    NSArray *shortageResult = [result filteredArrayUsingPredicate:[self shortageVolumePredicate]];
    NSArray *excessResult = [result filteredArrayUsingPredicate:[self excessVolumePredicate]];
    
    if (badResult.count > 0) {
        [self.tableData addObject:@{@(STMDataTypeBad) : badResult}];
    }
    
    if (shortageResult.count > 0) {
        [self.tableData addObject:@{@(STMDataTypeShortage) : shortageResult}];
    }
    
    if (excessResult.count > 0) {
        [self.tableData addObject:@{@(STMDataTypeExcess) : excessResult}];
  }
 
*/
    
    
    NSString *entityName = NSStringFromClass([STMArticle class]);
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:entityName];

    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    request.sortDescriptors = @[nameDescriptor];
    
    request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:[self requestPredicate]];
    
    NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];

    NSArray *badResult = [result filteredArrayUsingPredicate:[self badVolumePredicate]];
    NSArray *shortageResult = [result filteredArrayUsingPredicate:[self shortageVolumePredicate]];
    NSArray *excessResult = [result filteredArrayUsingPredicate:[self excessVolumePredicate]];

    if (badResult.count > 0) {
        
        NSArray *positions = [self filteredPositionsForArticlesArray:badResult];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"badVolume.integerValue > 0"];
        positions = [positions filteredArrayUsingPredicate:predicate];

        NSMutableArray *articlesArray = [NSMutableArray array];
        
        for (STMArticle *article in badResult) {
            
            predicate = [NSPredicate predicateWithFormat:@"article == %@", article];
            NSArray *tempPositions = [positions filteredArrayUsingPredicate:predicate];
            
            NSNumber *volumeSum = [tempPositions valueForKeyPath:@"@sum.badVolume"];
            
            [articlesArray addObject:@{@"article": article, @"volumeSum": volumeSum}];
            
        }
        
        [self.tableData addObject:@{@(STMDataTypeBad) : articlesArray}];
        
    }
    
    if (shortageResult.count > 0) {
        
        NSArray *positions = [self filteredPositionsForArticlesArray:shortageResult];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortageVolume.integerValue > 0"];
        positions = [positions filteredArrayUsingPredicate:predicate];
        
        NSMutableArray *articlesArray = [NSMutableArray array];
        
        for (STMArticle *article in badResult) {
            
            predicate = [NSPredicate predicateWithFormat:@"article == %@", article];
            NSArray *tempPositions = [positions filteredArrayUsingPredicate:predicate];
            
            NSNumber *volumeSum = [tempPositions valueForKeyPath:@"@sum.shortageVolume"];
            
            [articlesArray addObject:@{@"article": article, @"volumeSum": volumeSum}];
            
        }

        [self.tableData addObject:@{@(STMDataTypeShortage) : articlesArray}];
        
    }
    
    if (excessResult.count > 0) {
        
        NSArray *positions = [self filteredPositionsForArticlesArray:excessResult];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"excessVolume.integerValue > 0"];
        positions = [positions filteredArrayUsingPredicate:predicate];
        
        NSMutableArray *articlesArray = [NSMutableArray array];
        
        for (STMArticle *article in badResult) {
            
            predicate = [NSPredicate predicateWithFormat:@"article == %@", article];
            NSArray *tempPositions = [positions filteredArrayUsingPredicate:predicate];
            
            NSNumber *volumeSum = [tempPositions valueForKeyPath:@"@sum.excessVolume"];
            
            [articlesArray addObject:@{@"article": article, @"volumeSum": volumeSum}];
            
        }
        
        [self.tableData addObject:@{@(STMDataTypeExcess) : articlesArray}];
        
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

- (NSPredicate *)requestPredicate {

    NSPredicate *badVolumePredicate = [self badVolumePredicate];
    NSPredicate *shortageVolumePredicate = [self shortageVolumePredicate];
    NSPredicate *excessVolumePredicate = [self excessVolumePredicate];

    NSCompoundPredicate *volumesPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[badVolumePredicate, shortageVolumePredicate, excessVolumePredicate]];

    NSPredicate *shipmentIsProcessedPredicate = [NSPredicate predicateWithFormat:@"ANY shipmentPositions.shipment.isProcessed.boolValue == YES"];
    NSPredicate *shipmentPredicate = [NSPredicate predicateWithFormat:@"ANY shipmentPositions.shipment in %@", self.shipments];

    NSCompoundPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[shipmentIsProcessedPredicate, shipmentPredicate, volumesPredicate]];
    
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
            case STMDataTypeBad:
                return NSLocalizedString(@"BAD VOLUME LABEL", nil);
                break;

            case STMDataTypeShortage:
                return NSLocalizedString(@"SHORTAGE VOLUME LABEL", nil);
                break;

            case STMDataTypeExcess:
                return NSLocalizedString(@"EXCESS VOLUME LABEL", nil);
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
//        NSNumber *sectionKey = sectionData.allKeys.firstObject;
        NSArray *sectionValues = sectionData.allValues.firstObject;
        
        NSDictionary *sectionValue = sectionValues[indexPath.row];
        
        STMArticle *article = sectionValue[@"article"];
        NSNumber *volumeSum = sectionValue[@"volumeSum"];
        
        customCell.titleLabel.text = article.name;
        customCell.detailLabel.text = nil;
        
//        NSNumber *volume = nil;
//        
//        switch (sectionKey.integerValue) {
//            case STMDataTypeBad:
//                volume = position.badVolume;
//                break;
//                
//            case STMDataTypeShortage:
//                volume = position.shortageVolume;
//                break;
//                
//            case STMDataTypeExcess:
//                volume = position.excessVolume;
//                break;
//                
//            default:
//                break;
//        }
        
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
