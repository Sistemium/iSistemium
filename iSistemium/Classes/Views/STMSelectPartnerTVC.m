//
//  STMSelectPartnerTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSelectPartnerTVC.h"
#import "STMAddPopoverNC.h"
#import "STMAddOutletVC.h"

#import "STMUI.h"

@interface STMSelectPartnerTVC ()

@property (nonatomic, strong) STMAddPopoverNC *parentNC;

@end

@implementation STMSelectPartnerTVC

@synthesize resultsController = _resultsController;

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPartner class])];
        
        NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        request.sortDescriptors = @[nameSortDescriptor];
        request.predicate = [NSPredicate predicateWithFormat:@"name != %@", nil];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (STMAddPopoverNC *)parentNC {
    
    if (!_parentNC) {
        
        if ([self.navigationController isKindOfClass:[STMAddPopoverNC class]]) {
            _parentNC = (STMAddPopoverNC *)self.navigationController;
        }
        
    }
    return _parentNC;
    
}

- (void)setPartner:(STMPartner *)partner {
    
    if (_partner != partner) {
        
        _partner = partner;
//        [self performSegueWithIdentifier:@"showAddOutlet" sender:partner];
        
    }
    
}

- (void)cancelButtonPressed {
    
    [self.parentNC dismissSelf];
    
}

- (void)performFetch {
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showAddOutlet"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMAddOutletVC class]] && [sender isKindOfClass:[STMPartner class]]) {
            
            [(STMAddOutletVC *)segue.destinationViewController setPartner:(STMPartner *)sender];
            
        }
        
    }
    
}

#pragma mark - Table view data source & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"partnerCell" forIndexPath:indexPath];
    
    STMPartner *partner = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = partner.name;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPartner *partner = [self.resultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"showAddOutlet" sender:partner];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.title = NSLocalizedString(@"SELECT PARTNER", nil);
    
    STMUIBarButtonItemCancel *cancelButton = [[STMUIBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:@[cancelButton, flexibleSpace]];
    
    [self.navigationItem setTitle:NSLocalizedString(@"PARTNERS", nil)];

}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self customInit];
    [self performFetch];
    
    if (self.partner) {
        [self performSegueWithIdentifier:@"showAddOutlet" sender:self.partner];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
