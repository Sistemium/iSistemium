//
//  STMCatalogSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogSVC.h"

static NSString *defaultPriceTypeKey = @"priceTypeXid";
static NSString *showOnlyNonZeroStockKey = @"showOnlyNonZeroStock";
static NSString *showOnlyWithPicturesKey = @"showOnlyWithPictures";


@interface STMCatalogSVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;


@end


@implementation STMCatalogSVC

@synthesize selectedPriceType = _selectedPriceType;
@synthesize showOnlyNonZeroStock = _showOnlyNonZeroStock;
@synthesize showOnlyWithPictures = _showOnlyWithPictures;
@synthesize selectedInfoShowType = _selectedInfoShowType;


#pragma mark - subviews

- (STMCatalogDetailTVC *)detailTVC {
    
    if (!_detailTVC) {
        
        UINavigationController *navController = (UINavigationController *)self.viewControllers[1];
        
        UIViewController *detailTVC = navController.viewControllers[0];
        
        if ([detailTVC isKindOfClass:[STMCatalogDetailTVC class]]) {
            _detailTVC = (STMCatalogDetailTVC *)detailTVC;
        }
        
    }
    
    return _detailTVC;
    
}

- (STMCatalogMasterTVC *)masterTVC {
    
    if (!_masterTVC) {
        
        UINavigationController *navController = (UINavigationController *)self.viewControllers[0];
        
        UIViewController *masterTVC = navController.viewControllers[0];
        
        if ([masterTVC isKindOfClass:[STMCatalogMasterTVC class]]) {
            _masterTVC = (STMCatalogMasterTVC *)masterTVC;
        }
        
    }
    return _masterTVC;
    
}

- (NSArray *)catalogSettings {
    
    NSArray *availablePriceTypes = self.availablePriceTypes;
    NSArray *priceTypesArray = [availablePriceTypes valueForKeyPath:@"name"];
    NSUInteger index = [availablePriceTypes indexOfObject:self.selectedPriceType];
    NSDictionary *priceTypes = @{@"name": NSLocalizedString(@"PRICE_TYPE_LABEL", nil), @"current": @(index), @"available": priceTypesArray};
    
//    NSArray *stockTypesArray = @[NSLocalizedString(@"SHOW NONZERO STOCK ARTICLES", nil),
//                                 NSLocalizedString(@"SHOW ALL ARTICLES", nil)];
    NSDictionary *stockTypes = @{@"name": NSLocalizedString(@"SHOW ARTICLES STOCK", nil), @"current": @(self.showOnlyNonZeroStock), @"available": @"switch"};
    
//    NSArray *picturesTypesArray = @[NSLocalizedString(@"SHOW ALL ARTICLES", nil),
//                                    NSLocalizedString(@"SHOW ONLY WITH PICTURES", nil)];
    NSDictionary *picturesTypes = @{@"name": NSLocalizedString(@"SHOW PICTURES", nil), @"current": @(self.showOnlyWithPictures), @"available": @"switch"};
    
    NSArray *infoTypesArray = @[NSLocalizedString(@"PRICE_", nil),
                                NSLocalizedString(@"VOLUME", nil),
                                NSLocalizedString(@"STOCK", nil)];
    NSDictionary *infoTypes = @{@"name": NSLocalizedString(@"SHOW INFO", nil), @"current": @(self.selectedInfoShowType), @"available": infoTypesArray};
    
    
    return @[priceTypes,
             stockTypes,
             picturesTypes,
             infoTypes];
    
}

- (void)updateSettings:(NSArray *)newSettings {

    NSArray *oldSettings = [self catalogSettings];
    
    for (int index = 0; index < newSettings.count; index++) {
    
        NSUInteger oldValue = [oldSettings[index][@"current"] integerValue];
        NSUInteger newValue = [newSettings[index][@"current"] integerValue];

        if (oldValue != newValue) {
            
            switch (index) {
                    
                case 0:
                    self.selectedPriceType = self.availablePriceTypes[newValue];
                    break;
                    
                case 1:
                    self.showOnlyNonZeroStock = [@(newValue) boolValue];
                    break;
                    
                case 2:
                    self.showOnlyWithPictures = [@(newValue) boolValue];
                    break;
                    
                case 3:
                    self.selectedInfoShowType = newValue;
                    break;
                    
                default:
                    break;
                    
            }

        }
        
    }
    
}


