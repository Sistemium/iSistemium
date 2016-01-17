//
//  STMShippingLocationsTVC.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 04/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMShippingLocationsTVC: STMSearchableTVC, UISearchBarDelegate{
    
    private var _resultsController:NSFetchedResultsController?
    
    override var resultsController : NSFetchedResultsController? {
        get {
            if (_resultsController == nil) {
                let shippingFetchRequest = NSFetchRequest(entityName: NSStringFromClass(STMShippingLocation))
                shippingFetchRequest.sortDescriptors = [NSSortDescriptor(key: "deviceTs",ascending:false)]
                shippingFetchRequest.predicate = self.predicate
                _resultsController = NSFetchedResultsController(fetchRequest: shippingFetchRequest, managedObjectContext: self.document.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                _resultsController!.delegate = self
            }
            
            return _resultsController
        }
        set {
            _resultsController = newValue
        }
    }
    
    private var predicate:NSPredicate? {
        if self.searchBar?.text != nil && self.searchBar.text! == ""{
            return NSPredicate(format: "name != %@", self.searchBar.text!)
        }
        if self.searchBar?.text != nil {
            return NSPredicate(format: "(name contains[c] %@) OR (address contains[c] %@)", self.searchBar.text!,self.searchBar.text!)
        }
        return nil;
    }
    
    // MARK: table view data
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController!.fetchedObjects!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath:indexPath) as! STMCustom7TVCell
        let location = self.resultsController!.objectAtIndexPath(indexPath) as! STMShippingLocation
        cell.titleLabel!.text = location.name
        cell.detailLabel!.text = location.address
        cell.accessoryType = .DisclosureIndicator
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showLocation", sender: indexPath)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let destination = (segue.destinationViewController as? UINavigationController)?.visibleViewController as? STMShippingLocationTVC  {
            if segue.identifier == "showLocation"{
                
                let shippingLocation = self.resultsController!.objectAtIndexPath(sender as! NSIndexPath) as? STMShippingLocation
                
                destination.shippingLocation = shippingLocation
                
//            destination.shippingLocation = self.resultsController!.objectAtIndexPath(sender as! NSIndexPath) as? STMShippingLocation
            }
        }
    }
    
    // MARK: search & UISearchBarDelegate
    
    override func searchButtonPressed() {
        self.searchBar.becomeFirstResponder()
        self.tableView.setContentOffset(CGPointZero, animated:true)
    }
    
    override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        performFetch()
    }
    
    override func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    override func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil;
        hideKeyboard()
        performFetch()
    }
    
    func hideKeyboard() {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        hideKeyboard()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideKeyboard()
    }
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    override func customInit() {
        super.customInit()
        self.cellIdentifier = "shippingLocationCell"
        title = self.splitViewController?.navigationItem.title
        let cellNib = UINib(nibName: NSStringFromClass(STMCustom7TVCell.self), bundle:nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier:self.cellIdentifier)
        performFetch()
    }
    
}