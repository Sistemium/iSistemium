//
//  STMCatalogSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogSVC.h"

static NSString *defaultPriceTypeKey = @"priceTypeXid";
static NSString *showZeroStockKey = @"showZeroStock";


@interface STMCatalogSVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;


@end


@implementation STMCatalogSVC

@synthesize selectedPriceType = _selectedPriceType;
@synthesize showZeroStock = _showZeroStock;

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


#pragma mark - fetched results controller

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {

        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([STMPriceType class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[STMSessionManager sharedManager].currentSession document].mainContext sectionNameKeyPath:nil cacheName:nil];
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

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    self.availablePriceTypes = nil;
//}

- (BOOL)showZeroStock {

    if (!_showZeroStock) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id showZeroStock = [defaults objectForKey:showZeroStockKey];

        if (!showZeroStock) {
            
            showZeroStock = @(NO);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:showZeroStock forKey:showZeroStockKey];
            [defaults synchronize];

        }
        _showZeroStock = [showZeroStock boolValue];
        
    }
    return _showZeroStock;
    
}

- (void)setShowZeroStock:(BOOL)showZeroStock {
    
    if (showZeroStock != _showZeroStock) {
        
        _showZeroStock = showZeroStock;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(showZeroStock) forKey:showZeroStockKey];
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
            
            NSManagedObject *priceType = [STMObjectsController objectForXid:priceTypeXid];
            
            if ([priceType isKindOfClass:[STMPriceType class]]) _selectedPriceType = (STMPriceType *)priceType;
            
        } else {
            
            NSArray *priceTypes = [self availablePriceTypes];
            
            if (priceTypes.count > 0) {
                
                _selectedPriceType = priceTypes[0];
                
            } else {
                
                [[STMLogger sharedLogger] saveLogMessageWithText:@"priceTypes.count == 0"];
                
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