#pragma mark - fetched results controller

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {

        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([STMPriceType class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        request.predicate = [STMPredicate predicateWithNoFantoms];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[STMSessionManager sharedManager].currentSession document].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"resultsController performFetch:&error: %@", error.localizedDescription);
    } else {

    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.masterTVC refreshTable];
//    NSLog(@"self.availablePriceTypes %@", self.availablePriceTypes);
    
}

- (BOOL)showOnlyNonZeroStock {

    if (!_showOnlyNonZeroStock) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id showOnlyNonZeroStock = [defaults objectForKey:showOnlyNonZeroStockKey];

        if (!showOnlyNonZeroStock) {
            
            showOnlyNonZeroStock = @(NO);
            [defaults setObject:showOnlyNonZeroStock forKey:showOnlyNonZeroStockKey];
            [defaults synchronize];

        }
        _showOnlyNonZeroStock = [showOnlyNonZeroStock boolValue];
        
    }
    return _showOnlyNonZeroStock;
    
}

- (void)setShowOnlyNonZeroStock:(BOOL)showOnlyNonZeroStock {
    
    if (showOnlyNonZeroStock != _showOnlyNonZeroStock) {
        
        _showOnlyNonZeroStock = showOnlyNonZeroStock;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(showOnlyNonZeroStock) forKey:showOnlyNonZeroStockKey];
        [defaults synchronize];

        [self.masterTVC refreshTable];
        [self.detailTVC refreshTable];

    }
    
}

- (BOOL)showOnlyWithPictures {
 
    if (!_showOnlyWithPictures) {
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id showOnlyWithPictures = [defaults objectForKey:showOnlyWithPicturesKey];
        
        if (!showOnlyWithPictures) {
            
            showOnlyWithPictures = @NO;
            [defaults setObject:showOnlyWithPictures forKey:showOnlyWithPicturesKey];
            [defaults synchronize];
            
        }
        
        _showOnlyWithPictures = [showOnlyWithPictures boolValue];
        
    }
    return _showOnlyWithPictures;
    
}

- (void)setShowOnlyWithPictures:(BOOL)showOnlyWithPictures {
    
    if (showOnlyWithPictures != _showOnlyWithPictures) {
        
        _showOnlyWithPictures = showOnlyWithPictures;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(showOnlyWithPictures) forKey:showOnlyWithPicturesKey];
        [defaults synchronize];
        
        [self.masterTVC refreshTable];
        [self.detailTVC refreshTable];
        
    }
    
}

#pragma mark - selectedPriceType

- (STMPriceType *)selectedPriceType {
    
    if (!_selectedPriceType) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id priceTypeXid = [defaults objectForKey:defaultPriceTypeKey];
        
        if (priceTypeXid && [priceTypeXid isKindOfClass:[NSData class]]) {
            
            NSManagedObject *priceType = [STMObjectsController objectForXid:priceTypeXid entityName:NSStringFromClass([STMPriceType class])];
            
            if ([priceType isKindOfClass:[STMPriceType class]]) _selectedPriceType = (STMPriceType *)priceType;
            
        } else {
            
            NSArray *priceTypes = [self availablePriceTypes];
            
            NSDictionary *appSettings = [[[STMSessionManager sharedManager].currentSession settingsController] currentSettingsForGroup:@"appSettings"];
            
            NSString *genericPriceTypeXidString = appSettings[@"genericPriceType"];
            
            if (genericPriceTypeXidString) {
                
                NSData *genericPriceTypeXidData = [STMFunctions xidDataFromXidString:genericPriceTypeXidString];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"xid == %@", genericPriceTypeXidData];
                NSArray *genericPriceTypes = [priceTypes filteredArrayUsingPredicate:predicate];

                if (genericPriceTypes.firstObject) {
                    
                    _selectedPriceType = genericPriceTypes.firstObject;
                    
                } else {

                    if (priceTypes.count > 0) {
                        _selectedPriceType = priceTypes.firstObject;
                    } else {
                        [[STMLogger sharedLogger] saveLogMessageWithText:@"priceTypes.count == 0"];
                    }
                    
                }
                
            } else {
            
                if (priceTypes.count > 0) {
                    _selectedPriceType = priceTypes.firstObject;
                } else {
                    [[STMLogger sharedLogger] saveLogMessageWithText:@"priceTypes.count == 0"];
                }

            }
            
        }
        
        if (_selectedPriceType) {
            
            [defaults setObject:_selectedPriceType.xid forKey:defaultPriceTypeKey];
            [defaults synchronize];
            
        }
        
    }
    return _selectedPriceType;
    
}


