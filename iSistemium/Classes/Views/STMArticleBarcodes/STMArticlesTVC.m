//
//  STMArticlesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 26/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticlesTVC.h"

#import "STMArticlesNC.h"
#import "STMArticlesSVC.h"
#import "STMArticleCodesTVC.h"

#import "STMBarCodeScanner.h"
#import "STMSoundController.h"


@interface STMArticlesTVC () <STMBarCodeScannerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) STMArticlesSVC *splitVC;
@property (nonatomic, weak) STMArticlesNC *articlesNC;
@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;

@property (nonatomic, strong) NSString *scannedBarcode;
@property (nonatomic, strong) UIAlertView *addBarcodeAlert;

@property (nonatomic, strong) STMArticle *selectedArticle;
@property (nonatomic, strong) STMArticleCodesTVC *codesTVC;


@end


@implementation STMArticlesTVC

@synthesize selectedArticle = _selectedArticle;
@synthesize resultsController = _resultsController;


- (STMArticlesSVC *)splitVC {
    
    if (!_splitVC) {
    
        if ([self.splitViewController isKindOfClass:[STMArticlesSVC class]]) {
            _splitVC = (STMArticlesSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (STMArticlesNC *)articlesNC {
    
    if (!_articlesNC) {
        
        if ([self.navigationController isKindOfClass:[STMArticlesNC class]]) {
            _articlesNC = (STMArticlesNC *)self.navigationController;
        }
        
    }
    return _articlesNC;
}

- (STMArticle *)selectedArticle {
    
    if (IPAD) {
        return self.splitVC.selectedArticle;
    }
    if (IPHONE) {
        return self.articlesNC.selectedArticle;
    }

    return nil;
    
}

- (void)setSelectedArticle:(STMArticle *)selectedArticle {
    
    if (IPAD) {
        self.splitVC.selectedArticle = selectedArticle;
    }
    
    if (IPHONE) {
        self.articlesNC.selectedArticle = selectedArticle;
    }
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
    
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        request.predicate = [self predicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (NSPredicate *)predicate {
    
    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
        return [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text];
    } else if (self.scannedBarcode) {
        return [NSPredicate predicateWithFormat:@"ANY barCodes.code == %@", self.scannedBarcode];
    } else {
        return nil;
    }

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [super searchBarTextDidBeginEditing:searchBar];
    self.scannedBarcode = nil;
    [self performFetch];
    
}

- (void)performFetch {
    
    self.selectedArticle = nil;

    [super performFetch];
    [self updateToolbar];
    
}

- (BOOL)isInActiveTab {
    
    if (IPHONE) {
        return [self.tabBarController.selectedViewController isEqual:self.navigationController];
    }
    
    if (IPAD) {
        return [self.tabBarController.selectedViewController isEqual:self.splitViewController];
    }
    
    return NO;
    
}


#pragma mark - table view data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMArticle *article = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", article.name, (article.extraLabel) ? article.extraLabel : @""];
    cell.detailTextLabel.text = @(article.barCodes.count).stringValue;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    STMArticle *article = [self.resultsController objectAtIndexPath:indexPath];
    
    if ([self.selectedArticle isEqual:article]) {
        
        self.selectedArticle = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    } else {
        
        self.selectedArticle = article;
        
    }

    if (IPHONE) {
        
        if ([self.articlesNC.topViewController isEqual:self.codesTVC]) {
            self.codesTVC.selectedArticle = self.selectedArticle;
        } else {
            [self performSegueWithIdentifier:@"showCodes" sender:indexPath];
        }
        
    }
    
    if (IPAD) {

//        STMArticle *article = [self.resultsController objectAtIndexPath:indexPath];
//        
//        if ([self.selectedArticle isEqual:article]) {
//            
//            self.selectedArticle = nil;
//            [tableView deselectRowAtIndexPath:indexPath animated:NO];
//            
//        } else {
//            
//            self.selectedArticle = article;
//
//        }

    }
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [super controllerDidChangeContent:controller];
    [self updateToolbar];
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showCodes"] &&
        [segue.destinationViewController isKindOfClass:[STMArticleCodesTVC class]] &&
        [sender isKindOfClass:[NSIndexPath class]]) {
        
        STMArticle *article = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
        
        self.codesTVC = (STMArticleCodesTVC *)segue.destinationViewController;
        self.codesTVC.selectedArticle = article;
        
    }
    
}


#pragma mark - barcode scanning

- (void)startBarcodeScanning {
    [self startIOSModeScanner];
}

- (void)startIOSModeScanner {
    
    self.iOSModeBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerIOSMode];
    self.iOSModeBarCodeScanner.delegate = self;
    [self.iOSModeBarCodeScanner startScan];
    
    if ([self.iOSModeBarCodeScanner isDeviceConnected]) {
        [self addBarcodeImage];
    }
    
}

- (void)stopBarcodeScanning {
    [self stopIOSModeScanner];
}

- (void)stopIOSModeScanner {
    
    [self.iOSModeBarCodeScanner stopScan];
    self.iOSModeBarCodeScanner = nil;
    [self removeBarcodeImage];

}

- (void)receiveArticleBarcode:(NSString *)barcode {
    
    self.scannedBarcode = barcode;

    if (self.selectedArticle) {
        
        NSArray *articleBarcodes = [self.selectedArticle.barCodes valueForKeyPath:@"@distinctUnionOfObjects.code"];
        
        if ([articleBarcodes containsObject:self.scannedBarcode]) {
            [STMSoundController say:NSLocalizedString(@"THIS BARCODE ALREADY LINKED WITH CURRENT ARTICLE", nil)];
        } else {
            [self showAddBarcodeAlertForBarcode:self.scannedBarcode andArticle:self.selectedArticle];
        }
        
    } else {
    
        [self searchBarCancelButtonClicked:self.searchBar];

    }
    
}


#pragma mark - UIAlertViewDelegate

- (void)showAddBarcodeAlertForBarcode:(NSString *)barcode andArticle:(STMArticle *)article {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (self.addBarcodeAlert.isVisible) {
            [self.addBarcodeAlert dismissWithClickedButtonIndex:-1 animated:NO];
        }
        
        NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"ADD BARCODE TO ARTICLE?", nil), barcode, article.name];
       
        self.addBarcodeAlert = [[UIAlertView alloc] initWithTitle:@""
                                                          message:alertMessage
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [self.addBarcodeAlert show];
        
    }];
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {

    if ([alertView isEqual:self.addBarcodeAlert]) {
        
        switch (buttonIndex) {
            case 1:
                [self addBarcode:self.scannedBarcode toArticle:self.selectedArticle];
                break;
                
            default:
                break;
        }
        
    }

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if ([alertView isEqual:self.addBarcodeAlert]) {
        
        switch (buttonIndex) {
            case 1:
                if (self.codesTVC) {
                    self.codesTVC.selectedArticle = self.selectedArticle;
                }
                break;
                
            default:
                break;
        }
        
    }
    
}

