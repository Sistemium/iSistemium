//
//  STMUncashingInfoVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 15/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMUncashingInfoVC_iPhone: STMUncashingInfoVC {
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var sumTextLabel: UILabel!
    @IBOutlet weak var typeTextLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextView: UILabel!
    
    @IBAction func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(){
        STMUncashingProcessController.sharedInstance().uncashingDone()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.uncashing != nil {
            commentTextView.text = self.uncashing.commentText
        }
        else{
            commentTextView.text = self.comment
        }
        mainTextLabel.constraintWithIdentifier("height")?.constant = mainTextLabel.requiredHeight(self.view.frame.width )
        sumTextLabel.constraintWithIdentifier("height")?.constant = sumTextLabel.requiredHeight(self.view.frame.width )
        typeTextLabel.constraintWithIdentifier("height")?.constant = typeTextLabel.requiredHeight(self.view.frame.width )
        commentTextView.constraintWithIdentifier("height")?.constant = commentTextView.requiredHeight(self.view.frame.width )
        if imageView.image != nil {
            mainTextLabel?.preferredMaxLayoutWidth = self.view.frame.width / 2
            sumTextLabel?.preferredMaxLayoutWidth = self.view.frame.width / 2
            typeTextLabel?.preferredMaxLayoutWidth = self.view.frame.width / 2
            commentTextView?.preferredMaxLayoutWidth = self.view.frame.width / 2
            mainTextLabel.constraintWithIdentifier("height")?.constant = mainTextLabel.requiredHeight(self.view.frame.width / 2)
            sumTextLabel.constraintWithIdentifier("height")?.constant = sumTextLabel.requiredHeight(self.view.frame.width / 2)
            typeTextLabel.constraintWithIdentifier("height")?.constant = typeTextLabel.requiredHeight(self.view.frame.width / 2)
            commentTextView.constraintWithIdentifier("height")?.constant = commentTextView.requiredHeight(self.view.frame.width / 2)
        }
        self.preferredContentSize = CGSize(width: 500,height: mainTextLabel.constraintWithIdentifier("height")!.constant + sumTextLabel.constraintWithIdentifier("height")!.constant +
            typeTextLabel.constraintWithIdentifier("height")!.constant + commentTextView.constraintWithIdentifier("height")!.constant + 80)
    }
    
}

private extension UILabel{
    func requiredHeight(_ width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}

private extension UIView{
    func constraintWithIdentifier(_ identifier:String) -> NSLayoutConstraint?{
        if let constraint = (constraints.filter{$0.identifier == identifier}.first) {
            return constraint
        }
        return nil
    }
}
