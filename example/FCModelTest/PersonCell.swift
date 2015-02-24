//
//  PersonCell.swift
//  FCModelTest
//
//  Created by Ahmad Alhashemi on 2015-02-23.
//  Copyright (c) 2015 Marco Arment. All rights reserved.
//

import Foundation

@objc(PersonCell)
class PersonCell : UICollectionViewCell {
    @IBOutlet var idLabel : UILabel?
    @IBOutlet var nameLabel : UILabel?
    @IBOutlet var tapsLabel : UILabel?
    @IBOutlet var colorLabel : UILabel?

    private var person : Person?

    func configureWithPerson(person : Person) {
        if (self.person != nil) {
            self.person?.removeObserver(self, forKeyPath: "name")
            self.person?.removeObserver(self, forKeyPath: "colorName")
            self.person?.removeObserver(self, forKeyPath: "taps")
        }
        
        self.person = person
        
        if (self.person != nil) {
            self.person?.addObserver(self, forKeyPath: "name", options:.Initial, context:nil)
            self.person?.addObserver(self, forKeyPath: "colorName", options:.Initial, context:nil)
            self.person?.addObserver(self, forKeyPath: "taps", options:.Initial, context:nil)
            
            self.idLabel?.text = NSString(format: "%lld", person.id) as? String
        }

    }
    
    deinit {
        if (self.person != nil) {
            self.person?.removeObserver(self, forKeyPath: "name")
            self.person?.removeObserver(self, forKeyPath: "colorName")
            self.person?.removeObserver(self, forKeyPath: "taps")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "name") {
            self.nameLabel?.text = person?.name
        } else if (keyPath == "colorName") {
            var c = person?.color
            self.backgroundColor = (c != nil) ? c?.colorValue : UIColor.clearColor()
            self.colorLabel?.text = (c != nil) ? c?.name : "(invalid)"
        } else if (keyPath == "taps") {
            self.tapsLabel?.text = NSString(format: "%d tap%@", person!.taps, (person?.taps == 1) ? "" : "s") as? String
        }
    }
}