- (void)addBarcode:(NSString *)barcode toArticle:(STMArticle *)article {

    [STMBarCodeController addBarcode:barcode toArticle:article];
    self.selectedArticle = article;

}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type {
    
    if ([self isInActiveTab]) {
        
        NSLog(@"barCodeScanner receiveBarCode: %@ withType:%d", barcode, type);
        
        switch (type) {
            case STMBarCodeTypeUnknown: {
                
                break;
            }
            case STMBarCodeTypeArticle: {
                [self receiveArticleBarcode:barcode];
                break;
            }
            case STMBarCodeTypeExciseStamp: {
                
                break;
            }
            case STMBarCodeTypeStockBatch: {
                
                break;
            }
        }

    }
    
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error {
    NSLog(@"barCodeScanner receiveError: %@", error.localizedDescription);
}

- (void)deviceArrivalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE ARRIVAL", nil)];
        [self addBarcodeImage];
        
    }
    
}

- (void)deviceRemovalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE REMOVAL", nil)];
        [self removeBarcodeImage];
        
    }
    
}


#pragma mark - toolbars

- (void)updateToolbar {
    
    [self updateArticleCountInfo];
    [self updateClearFilterButton];
    
}

- (void)updateArticleCountInfo {
    
    NSInteger articleCount = self.resultsController.fetchedObjects.count;
    NSString *pluralType = [STMFunctions pluralTypeForCount:articleCount];
    NSString *articlePluralString = [pluralType stringByAppendingString:@"ARTICLES"];
    
    NSString *articleCountString = nil;
    
    if (articleCount == 0) {
        
        articleCountString = NSLocalizedString(articlePluralString, nil);
        
        if (self.scannedBarcode) {
            [STMSoundController alertSay:NSLocalizedString(@"NO ARTICLES FOR THIS BARCODE", nil)];
        }

    } else {
        
        articleCountString = [NSString stringWithFormat:@"%@ %@", @(articleCount), NSLocalizedString(articlePluralString, nil)];
        
    }
    
    STMBarButtonItemLabel *label = [[STMBarButtonItemLabel alloc] initWithTitle:articleCountString
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:nil
                                                                         action:nil];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    [self setToolbarItems:@[flexibleSpace, label, flexibleSpace] animated:NO];
    
}

- (void)updateClearFilterButton {
    
    if (self.scannedBarcode || self.selectedArticle) {
        
        STMBarButtonItem *clearFilterButton = [[STMBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Clear Filters-25"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(clearFilter)];
        
        NSMutableArray *toolbarItems = self.toolbarItems.mutableCopy;
        [toolbarItems addObject:clearFilterButton];
        [self setToolbarItems:toolbarItems animated:NO];
        
    }
    
}

- (void)clearFilter {
    
    self.scannedBarcode = nil;
    self.selectedArticle = nil;
    [self performFetch];
    
}

- (void)addBarcodeImage {
    
    UIImage *image = [STMFunctions resizeImage:[UIImage imageNamed:@"barcode.png"] toSize:CGSizeMake(25, 25)];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
}

- (void)removeBarcodeImage {
    self.navigationItem.titleView = nil;
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    self.navigationItem.title = NSLocalizedString(@"ARTICLES", nil);
    
    [self performFetch];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self startBarcodeScanning];
    
    if (IPHONE) {
        self.selectedArticle = nil;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