- (NSArray *)availablePriceTypes {
    
    NSSortDescriptor *priceTypeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *prices = [self.resultsController.fetchedObjects sortedArrayUsingDescriptors:@[priceTypeDescriptor]];

    return prices;
    
}

- (void)setSelectedPriceType:(STMPriceType *)selectedPriceType {
    
    if (![selectedPriceType isEqual:_selectedPriceType]) {
        
        _selectedPriceType = selectedPriceType;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_selectedPriceType.xid forKey:defaultPriceTypeKey];
        [defaults synchronize];
        
        [self.masterTVC refreshTable];
        [self.detailTVC refreshTable];
        
    }
    
}


#pragma mark - infoShowType

- (STMCatalogInfoShowType)selectedInfoShowType {
    
    if (!_selectedInfoShowType) {
        
        NSDictionary *appSettings = [[[STMSessionManager sharedManager].currentSession settingsController] currentSettingsForGroup:@"appSettings"];
        NSString *infoShowType = appSettings[@"catalogue.cell.right"];
        
        if ([infoShowType isEqualToString:@"price"]) {
            _selectedInfoShowType = STMCatalogInfoShowPrice;
        } else if ([infoShowType isEqualToString:@"pieceVolume"]) {
            _selectedInfoShowType = STMCatalogInfoShowPieceVolume;
        } else if ([infoShowType isEqualToString:@"stock"]) {
            _selectedInfoShowType = STMCatalogInfoShowStock;
        } else {
            _selectedInfoShowType = STMCatalogInfoShowPrice;
        }
        
    }
    return _selectedInfoShowType;

}

- (void)setSelectedInfoShowType:(STMCatalogInfoShowType)selectedInfoShowType {

    if (selectedInfoShowType != _selectedInfoShowType) {
    
        NSString *infoShowType = @"";
        
        switch (selectedInfoShowType) {
            case STMCatalogInfoShowPrice: {
                infoShowType = @"price";
                break;
            }
            case STMCatalogInfoShowPieceVolume: {
                infoShowType = @"pieceVolume";
                break;
            }
            case STMCatalogInfoShowStock: {
                infoShowType = @"stock";
                break;
            }
            default: {
                break;
            }
        }
        
        [[[STMSessionManager sharedManager].currentSession settingsController] setNewSettings:@{@"catalogue.cell.right": infoShowType} forGroup:@"appSettings"];
        
        _selectedInfoShowType = selectedInfoShowType;
        
        [self.detailTVC refreshTable];

    }
    
}


- (void)setCurrentArticleGroup:(STMArticleGroup *)currentArticleGroup {
    
    if (_currentArticleGroup != currentArticleGroup) {
        
        _currentArticleGroup = currentArticleGroup;
        
        [self.detailTVC refreshTable];
        [self.detailTVC hideKeyboard];
        
    }
    
}

- (NSArray *)nestedArticleGroups {
    
    if (!self.currentArticleGroup) {
        
        return nil;
        
    } else {
        
        NSMutableArray *array = [NSMutableArray array];
        [self addChildGroupsFromArticleGroup:self.currentArticleGroup toArray:array];
        
        return array;
    
    }
    
}

- (void)addChildGroupsFromArticleGroup:(STMArticleGroup *)articleGroup toArray:(NSMutableArray *)array {
    
    [array addObject:articleGroup];
    
    for (STMArticleGroup *childGroup in articleGroup.articleGroups) {
        [self addChildGroupsFromArticleGroup:childGroup toArray:array];
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.currentArticleGroup = nil;
    [self performFetch];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

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
