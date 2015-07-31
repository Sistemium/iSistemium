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
    STMSummaryTypeShortage,
    STMSummaryTypeRegrade
};


@interface STMShipmentRouteSummaryTVC ()

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSSet *shippedShipments;


@end


@implementation STMShipmentRouteSummaryTVC

- (NSMutableArray *)tableData {
    
    if (!_tableData) {
        _tableData = [NSMutableArray array];
    }
    return _tableData;
    
}

- (NSSet *)shippedShipments {
    
    if (!_shippedShipments) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isShipped.boolValue == YES"];
        NSSet *shipments = [self.route valueForKeyPath:@"shipmentRoutePoints.@distinctUnionOfSets.shipments"];
        NSSet *shippedShipments = [shipments filteredSetUsingPredicate:predicate];

        _shippedShipments = shippedShipments;
        
    }
    return _shippedShipments;
    
}

- (NSString *)cellIdentifier {
    return @"summaryCell";
}

- (NSArray *)availableTypes {
    
    return @[@(STMSummaryTypeBad),
             @(STMSummaryTypeExcess),
             @(STMSummaryTypeShortage),
             @(STMSummaryTypeRegrade)];
    
}

- (void)prepareTableData {
    
    NSSet *positions = [self.shippedShipments valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    
    for (NSNumber *typeNumber in [self availableTypes]) {
        
        STMSummaryType type = typeNumber.integerValue;
        NSString *typeString = [self stringVolumePropertyForType:type];
        
        NSString *predicateFormat = [typeString stringByAppendingString:@".integerValue > 0"];
        NSPredicate *volumePredicate = [NSPredicate predicateWithFormat:predicateFormat];

        NSSet *filteredPositions = [positions filteredSetUsingPredicate:volumePredicate];
        
        if (filteredPositions.count > 0) {
            
            NSSortDescriptor *articleNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *articles = [[filteredPositions valueForKeyPath:@"@distinctUnionOfObjects.article"] sortedArrayUsingDescriptors:@[articleNameDescriptor]];
            
            NSMutableArray *articlesArray = [NSMutableArray array];
            
            for (STMArticle *article in articles) {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"article == %@", article];
                NSSet *articlePositions = [filteredPositions filteredSetUsingPredicate:predicate];
                NSString *keyPath = [@"@sum." stringByAppendingString:typeString];
                NSNumber *volumeSum = [articlePositions valueForKeyPath:keyPath];
                
                [articlesArray addObject:@{@"article": article, @"volumeSum": volumeSum}];
                
            }
            
            [self.tableData addObject:@{typeNumber : articlesArray}];

        }
        
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
        case STMSummaryTypeRegrade: {
            volumeType = @"regradeVolume";
            break;
        }
        default: {
            break;
        }
    }

    return volumeType;
    
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
                
            case STMSummaryTypeRegrade:
                return NSLocalizedString(@"REGRADE VOLUME LABEL", nil);
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
