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


@end


@implementation STMShipmentRouteSummaryTVC

- (NSMutableArray *)tableData {
    
    if (!_tableData) {
        _tableData = [NSMutableArray array];
    }
    return _tableData;
    
}

- (NSString *)cellIdentifier {
    return @"summaryCell";
}

- (void)prepareTableData {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipmentPosition class])];
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    request.sortDescriptors = @[nameDescriptor];
    request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:[self requestPredicate]];
    
    NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    
    NSArray *badResult = [result filteredArrayUsingPredicate:[self badVolumePredicate]];
    NSArray *shortageResult = [result filteredArrayUsingPredicate:[self shortageVolumePredicate]];
    NSArray *excessResult = [result filteredArrayUsingPredicate:[self excessVolumePredicate]];
    
    if (badResult.count > 0) {
        [self.tableData addObject:@{@(STMDataTypeBad) : badResult}];
    }
    
    if (shortageResult.count > 0) {
//        [self.tableData addObject:@{NSLocalizedString(@"SHORTAGE VOLUME LABEL", nil) : shortageResult}];
        [self.tableData addObject:@{@(STMDataTypeShortage) : shortageResult}];
    }
    
    if (excessResult.count > 0) {
//        [self.tableData addObject:@{NSLocalizedString(@"EXCESS VOLUME LABEL", nil) : excessResult}];
        [self.tableData addObject:@{@(STMDataTypeExcess) : excessResult}];
  }
    
}

- (NSPredicate *)requestPredicate {
    
    NSPredicate *badVolumePredicate = [self badVolumePredicate];
    NSPredicate *shortageVolumePredicate = [self shortageVolumePredicate];
    NSPredicate *excessVolumePredicate = [self excessVolumePredicate];

    NSCompoundPredicate *volumesPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[badVolumePredicate, shortageVolumePredicate, excessVolumePredicate]];

    NSPredicate *shipmentPredicate = [NSPredicate predicateWithFormat:@"shipment.isProcessed.boolValue == YES"];

    NSCompoundPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[shipmentPredicate, volumesPredicate]];
    
    return finalPredicate;
    
}

- (NSPredicate *)badVolumePredicate {
    return [NSPredicate predicateWithFormat:@"badVolume.integerValue > 0"];
}

- (NSPredicate *)shortageVolumePredicate {
    return [NSPredicate predicateWithFormat:@"shortageVolume.integerValue > 0"];
}

- (NSPredicate *)excessVolumePredicate {
    return [NSPredicate predicateWithFormat:@"excessVolume.integerValue > 0"];
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
        NSNumber *sectionKey = sectionData.allKeys.firstObject;
        NSArray *sectionValue = sectionData.allValues.firstObject;
        
        STMShipmentPosition *position = [sectionValue objectAtIndex:indexPath.row];
        
        customCell.titleLabel.text = position.article.name;
        customCell.detailLabel.text = nil;
        
        NSNumber *volume = nil;
        
        switch (sectionKey.integerValue) {
            case STMDataTypeBad:
                volume = position.badVolume;
                break;
                
            case STMDataTypeShortage:
                volume = position.shortageVolume;
                break;
                
            case STMDataTypeExcess:
                volume = position.excessVolume;
                break;
                
            default:
                break;
        }
        
        STMLabel *infoLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
        infoLabel.text = [STMFunctions volumeStringWithVolume:volume.integerValue andPackageRel:position.article.packageRel.integerValue];
        infoLabel.textAlignment = NSTextAlignmentRight;
        infoLabel.adjustsFontSizeToFitWidth = YES;
        
        customCell.accessoryView = infoLabel;

    }
    
    
    [super fillCell:cell atIndexPath:indexPath];
    
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
