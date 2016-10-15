//
//  STMUncashingTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMUncashingTVC_iPhone: STMUncashingMasterTVC {
    
    // MARK: Superclass override
    
    override func uncashingProcessStart(){
    }
    
    // MARK: Table view data
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if ((indexPath as NSIndexPath).section == 0) {
            performSegue(withIdentifier: "showUncashing", sender: nil)
        } else {
            let sectionInfo = self.resultsController.sections![(indexPath as NSIndexPath).section-1]
            let uncashing = sectionInfo.objects![(indexPath as NSIndexPath).row];
            performSegue(withIdentifier: "showUncashing", sender: uncashing)
        }
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.tintColor = .white()
        return indexPath
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier!{
        case "showUncashing":
            (segue.destination as! STMUncashingDetailsTVC).uncashing = sender as? STMUncashing
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            if sender != nil{
                if let destination = segue.destination as? STMUncashingDetailsTVC{
                    destination.title = NSLocalizedString("HAND OVER", comment: "").dropLast
                    if let date = (sender as! STMUncashing).date {
                        destination.title! += " (" + dateFormatter.string(from: date) + ")"
                    }
                }
            }else{
                (segue.destination as! STMUncashingDetailsTVC).title = NSLocalizedString("ON HAND", comment: "").dropLast
            }
        default:
            break
        }
    }
    
    // MARK: View lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setToolbarHidden(true, animated: true)
    }
}
