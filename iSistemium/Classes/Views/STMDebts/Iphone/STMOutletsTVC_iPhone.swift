//
//  STMOutletsTVC_Iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 26/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMOutletsTVC_iPhone: STMOutletsTVC {
    
    override func cashingProcessStart() {
    }
    
    // MARK: Table view data
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let outlet = self.resultsController.object(at: indexPath)
        performSegue(withIdentifier: "showDebts", sender: outlet)
        return indexPath
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier!{
        case "showDebts":
            (segue.destination as! STMDebtsPVC_iPhone).outlet = sender as? STMOutlet
        default:
            break
        }
    }
    
    // MARK: View lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 2.0
    }
    
}
