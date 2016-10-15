//
//  STMShippingLocationsTVC.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 04/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMShippingLocationsTVC: STMSearchableTVC, UISearchBarDelegate{
    
    fileprivate var _resultsController:NSFetchedResultsController<AnyObject>?
    
    override var resultsController : NSFetchedResultsController<AnyObject>? {
        get {
            if (_resultsController == nil) {
                let shippingFetchRequest = STMFetchRequest(entityName: "STMShippingLocation")
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
    
    fileprivate var predicate:NSPredicate? {
        if self.searchBar?.text != nil && self.searchBar.text! == ""{
            return NSPredicate(format: "name != %@", self.searchBar.text!)
        }
        if self.searchBar?.text != nil {
            return NSPredicate(format: "(name contains[c] %@) OR (address contains[c] %@)", self.searchBar.text!,self.searchBar.text!)
        }
        return nil;
    }
    
    // MARK: table view data
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController!.fetchedObjects!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for:indexPath) as! STMCustom7TVCell
        let location = self.resultsController!.object(at: indexPath) as! STMShippingLocation
        cell.titleLabel!.text = location.name
        cell.detailLabel!.text = location.address
        cell.accessoryType = .disclosureIndicator
        //as for 2016-01-21 without "cell.layoutIfNeeded()" occurs some weird xcode bug on real device (http://stackoverflow.com/questions/27842764/uitableviewautomaticdimension-not-working-until-scroll)
        cell.layoutIfNeeded()
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showLocation", sender: indexPath)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = (segue.destination as? UINavigationController)?.visibleViewController as? STMShippingLocationTVC  {
            if segue.identifier == "showLocation"{
            destination.shippingLocation = self.resultsController!.object(at: sender as! IndexPath) as? STMShippingLocation
            }
        }
    }
    
    // MARK: search & UISearchBarDelegate
    
    override func searchButtonPressed() {
        self.searchBar.becomeFirstResponder()
        self.tableView.setContentOffset(CGPoint.zero, animated:true)
    }
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performFetch()
    }
    
    override func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil;
        hideKeyboard()
        performFetch()
    }
    
    func hideKeyboard() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboard()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideKeyboard()
    }
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        customInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func customInit() {
        super.customInit()
        self.cellIdentifier = "shippingLocationCell"
        title = self.splitViewController?.navigationItem.title
        let cellNib = UINib(nibName: NSStringFromClass(STMCustom7TVCell.self), bundle:nil)
        self.tableView.register(cellNib, forCellReuseIdentifier:self.cellIdentifier)
        performFetch()
    }
    
}
